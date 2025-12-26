#!/bin/bash

# Fungsi untuk memverifikasi login root
verify_root_login() {
    echo "======================================"
    echo "      Login sebagai root diperlukan   "
    echo "======================================"
    read -sp "Masukkan password root: " root_password
    echo

    # Verifikasi apakah password root valid
    echo "$root_password" | sudo -kS echo "" > /dev/null 2>&1
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
    echo "3. Restart Spesifik Docker Container"
    echo "4. Restart Semua Docker Container"
    echo "5. Instalasi N8N"
	echo "6. Instalasi N8N Worker"
	echo "7. Instalasi WAHA"
 	echo "8. Instalasi Grafana"
    echo "0. Keluar"
    echo "================================================"
    read -p "Pilih opsi [0-8]: " opsi

    case $opsi in
        1)
            # Update & upgrade sistem
            echo "Melakukan update & upgrade sistem..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install apt-transport-https curl ca-certificates curl gnupg lsb-release -y
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo systemctl enable docker.service && sudo systemctl enable containerd.service
			sudo systemctl start docker.service && sudo systemctl start containerd.service
            echo "Update & upgrade selesai."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        2)
            # Instalasi Elastic Agent
            echo "Menginstal Elastic Agent..."
            read -p "Masukkan Fleet Enrollment Token: " ENROLLMENT_TOKEN
            echo "Install Elastic Agent Pada Server ini ..."
            read -p "Masukkan Nama Agent: " AGENT
            read -p "Masukkan IP Host Elasticsearch (contoh xx.xx.xx.xx): " IP_ADDRESS
			curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.19.9-linux-x86_64.tar.gz 
			tar xzvf elastic-agent-8.19.9-linux-x86_64.tar.gz
			cd elastic-agent-8.19.9-linux-x86_64
			sudo ./elastic-agent install --url=https://$IP_ADDRESS:8220 --enrollment-token=$ENROLLMENT_TOKEN
            echo "Elastic Agent berhasil diinstal dengan Docker!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        3)
            # Restart Elastic Agent (spesifik)
            echo "Daftar container aktif:"
            docker ps --format "table {{.Names}}\t{{.ID}}\t{{.Status}}"
            echo
            read -p "Masukkan nama atau ID docker container untuk di-restart: " container_name
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
            # Restart semua container
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
		    echo "Menginstal n8n..."
		
		    # Generate encryption key
		    KEY=$(openssl rand -hex 32)
		    echo "$KEY" > /root/n8n_data/encryption.key
		
		    # Persiapan direktori data
		    mkdir -p /root/n8n_data
		    chmod 777 /root/n8n_data
		    sleep 1
		
		    # Jalankan Redis
		    docker run -d \
		      --name redis-n8n \
		      --restart always \
		      redis:7
		
		    sleep 1
		
		    # Jalankan n8n main
		    docker run -d \
		      --name n8n-main \
		      --restart always \
		      -p 5678:5678 \
		      -v /root/n8n_data:/home/node/.n8n \
		      -e N8N_ENCRYPTION_KEY="$KEY" \
		      -e EXECUTIONS_MODE=queue \
		      -e QUEUE_BULL_REDIS_HOST=redis-n8n \
		      -e QUEUE_BULL_REDIS_PORT=6379 \
		      -e WEBHOOK_URL="http://$(hostname -I | awk '{print $1}'):5678" \
		      -e N8N_SECURE_COOKIE=false \
		      -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
		      --link redis-n8n \
		      n8nio/n8n
		
		    echo "✅ n8n berhasil diinstal!"
		    echo "Gunakan menu 6 untuk membuat worker tambahan."
		    read -p "Tekan Enter untuk kembali ke menu."
		    ;;

		6)
		    echo "Menginstal n8n worker..."
		
		    # Load KEY
		    if [ -f /root/n8n_data/encryption.key ]; then
		        KEY=$(cat /root/n8n_data/encryption.key)
		    else
		        echo "❌ Encryption key tidak ditemukan! Jalankan menu 5 dahulu."
		        exit 1
		    fi
		
		    # Input jumlah worker
		    read -p "Jumlah n8n Worker: " WORKER
		
		    # Validasi input
		    if ! [[ "$WORKER" =~ ^[0-9]+$ ]] || [ "$WORKER" -le 0 ]; then
		        echo "Input tidak valid. Harus angka > 0." >&2
		        exit 1
		    fi
		
		    echo "Membuat $WORKER worker..."
		    for ((i=1; i<=WORKER; i++)); do
		        docker run -d \
		          --name n8n-worker-$i \
		          --restart always \
		          -v /root/n8n_data:/home/node/.n8n \
		          -e N8N_ENCRYPTION_KEY="$KEY" \
		          -e EXECUTIONS_MODE=queue \
		          -e EXECUTIONS_CONCURRENCY=5 \
		          -e QUEUE_BULL_REDIS_HOST=redis-n8n \
		          -e QUEUE_BULL_REDIS_PORT=6379 \
		          -e N8N_SECURE_COOKIE=false \
		          --link redis-n8n \
		          n8nio/n8n worker
		
		        echo "✅ Worker $i dibuat!"
		    done
		
		    read -p "Tekan Enter untuk kembali ke menu."
		    ;;

        7)
            # Instalasi waha
            echo "Registrasi akun WAHA..."
			read -p "Masukkan Username WAHA: " USERNAME
            read -p "Masukkan Password WAHA: " PASSWORD
			echo "Menginstal waha..."
			docker run -d -e WHATSAPP_SWAGGER_USERNAME=$USERNAME -e WHATSAPP_SWAGGER_PASSWORD=$PASSWORD -e WAHA_DASHBOARD_USERNAME=$USERNAME -e WAHA_DASHBOARD_PASSWORD=$PASSWORD --restart=always  -p 3001:3000 --name waha devlikeapro/waha
            sleep 1
            echo "WAHA telah berhasil diinstal! Akses di http://$(hostname -I | awk '{print $1}'):3001/"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        8)
            # Instalasi grafana
            echo "Menginstal Grafana..."
			docker run -d --restart=always --name grafana -p 3000:3000 --name grafana grafana/grafana
            sleep 1
            echo "grafana telah berhasil diinstal! Akses di http://$(hostname -I | awk '{print $1}'):3000/"
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

