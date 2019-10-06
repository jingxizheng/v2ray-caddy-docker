#!/bin/sh

# Config caddy to '/etc/Caddyfile'
# Env required: CADDY_DOMAIN
cat > /etc/Caddyfile << 'EOF'
CADDY_DOMAIN
{
  log /var/log/caddy.log
  proxy /ray localhost:9527 {
    websocket
    header_upstream -Origin
  }
}
EOF
sed -i "s/CADDY_DOMAIN/$CADDY_DOMAIN/" /etc/Caddyfile

# Copy index.html to '/srv/index.html'
cp -f index.html /srv/index.html

# Config v2ray to '/etc/v2ray/config.json'
# Env required: V2RAY_UUID
cat > /etc/v2ray/config.json << 'EOF'
{
    "inbounds": [
        {
            "port": 9527,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "V2RAY_UUID",
                        "alterId": 64
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                    "path": "/ray"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ],
    "outboundDetour": [
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "routing": {
        "strategy": "rules",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "0.0.0.0/8",
                        "10.0.0.0/8",
                        "100.64.0.0/10",
                        "127.0.0.0/8",
                        "169.254.0.0/16",
                        "172.16.0.0/12",
                        "192.0.0.0/24",
                        "192.0.2.0/24",
                        "192.168.0.0/16",
                        "198.18.0.0/15",
                        "198.51.100.0/24",
                        "203.0.113.0/24",
                        "::1/128",
                        "fc00::/7",
                        "fe80::/10"
                    ],
                    "outboundTag": "blocked"
                }
            ]
        }
    }
}
EOF
sed -i "s/V2RAY_UUID/$V2RAY_UUID/" /etc/v2ray/config.json

# Start caddy
# nohup /bin/parent caddy --conf /etc/Caddyfile --log stdout --agree=false &
# Start v2ray
# /usr/bin/v2ray -config /etc/v2ray/config.json