# 🚀 SIEM - Security Information and Event Management

![siem drawio](https://github.com/user-attachments/assets/4bcc6077-1377-405e-9b4d-d7cf4ebefc49)

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
![Untitled-2025-03-13-0920](https://github.com/user-attachments/assets/ff9cf809-7ad3-4ea6-a0de-6432b661b76d)

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

🔲 Konfigurasi sistem **SOAR** di **n8n**.

## 🎯 Cara Kontribusi
Jika tertarik untuk berkontribusi, silakan fork repository ini dan buat **Pull Request**! 💡


