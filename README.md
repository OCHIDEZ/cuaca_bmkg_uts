# BMKG Info: Cuaca & Gempa (cuaca_bmkg_uts)

## Deskripsi Singkat Aplikasi
**BMKG Info: Cuaca & Gempa** adalah aplikasi mobile berbasis Flutter dan Dart yang menyajikan informasi prakiraan cuaca multi-wilayah serta pemantauan aktivitas gempa bumi secara *real-time* di Indonesia. Aplikasi ini mengintegrasikan data dinamis dari API terbuka Badan Meteorologi, Klimatologi, dan Geofisika (BMKG) serta API referensi wilayah administrasi Indonesia dalam antarmuka pengguna yang informatif dan interaktif.

## Fitur Utama
1. **Pemilih Wilayah Dinamis (Multi-Region Selector):** Memilih Provinsi, Kabupaten/Kota, dan Kecamatan di seluruh Indonesia secara berjenjang untuk melihat cuaca spesifik wilayah terkait.
2. **Prakiraan Cuaca 3 Hari & Highlight Cuaca Terkini:** Menampilkan suhu udara (°C), kondisi cuaca, kelembapan (%), kecepatan & arah angin, jarak pandang, persentase tutupan awan, serta jadwal cuaca per 3 jam selama 3 hari ke depan.
3. **Peta Interaktif Episentrum Gempa Bumi:** Visualisasi geografis titik pusat gempa terbaru dan 15 gempa terkini (M ≥ 5.0) di atas peta interaktif OpenStreetMap dengan fitur fokus kamera saat penanda (*marker*) atau daftar gempa diketuk.
4. **Informasi Detail Gempa Real-Time:** Menyajikan parameter lengkap meliputi magnitudo, kedalaman, waktu kejadian, koordinat lintang & bujur, lokasi wilayah pusat gempa, potensi tsunami, dan skala guncangan dirasakan (MMI).
5. **Manajemen Cache & Asynchronous State Handling:** Mendukung penyimpanan *in-memory cache*, *pull-to-refresh* (`RefreshIndicator`), *auto-retry* saat terjadi pembatasan server (HTTP 429), serta penanganan kondisi *Loading*, *Success*, dan *Error* menggunakan `FutureBuilder`.

## Teknologi & Package yang Digunakan
* **Framework & Bahasa:** Flutter SDK (Material 3) & Dart
* **`http`:** Melakukan permintaan HTTP GET ke REST API BMKG dan API wilayah Indonesia.
* **`flutter_map`:** Menampilkan peta interaktif berbasis OpenStreetMap (`TileLayer` & `MarkerLayer`).
* **`latlong2`:** Mengelola struktur data koordinat geografis (`LatLng`) untuk pemetaan titik gempa.
* **`dart:convert`:** Mengonversi (*decoding*) respons JSON menjadi objek model Dart.

## Langkah Menjalankan Aplikasi
1. Pastikan **Flutter SDK** sudah terinstal dan terkonfigurasi dengan baik di komputer Anda.
2. Buka folder project `cuaca_bmkg_uts` menggunakan IDE favorit Anda (seperti **Android Studio** atau **Visual Studio Code**).
3. Buka terminal di dalam IDE tersebut, lalu jalankan perintah berikut untuk mengunduh seluruh dependensi atau *package* yang dibutuhkan:
   ```bash
   flutter pub get

## Struktur Direktori Utama (`lib/`)
```text
lib/
├── models/
│   ├── earthquake_model.dart   # Model data gempa bumi BMKG
│   └── weather_model.dart      # Model data lokasi dan prakiraan cuaca BMKG
├── screens/
│   ├── main_screen.dart        # Navigasi utama aplikasi (Bottom Navigation Bar)
│   ├── weather_screen.dart     # Halaman antarmuka Prakiraan Cuaca
│   └── earthquake_screen.dart  # Halaman antarmuka Peta & Info Gempa
├── services/
│   └── bmkg_service.dart       # Layanan HTTP request API, caching, & error handling
└── main.dart                   # Entry point aplikasi & konfigurasi tema Material 3
