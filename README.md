# 🚀 SIEM - Security Information and Event Management


## 📌 Tentang Proyek
Proyek **SIEM** ini bertujuan untuk membangun sistem **Security Information and Event Management** (SIEM) berbasis **Elasticsearch, Kibana, Elastic-Agent**, dan **Jira** untuk mendeteksi serta merespons ancaman keamanan secara otomatis.

## 🏗️ Desain Arsitektur
Proyek ini menggunakan **3 jenis Aplikasi** dengan fungsi sebagai berikut:

### 🔹 1. Sistem Manager
Sistem utama untuk mengelola dan mengolah data yang dikumpulkan dari server sensor.

🔹 **Aplikasi yang digunakan:**
- Elasticsearch
- Kibana
- FleetServer

### 🔹 2. Sensor
Sistem yang bertugas mengumpulkan log dari berbagai perangkat seperti **Firewall, WAF, Website, dll.**

🔹 **Aplikasi yang digunakan:**
- Elastic-Agent

### 🔹 3. SOAR & Ticket
Sistem ini bertugas untuk otomasi **alert & ticketing** dari Server Manager.

🔹 **Aplikasi yang digunakan:**
- n8n
- Jira

## 📌 Sketsa Arsitektur
![Untitled-2025-03-13-0920](https://github.com/user-attachments/assets/4070bf9f-8c33-4c98-a134-9dace569e1e2)

## ✅ Checkpoint (Progress yang sudah dikerjakan)

✔️ Pembuatan **script instalasi** untuk 3 jenis server.

✔️ Integrasi **Elasticsearch, Kibana, dan Elastic-Agent**.

✔️ Pengiriman **log** dari beberapa sumber (*website & Threat Intelligence*) ke Elasticsearch.

✔️ Testing script instalasi server.

✔️ Konfigurasi **relasi Elasticsearch → n8n → Jira**.


## 🛠️ Challenges (Yang masih perlu dikerjakan)

🔲 Integrasi **ticketing ke media sosial**.

🔲 Konfigurasi **pengumpulan log** dari perangkat keamanan.

🔲 Konfigurasi **SIEM rules** di Elasticsearch.

🔲 List perangkat yang akan dimonitor.

## 🎯 Cara Kontribusi
Jika tertarik untuk berkontribusi, silakan fork repository ini dan buat **Pull Request**! 💡


