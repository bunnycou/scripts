#!/bin/bash

# Script that checks public IP and cloudflare DNS record and updates the DNS record if it does not match
# Scheduled to run hourly with crontab
# 0 * * * * /scripts/ddns.sh

ZONE_ID="Domain Zone ID"
DNS_RECORD_ID="DNS Record ID"
CLOUDFLARE_API_TOKEN="API KEY"
DNS_NAME="sub.domain.com"

# Get Public IP
PUBLIC_IP=$(curl -s https://api.ipify.org)

# Get Cloudflare DNS Record IP
CLOUDFLARE_IP=$(curl https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
    -X GET \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq -r '.result.content')

# If IPs do not match, update Cloudflare record to public IP
if [ "$PUBLIC_IP" != "$CLOUDFLARE_IP" ]; then
    echo "Updating Cloudflare IP ($CLOUDFLARE_IP) to $PUBLIC_IP"
    curl https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID \
        -X PUT \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -d "{\"name\": \"$DNS_NAME\", \"type\": \"A\", \"content\": \"$PUBLIC_IP\"}"
else
    echo "Public IP ($PUBLIC_IP) matches Cloudflare ($CLOUDFLARE_IP)"
fi
