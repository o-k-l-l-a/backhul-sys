#!/bin/bash

# آرایه آی‌پی‌های ایران + پورت
iran_ips_ports=(
"185.209.42.90:4000"
"2.188.227.128:4007"
"91.212.232.57:4014"
"91.234.38.13:4021"
"93.126.19.176:4028"
"89.235.117.132:4035"
"37.202.248.98:4042"
)

output_dir="/root/backhaul-core"
mkdir -p "$output_dir"

# تشخیص IP فعلی سرور
SERVER_IP=$(hostname -I | awk '{print $1}')

# جستجوی IP در آرایه و استخراج پورت
PORT=""
for entry in "${iran_ips_ports[@]}"; do
    ip=$(echo $entry | cut -d: -f1)
    port=$(echo $entry | cut -d: -f2)
    if [ "$ip" == "$SERVER_IP" ]; then
        PORT=$port
        break
    fi
done

if [ -z "$PORT" ]; then
    echo "IP سرور ($SERVER_IP) در آرایه ایران پیدا نشد!"
    exit 1
fi

# ساخت فایل TOML
toml_file="$output_dir/iran${PORT}.toml"
cat > "$toml_file" <<EOF
[server]
bind_addr = ":$PORT"
transport = "uwsmux"
accept_udp = false
token = "okila82"
keepalive_period = 75
nodelay = true
channel_size = 2048
heartbeat = 40
mux_con = 8
mux_version = 2
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 2000000
sniffer = false
web_port = 0
sniffer_log = "/root/log.json"
log_level = "info"
proxy_protocol= false
tun_name = "backhaul"
tun_subnet = "10.10.10.0/24"
mtu = 1500

ports = [
"4041",
"4040"
]
EOF

# ساخت Systemd service
service_file="/etc/systemd/system/backhaul-iran${PORT}.service"
cat > "$service_file" <<EOF
[Unit]
Description=Backhaul Iran Port $PORT
After=network.target

[Service]
Type=simple
ExecStart=$output_dir/backhaul_premium -c $toml_file
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# فعال سازی و استارت سرویس
systemctl daemon-reload
systemctl enable "backhaul-iran${PORT}.service"
systemctl start "backhaul-iran${PORT}.service"

echo "فایل TOML و سرویس Systemd برای IP $SERVER_IP و پورت $PORT ایجاد و استارت شدند."
