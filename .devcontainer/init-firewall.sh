#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "Initializing Codex devcontainer firewall..."

# Preserve Docker internal DNS NAT rules before flushing.
DOCKER_DNS_RULES="$(iptables-save -t nat | grep "127\.0\.0\.11" || true)"

# Flush existing rules and ipsets.
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# Restore Docker DNS rules.
if [ -n "$DOCKER_DNS_RULES" ]; then
  echo "Restoring Docker DNS rules..."
  iptables -t nat -N DOCKER_OUTPUT 2>/dev/null || true
  iptables -t nat -N DOCKER_POSTROUTING 2>/dev/null || true
  echo "$DOCKER_DNS_RULES" | xargs -L 1 iptables -t nat
else
  echo "No Docker DNS rules to restore"
fi

# Allow DNS.
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -j ACCEPT

# Allow SSH.
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Allow localhost.
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Create ipset with CIDR support.
ipset create allowed-domains hash:net

add_ipv4_to_ipset() {
  local ip="$1"
  local label="$2"

  if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Skipping non-IPv4 record for $label: $ip"
    return 0
  fi

  echo "Adding $ip for $label"
  ipset add allowed-domains "$ip" -exist
}

resolve_domain() {
  local domain="$1"

  echo "Resolving $domain..."
  local ips
  ips="$(dig +short A "$domain" || true)"

  if [ -z "$ips" ]; then
    echo "WARN: Failed to resolve $domain"
    return 0
  fi

  while read -r ip; do
    [ -z "$ip" ] && continue
    add_ipv4_to_ipset "$ip" "$domain"
  done < <(echo "$ips")
}

resolve_domain_pattern() {
  local domain="$1"

  # DNS wildcards cannot be resolved directly in a useful way.
  # Keep this helper for readability when documenting wildcard-style service needs.
  resolve_domain "$domain"
}

# Fetch GitHub IP ranges from GitHub meta API.
echo "Fetching GitHub IP ranges..."
gh_ranges="$(curl -fsSL https://api.github.com/meta || true)"

if [ -z "$gh_ranges" ]; then
  echo "ERROR: Failed to fetch GitHub IP ranges"
  exit 1
fi

if ! echo "$gh_ranges" | jq -e '.web and .api and .git' >/dev/null; then
  echo "ERROR: GitHub API response missing required fields"
  exit 1
fi

echo "Processing GitHub IP ranges..."
while read -r cidr; do
  [ -z "$cidr" ] && continue

  if [[ ! "$cidr" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    echo "Skipping non-IPv4 or invalid GitHub CIDR: $cidr"
    continue
  fi

  echo "Adding GitHub range $cidr"
  ipset add allowed-domains "$cidr" -exist
done < <(echo "$gh_ranges" | jq -r '(.web + .api + .git)[]' | aggregate -q)

# Core development domains.
DEV_DOMAINS=(
  # npm / package installation
  "registry.npmjs.org"
  "www.npmjs.com"
  "nodejs.org"

  # GitHub / raw files / releases
  "github.com"
  "api.github.com"
  "raw.githubusercontent.com"
  "objects.githubusercontent.com"
  "github-releases.githubusercontent.com"
  "codeload.github.com"

  # VS Code / Dev Containers
  "marketplace.visualstudio.com"
  "vscode.blob.core.windows.net"
  "update.code.visualstudio.com"

  # OpenAI / Codex auth and API
  "api.openai.com"
  "chatgpt.com"
  "auth.openai.com"
  "auth0.openai.com"
  "cdn.openai.com"
  "ab.chatgpt.com"
  "oaiusercontent.com"
  "files.oaiusercontent.com"
  "persistent.oaistatic.com"
  "oaistatic.com"

  # OpenAI developer docs / MCP docs if used
  "developers.openai.com"
  "platform.openai.com"

  # Sentry / common telemetry endpoints used by CLIs
  "sentry.io"
  "o33249.ingest.sentry.io"

  # Vercel / skills / shadcn ecosystem
  "vercel.com"
  "api.vercel.com"
  "v0.dev"
  "skills.sh"
  "registry.skills.sh"
  "ui.shadcn.com"
  "shadcn.com"

  # Supabase local/project tooling and MCP/docs
  "supabase.com"
  "api.supabase.com"
  "mcp.supabase.com"

  # Common CDNs used by npm tooling/docs
  "unpkg.com"
  "cdn.jsdelivr.net"
)

echo "Resolving allowlisted development domains..."
for domain in "${DEV_DOMAINS[@]}"; do
  resolve_domain "$domain"
done

# Optional: allow Supabase project domains by pattern is not possible via DNS wildcard.
# Add your concrete project ref here if needed:
#
# resolve_domain "YOUR_PROJECT_REF.supabase.co"
#
# For Sr. Reis, prefer adding the exact Supabase project host once known.

# Detect host network for local dev servers and host access.
HOST_IP="$(ip route | awk '/default/ {print $3; exit}')"

if [ -z "$HOST_IP" ]; then
  echo "ERROR: Failed to detect host IP"
  exit 1
fi

HOST_NETWORK="$(echo "$HOST_IP" | sed 's/\.[0-9]*$/.0\/24/')"
echo "Host network detected as: $HOST_NETWORK"

iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT

# Allow established connections.
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Default deny policies.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow outbound traffic to approved IPs only.
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

# Reject everything else for immediate feedback.
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

echo "Firewall configuration complete"
echo "Verifying firewall rules..."

# Block test.
if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
  echo "ERROR: Firewall verification failed - was able to reach https://example.com"
  exit 1
else
  echo "Firewall verification passed - unable to reach https://example.com as expected"
fi

# GitHub test.
if ! curl --connect-timeout 5 https://api.github.com/zen >/dev/null 2>&1; then
  echo "ERROR: Firewall verification failed - unable to reach https://api.github.com"
  exit 1
else
  echo "Firewall verification passed - able to reach https://api.github.com as expected"
fi

# npm test.
if ! curl --connect-timeout 5 https://registry.npmjs.org/ >/dev/null 2>&1; then
  echo "ERROR: Firewall verification failed - unable to reach registry.npmjs.org"
  exit 1
else
  echo "Firewall verification passed - able to reach registry.npmjs.org as expected"
fi

# OpenAI API connectivity test.
# This only checks network reachability, not auth validity.
if ! curl --connect-timeout 5 https://api.openai.com/v1/models >/dev/null 2>&1; then
  echo "WARN: Could not reach https://api.openai.com/v1/models"
  echo "WARN: If Codex fails, inspect blocked domains and add the exact host to DEV_DOMAINS."
else
  echo "Firewall verification passed - able to reach api.openai.com as expected"
fi

echo "Codex devcontainer firewall is active"
