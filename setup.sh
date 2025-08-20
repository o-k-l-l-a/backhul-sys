#!/bin/bash
set -e

echo "📦 شروع نصب backhaul..."

# --- بخش اول: آماده‌سازی مسیر ---
mkdir -p /root/backhaul-core
cd /root/backhaul-core

BASE_URL_CORE="https://raw.githubusercontent.com/o-k-l-l-a/backhul-sys/refs/heads/main/backhaul-core"

FILES_CORE=(
    "iran55.toml"
    "iran60.toml"
    "iran70.toml"
    "iran75.toml"
    "iran80.toml"
    "iran85.toml"
    "iran90.toml"
    "iran95.toml"
    "iran100.toml"
)

# --- دانلود backhaul_premium اگر وجود نداشت ---
if [ ! -f "/root/backhaul-core/backhaul_premium" ]; then
    echo "⬇️ تلاش برای دانلود backhaul_premium ..."
    if curl -fsSL -o backhaul_premium "$BASE_URL_CORE/backhaul_premium"; then
        chmod +x backhaul_premium
        echo "✅ backhaul_premium دانلود شد."
    else
        echo "❌ دانلود backhaul_premium ناموفق بود. لطفاً فایل را دستی قرار دهید."
        exit 1
    fi
else
    echo "ℹ️ backhaul_premium از قبل وجود دارد، دانلود نمی‌شود."
    chmod +x backhaul_premium
fi

# --- دانلود فایل‌های کانفیگ ---
echo "⬇️ دانلود فایل‌های core..."
for file in "${FILES_CORE[@]}"; do
    echo "دانلود $file ..."
    if ! curl -fsSL -o "$file" "$BASE_URL_CORE/$file"; then
        echo "⚠️ دانلود $file ناموفق بود"
    fi
done

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
    if ! curl -fsSL -o "/etc/systemd/system/$file" "$BASE_URL_SYSTEMD/$file"; then
        echo "⚠️ دانلود سرویس $file ناموفق بود"
    fi
done

# --- رفرش systemd ---
echo "🔄 ریفرش systemd ..."
systemctl daemon-reload

# --- فعال‌سازی و اجرای سرویس‌ها ---
echo "🚀 فعال‌سازی سرویس‌ها..."
for svc in 55 60 70 75 80 85 90 95 100; do
    systemctl enable backhaul-iran${svc}.service --now
done

# --- نمایش وضعیت ---
echo "📋 وضعیت سرویس‌ها:"
systemctl --no-pager --full -l status backhaul-iran*.service | grep -E "●|Active|Main PID|failed"

echo "✅ نصب کامل شد و همه سرویس‌ها فعال شدند."
