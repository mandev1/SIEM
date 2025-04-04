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
    echo "   Deployment Elastic Agent                     "
    echo "================================================"
    echo "1. Update & Upgrade Sistem"
    echo "2. Instalasi Elastic Agent via Docker"
    echo "3. Restart Elastic Agent"
    echo "4. Restart Semua Elastic Agent"
    echo "5. Instalasi n8n"
    echo "6. Restart n8n"
    echo "0. Keluar"
    echo "================================================"
    read -p "Pilih opsi [0-6]: " opsi

    case $opsi in
        1)
            # Update & upgrade sistem
            echo "Melakukan update & upgrade sistem..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install apt-transport-https curl gnupg docker.io -y
            echo "Update & upgrade selesai."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        2)
            # Instalasi Elastic Agent
            echo "Menginstal Elastic Agent..."
            read -p "Masukkan Fleet Enrollment Token: " ENROLLMENT_TOKEN
            echo "Install Elastic Agent Pada Server ini (via Docker)..."
            read -p "Masukkan Nama Agent: " AGENT
            read -p "Masukkan IP Host Elasticsearch : " IP_ADDRESS
            sudo docker run -d --restart=always --name $AGENT \
                --env FLEET_ENROLL=1 \
                --env FLEET_URL=https://$IP_ADDRESS:8220 \
                --env FLEET_ENROLLMENT_TOKEN=$ENROLLMENT_TOKEN \
                --env FLEET_INSECURE=true \
                --cap-add=NET_RAW \
                --cap-add=SETUID \
                docker.elastic.co/elastic-agent/elastic-agent-complete:8.17.0
            echo "Elastic Agent berhasil diinstal dengan Docker!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        3)
            # Restart Elastic Agent (spesifik)
            echo "Daftar container aktif:"
            docker ps --format "table {{.Names}}\t{{.ID}}\t{{.Status}}"
            echo
            read -p "Masukkan nama atau ID container Elastic Agent untuk di-restart: " container_name
            if [ -z "$container_name" ]; then
                echo "Nama atau ID container tidak boleh kosong!"
            else
                echo "Merestart container $container_name..."
                docker restart "$container_name" 2>/dev/null

                if [ $? -eq 0 ]; then
                    echo "Container $container_name telah di-restart!"
                else
                    echo "Container $container_name tidak ditemukan atau terjadi kesalahan."
                fi
            fi
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        4)
            # Restart semua Elastic Agent
            if [ -z "$(docker ps -q)" ]; then
                echo "Tidak ada container yang sedang berjalan untuk di-restart."
            else
                echo "Merestart semua container Elastic Agent..."
                docker restart $(docker ps -q)
                echo "Semua container telah di-restart!"
            fi
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        5)
            # Instalasi n8n
            echo "Menginstal n8n..."
            docker run -d --restart=always --name n8n -p 5678:5678 n8nio/n8n -e N8N_SECURE_COOKIE=false n8nio/n8n
            sleep 1
            echo "n8n telah berhasil diinstal! Akses di http://$(hostname -I | awk '{print $1}'):5678/"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        6)
            # Restart n8n
            echo "Restart n8n..."
            docker restart n8n 
            sleep 1
            echo "n8n telah berhasil Restart! Akses di http://$(hostname -I | awk '{print $1}'):5678/"
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
            ;;
    esac
done

