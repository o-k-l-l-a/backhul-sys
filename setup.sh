#!/bin/bash
set -e

echo "📦 شروع نصب backhaul..."

# --- بخش اول: دانلود فایل‌های backhaul-core ---
mkdir -p /root/backhaul-core
cd /root/backhaul-core

BASE_URL_CORE="https://raw.githubusercontent.com/o-k-l-l-a/backhul-sys/refs/heads/main/backhaul-core"

FILES_CORE=(
    "backhaul_premium"
    "iran100.toml"
    "iran55.toml"
    "iran60.toml"
    "iran70.toml"
    "iran75.toml"
    "iran80.toml"
    "iran85.toml"
    "iran90.toml"
    "iran95.toml"
)

echo "⬇️ دانلود فایل‌های core..."
for file in "${FILES_CORE[@]}"; do
    echo "دانلود $file ..."
    curl -s -O "$BASE_URL_CORE/$file"
done

chmod +x backhaul_premium
cd /root

# --- بخش دوم: دانلود فایل‌های systemd service ---
BASE_URL_SYSTEMD="https://raw.githubusercontent.com/o-k-l-l-a/backhul-sys/refs/heads/main/etc/systemd/system"

FILES_SYSTEMD=(
    "backhaul-iran55.service"
    "backhaul-iran60.service"
    "backhaul-iran70.service"
    "backhaul-iran75.service"
    "backhaul-iran80.service"
    "backhaul-iran85.service"
    "backhaul-iran90.service"
    "backhaul-iran95.service"
    "backhaul-iran100.service"
)

echo "⬇️ دانلود فایل‌های systemd ..."
for file in "${FILES_SYSTEMD[@]}"; do
    echo "دانلود $file به /etc/systemd/system ..."
    sudo curl -s -o "/etc/systemd/system/$file" "$BASE_URL_SYSTEMD/$file"
done

# --- رفرش systemd ---
echo "🔄 ریفرش systemd ..."
sudo systemctl daemon-reload

# --- فعال‌سازی و اجرای سرویس‌ها ---
echo "🚀 فعال‌سازی سرویس‌ها..."
for svc in 55 60 70 75 80 85 90 95 100; do
    sudo systemctl enable backhaul-iran${svc}.service --now
done

# --- اجرای مستقیم backhaul_premium با کانفیگ‌ها ---
echo "▶️ اجرای مستقیم backhaul_premium با کانفیگ‌ها..."
for svc in 55 60 70 75 80 85 90 95 100; do
    /root/backhaul-core/backhaul_premium -c /root/backhaul-core/iran${svc}.toml &
done

# --- ریستارت نهایی سرویس‌ها ---
echo "♻️ ریستارت نهایی همه سرویس‌ها..."
for svc in 55 60 70 75 80 85 90 95 100; do
    sudo systemctl restart backhaul-iran${svc}.service
done

echo "✅ نصب کامل شد و همه سرویس‌ها ریستارت شدند."
