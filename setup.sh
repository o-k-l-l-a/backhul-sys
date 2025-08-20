#!/bin/bash
set -e

SERVICES=(55 60 65 70 75 80 85 90 95 100)
BASE_URL_CORE="https://raw.githubusercontent.com/o-k-l-l-a/backhul-sys/refs/heads/main/backhaul-core"
BASE_URL_SYSTEMD="https://raw.githubusercontent.com/o-k-l-l-a/backhul-sys/refs/heads/main/etc/systemd/system"

function uninstall_backhaul() {
    echo "🛑 توقف و حذف سرویس‌ها..."
    for svc in "${SERVICES[@]}"; do
        systemctl stop backhaul-iran${svc}.service || true
        systemctl disable backhaul-iran${svc}.service || true
        rm -f /etc/systemd/system/backhaul-iran${svc}.service
    done
    systemctl daemon-reload
    systemctl reset-failed

    echo "🗑 حذف فایل‌های core..."
    rm -rf /root/backhaul-core
    echo "✅ حذف کامل شد."
}

function install_backhaul() {
    echo "📦 شروع نصب backhaul..."
    mkdir -p /root/backhaul-core
    cd /root/backhaul-core

    # دانلود باینری
    if [ ! -f "backhaul_premium" ]; then
        echo "⬇️ دانلود backhaul_premium ..."
        curl -fsSL -o backhaul_premium "$BASE_URL_CORE/backhaul_premium"
        chmod +x backhaul_premium
    fi

    # دانلود کانفیگ‌ها
    for svc in "${SERVICES[@]}"; do
        echo "⬇️ دانلود iran${svc}.toml ..."
        curl -fsSL -o iran${svc}.toml "$BASE_URL_CORE/iran${svc}.toml" || echo "⚠️ دانلود iran${svc}.toml ناموفق بود"
    done

    cd /root

    # دانلود فایل‌های systemd
    for svc in "${SERVICES[@]}"; do
        echo "⬇️ دانلود backhaul-iran${svc}.service ..."
        curl -fsSL -o "/etc/systemd/system/backhaul-iran${svc}.service" "$BASE_URL_SYSTEMD/backhaul-iran${svc}.service" || echo "⚠️ دانلود سرویس ${svc} ناموفق بود"
    done

    # ریفرش systemd
    systemctl daemon-reload

    # فعال‌سازی
    for svc in "${SERVICES[@]}"; do
        systemctl enable backhaul-iran${svc}.service --now
    done

    echo "✅ نصب کامل شد."
    systemctl --no-pager --full -l status backhaul-iran*.service | grep -E "●|Active|failed"
}

function close_ports() {
    echo "🔒 بستن پورت‌های سرویس‌ها..."
    for svc in "${SERVICES[@]}"; do
        ufw deny ${svc} || true
    done
    ufw reload
    echo "✅ همه پورت‌ها بسته شدند."
}

function open_ports() {
    echo "🔓 باز کردن پورت‌های سرویس‌ها..."
    for svc in "${SERVICES[@]}"; do
        ufw allow ${svc} || true
    done
    ufw reload
    echo "✅ همه پورت‌ها باز شدند."
}

echo "=== مدیریت Backhaul Iran ==="
echo "1) Uninstall (حذف کامل)"
echo "2) Install (نصب مجدد)"
echo "3) Close Ports (بستن همه پورت‌ها)"
echo "4) Open Ports (باز کردن همه پورت‌ها)"
read -p "انتخاب شما: " choice

case $choice in
    1) uninstall_backhaul ;;
    2) install_backhaul ;;
    3) close_ports ;;
    4) open_ports ;;
    *) echo "❌ انتخاب نامعتبر" ;;
esac
