#!/bin/bash

# Fungsi untuk memverifikasi login root
verify_root_login() {
    echo "======================================"
    echo "      Login sebagai root diperlukan   "
    echo "======================================"
    read -sp "Masukkan password root: " root_password
    echo

    # Verifikasi apakah password root valid
    echo "$root_password" | sudo -S echo "" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Password salah. Silakan coba lagi."
        sleep 2
        clear
        verify_root_login
    else
        echo "Login berhasil!"
        sleep 2
    fi
}

# Memanggil fungsi login sebelum melanjutkan
verify_root_login

# Menu utama
while true; do
    clear
    echo "================================================"
    echo "   Instalasi Zammad dan n8n                    "
    echo "================================================"
    echo "1. Update & Upgrade Sistem"
    echo "2. Instalasi Zammad"
    echo "3. Instalasi n8n"
    echo "4. Restart n8n (spesifik)"
    echo "0. Keluar"
    echo "================================================"
    read -p "Pilih opsi [0-5]: " opsi

    case $opsi in
        1)
            # Update & upgrade sistem
            echo "Melakukan update & upgrade sistem..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install apt-transport-https wget curl gnupg -y
            echo "Update & upgrade selesai."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        2)
            # Instalasi Zammad
            echo "Menginstal Zammad..."
            wget -qO- https://dl.packager.io/srv/zammad/zammad/key | sudo apt-key add -
            echo "deb [signed-by=/usr/share/keyrings/zammad-archive-keyring.gpg] https://dl.packager.io/srv/deb/zammad/zammad/stable/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/zammad.list
            sudo apt update && sudo apt install zammad -y
            sudo systemctl enable zammad
            sudo systemctl start zammad
            echo "Zammad telah berhasil diinstal! Akses di http://$(hostname -I | awk '{print $1}')"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        3)
            # Instalasi n8n
            echo "Menginstal n8n..."
            curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
            sudo apt install nodejs -y
            sudo npm install -g n8n
            sudo bash -c 'cat > /etc/systemd/system/n8n.service <<EOF
[Unit]
Description=n8n Automation Tool
After=network.target

[Service]
Type=simple
User=$(whoami)
ExecStart=$(which n8n)
Restart=on-failure
Environment=GENERIC_TIMEZONE="UTC"

[Install]
WantedBy=multi-user.target
EOF'
            sudo systemctl daemon-reload
            sudo systemctl enable n8n
            sudo systemctl start n8n
            echo "n8n telah berhasil diinstal! Akses di http://$(hostname -I | awk '{print $1}'):5678/"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        4)
            # Restart Zammad
            echo "Merestart layanan Zammad..."
            sudo systemctl restart zammad
            echo "Layanan Zammad telah di-restart!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        5)
            # Restart n8n
            echo "Merestart layanan n8n..."
            sudo systemctl restart n8n
            echo "Layanan n8n telah di-restart!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        0)
            # Keluar dari program
            echo "Keluar dari menu. Sampai jumpa!"
            exit 0
            ;;
        *)
            # Opsi tidak valid
            echo "Pilihan tidak valid. Silakan coba lagi."
            sleep 1
            ;;
    esac
done

