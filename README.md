# 🚀 SIEM - Security Information and Event Management


## 📌 Tentang Proyek
Proyek **SIEM** ini bertujuan untuk membangun sistem **Security Information and Event Management** (SIEM) berbasis **Elasticsearch, Kibana, Elastic-Agent**, dan **Zammad** untuk mendeteksi serta merespons ancaman keamanan secara otomatis.

## 🏗️ Desain Arsitektur
Proyek ini menggunakan **3 jenis server** dengan fungsi sebagai berikut:

### 🔹 1. Server Manager
Server utama untuk mengelola dan mengolah data yang dikumpulkan dari server sensor.

🔹 **Aplikasi yang digunakan:**
- Elasticsearch
- Kibana
- FleetServer

### 🔹 2. Server Sensor
Server yang bertugas mengumpulkan log dari berbagai perangkat seperti **Firewall, WAF, Website, dll.**

🔹 **Aplikasi yang digunakan:**
- Elastic-Agent

### 🔹 3. Server SOAR & Ticket
Server ini bertugas untuk otomasi **alert & ticketing** dari Server Manager.

🔹 **Aplikasi yang digunakan:**
- n8n
- Zammad

## 📌 Sketsa Arsitektur
![WhatsApp Image 2025-03-19 at 16 45 13_d3e06c4d](https://github.com/user-attachments/assets/97cd32e0-ac8e-4672-a48b-de3f8b20f88f)

## ✅ Checkpoint (Progress yang sudah dikerjakan)

✔️ Pembuatan **script instalasi** untuk 3 jenis server.

✔️ Integrasi **Elasticsearch, Kibana, dan Elastic-Agent**.

✔️ Pengiriman **log** dari beberapa sumber (*website & Threat Intelligence*) ke Elasticsearch.

## 🛠️ Challenges (Yang masih perlu dikerjakan)

🔲 Testing script instalasi 3 jenis server.

🔲 Integrasi **ticketing ke media sosial**.

🔲 Konfigurasi **relasi Elasticsearch → n8n → Zammad**.

🔲 Konfigurasi **pengumpulan log** dari perangkat keamanan.

🔲 Konfigurasi **SIEM rules** di Elasticsearch.

🔲 List perangkat yang akan dimonitor.

## 🎯 Cara Kontribusi
Jika tertarik untuk berkontribusi, silakan fork repository ini dan buat **Pull Request**! 💡


