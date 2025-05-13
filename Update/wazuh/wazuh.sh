#!/bin/bash

# Fungsi untuk memverifikasi login root
function verify_root_login() {
    echo "======================================"
    echo "      Login sebagai root diperlukan    "
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
    echo "======================================"
    echo "         Elasticsearch & Kibana       "
    echo "======================================"
    echo "1. Update & Upgrade Sistem"
    echo "2. Create Certificate"
    echo "3. Install Wazuh Indexer"
    echo "4. Install Wazuh Manager"
    echo "5. Install Wazuh Dashboard"
    echo "6. Restart Service"
    echo "0. Keluar"
    echo "======================================"
    read -p "Pilih opsi [0-8]: " opsi

    case $opsi in
        1)
            echo "Melakukan update & upgrade sistem..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install apt-transport-https curl gnupg debconf adduser procps libcap -y
            sudo curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && sudo chmod 644 /usr/share/keyrings/wazuh.gpg
            sudo echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
            sudo apt update
            echo "Update & upgrade selesai."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        2)
            echo "Generate Certificate..."
            sed -i 's/<indexer-node-ip>/$(hostname -I | awk '{print $1}')/g' config.yml
	    sed -i 's/<wazuh-manager-ip>/$(hostname -I | awk '{print $1}')/g' config.yml
    	    sed -i 's/<dashboard-node-ip>/$(hostname -I | awk '{print $1}')/g' config.yml
	    sudo ./wazuh-certs-tool.sh -A
     	    sleep 1
	    ls -lah  ./wazuh-certificates
     	    echo "Certificate sudah selesai dibuat!!!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        3)
            echo "Menginstal Wazuh Indexer..."
            sudo apt install wazuh-indexer -y
            sudo sed -i 's/127.0.0.1/$(hostname -I | awk '{print $1}')/g' /etc/wazuh-indexer/opensearch.yml
	    sudo sed -i 's/Xms1g/Xms4g/g' /etc/wazuh-indexer/jvm.options
	    sudo sed -i 's/Xmx1g/Xmx4g/g' /etc/wazuh-indexer/jvm.options
	    mkdir /etc/wazuh-indexer/certs
	    sudo cp admin.pem admin-key.pem root-ca.pem  /etc/wazuh-indexer/certs
     	    sudo cp node-1.pem /etc/wazuh-indexer/certs/indexer.pem
	    sudo cp node-1-key.pem /etc/wazuh-indexer/certs/indexer-key.pem
	    sudo chmod 500 /etc/wazuh-indexer/certs
	    sudo chmod 400 /etc/wazuh-indexer/certs/*
	    sudo chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs
            sudo systemctl daemon-reload
     	    sudo systemctl enable wazuh-indexer
	    sudo systemctl start wazuh-indexer
            sudo /usr/share/wazuh-indexer/bin/indexer-security-init.sh
	    sleep 1
            echo "Instalasi Wazuh Indexer selesai!!!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
     
        4)  
            echo "Menginstal Wazuh Manager..."
            sudo apt install wazuh-manager filebeat -y
            sudo sed -i 's/127.0.0.1/$(hostname -I | awk '{print $1}')/g' /etc/filebeat/filebeat.yml
	    sudo filebeat keystore create
     	    sudo echo admin | filebeat keystore add username --stdin --force
            sudo echo admin | filebeat keystore add password --stdin --force
	    sudo curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.12.0/extensions/elasticsearch/7.x/wazuh-template.json
	    sudo chmod go+r /etc/filebeat/wazuh-template.json
	    sudo curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.4.tar.gz | sudo tar -xvz -C /usr/share/filebeat/module
	    mkdir /etc/wazuh-indexer/certs
	    sudo cp root-ca.pem  /etc/wazuh-indexer/certs
     	    sudo cp wazuh-1.pem /etc/filebeat/certs/filebeat.pem
	    sudo cp wazuh-1-key.pem /etc/filebeat/certs/filebeat-key.pem
	    sudo chmod 500 /etc/filebeat/certs
	    sudo chmod 400 400 /etc/filebeat/certs/*
	    sudo chown -R root:root /etc/filebeat/certs
     	    sudo echo admin | /var/ossec/bin/wazuh-keystore -f indexer -k username
	    sudo echo admin | /var/ossec/bin/wazuh-keystore -f indexer -k password
     	    sudo sed -i 's/127.0.0.1:9200/$(hostname -I | awk '{print $1}'):9200/g' /var/ossec/etc/ossec.conf
     	    sudo systemctl enable wazuh-indexer
	    sudo systemctl start wazuh-indexer
            sudo systemctl enable filebeat
	    sudo systemctl start filebeat
	    sleep 1
	    filebeat test output
	    sleep 1
            echo "Instalasi Wazuh Manager selesai!!!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
        5)
 	    echo "Menginstal Wazuh Dashboard..."
            sudo apt install wazuh-dashboard -y
            sudo sed -i 's/localhost:9200/$(hostname -I | awk '{print $1}')9200/g' /etc/wazuh-dashboard/opensearch_dashboards.yml
	    mkdir /etc/wazuh-dashboard/certs
	    sudo cp root-ca.pem dashboard-key.pem dashboard.pem   /etc/wazuh-dashboard/certs
	    sudo chmod 500 /etc/wazuh-dashboard/certs
	    sudo chmod 400 /etc/wazuh-dashboard/certs/*
	    sudo chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs
     	    sudo systemctl enable wazuh-dashboard
	    sudo systemctl start wazuh-dashboard
            sudo /usr/share/wazuh-indexer/bin/indexer-security-init.sh
	    sleep 1
            echo "Instalasi Wazuh Dashboard selesai!!!"
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
     
        6)
            echo "Restart Semua Service..."
            sleep 1
	    
            echo "Restart Wazuh Indexer..."
            sudo systemctl restart wazuh-indexer
            sleep 1
            echo "Wazuh Indexer selesai Restart!"
            sleep 1
	    
            echo "Restart Wazuh Manager"
            sudo systemctl restart wazuh-manager
            sleep 1
            echo "Wazuh Manager selesai Restart!"
            sleep 1
	    
            echo "Restart Wazuh Dashboard"
            sudo systemctl restart wazuh-dashboard
            sleep 1
            echo "Wazuh Dashboard selesai Restart!"
            sleep 1
	    echo "Restart Filebeat"
            sudo systemctl restart filebeat
            sleep 1
            echo "Filebeat selesai Restart!"
            sleep 1
	    read -p "Tekan Enter untuk kembali ke menu."
            ;;
        0)
            echo "Keluar dari menu. Sampai jumpa!"
            sleep 1
            clear
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid. Coba lagi."
            sleep 1
            read -p "Tekan Enter untuk kembali ke menu."
            ;;
    esac
done
