# TeknoNews Indonesia — Flutter News App

Aplikasi berita bertema teknologi Indonesia untuk tugas mandiri Pemrograman Mobile. Aplikasi mengambil berita asli dari GNews API, menggunakan Dio untuk HTTP request, GetX hanya untuk routing, dan FutureBuilder untuk menampilkan hasil request.

## Fitur yang sudah disiapkan

- Daftar berita dari GNews `/top-headlines`.
- Pilihan kategori: Teknologi, Sains, Bisnis, Umum, Nasional, dan Olahraga.
- Cache `Map<String, Future<List<ArticleModel>>>` per kategori agar kembali ke kategori yang pernah dibuka tidak membuat request baru.
- Pencarian berita melalui IconButton di AppBar. Tombol membuka dialog, lalu hasil `searchNews()` ditampilkan pada halaman pencarian dengan FutureBuilder.
- Halaman detail artikel.
- Pull-to-refresh pada daftar berita dan hasil pencarian.
- Empat state FutureBuilder: loading, error, kosong, dan data.
- `ApiException` dengan beberapa pesan yang berbeda untuk konfigurasi kosong, koneksi terputus, timeout, API key salah, akses/kuota ditolak, endpoint salah, rate limit, server bermasalah, dan format data tidak sesuai.
- Tombol **Coba Lagi** pada tampilan error.
- API key disimpan melalui `--dart-define-from-file` dan file lokalnya dikecualikan dari Git.

## 1. Buat proyek Flutter

Pastikan Flutter SDK dan Android Studio/VS Code sudah terpasang. Buat proyek baru:

```bash
flutter create tekno_news
```

Salin/merge isi folder paket ini ke dalam folder proyek `tekno_news` (folder `lib`, `config`, `.vscode`, `.gitignore`, `pubspec.yaml`, dan `README.md`). Jika sistem bertanya apakah `pubspec.yaml` atau file `lib` ingin ditimpa, pilih untuk mengganti dengan versi dari paket ini.

Kemudian buka terminal pada folder proyek dan jalankan:

```bash
flutter pub get
```

## 2. Siapkan API key GNews

1. Daftar di https://gnews.io/ dan verifikasi email.
2. Salin API key dari dashboard GNews.
3. Duplikat `config/env.example.json` dan beri nama `config/env.json`.
4. Isi `GNEWS_API_KEY` dengan API key milik sendiri. Jangan mengunggah `config/env.json` ke GitHub.

Contoh isi lokal `config/env.json`:

```json
{
  "GNEWS_BASE_URL": "https://gnews.io/api/v4",
  "GNEWS_API_KEY": "ISI_API_KEY_ASLI_DI_SINI"
}
```

Jalankan aplikasi:

```bash
flutter run --dart-define-from-file=config/env.json
```

Untuk Flutter Web:

```bash
flutter run -d chrome --dart-define-from-file=config/env.json
```

Konfigurasi VS Code juga tersedia di `.vscode/launch.json`.

> Catatan keamanan: cara `dart-define` ini mengikuti materi untuk development/tugas. API key masih dapat diekstrak dari aplikasi yang sudah dibuild. Jangan memakai konfigurasi ini untuk aplikasi production publik; gunakan proxy server seperti skema pada bagian 10 PDF materi.

## 3. Struktur folder

```text
lib/
├── main.dart
├── config/
│   └── env.dart
├── models/
│   ├── article_model.dart
│   └── news_response_model.dart
├── services/
│   ├── api_exception.dart
│   └── news_api_service.dart
├── views/
│   ├── home_view.dart
│   ├── search_view.dart
│   └── detail_view.dart
├── widgets/
│   ├── article_card.dart
│   ├── error_view.dart
│   └── news_image.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
└── utils/
    ├── app_colors.dart
    └── date_formatter.dart

config/
└── env.example.json
```

## 4. Skenario uji error untuk screenshot tugas

Ambil screenshot layar aplikasi yang menampilkan pesan error, bukan hanya screenshot terminal. Dua skenario yang mudah dibuktikan:

### Screenshot 1 — API key salah (HTTP 401)

1. Tutup aplikasi.
2. Pada `config/env.json`, ubah `GNEWS_API_KEY` sementara menjadi 32 angka nol:
   `00000000000000000000000000000000`.
3. Jalankan kembali aplikasi dengan perintah run di atas.
4. Tunggu sampai FutureBuilder menampilkan error **“API key GNews salah atau tidak terdaftar.”**
5. Ambil screenshot layar tersebut.

### Screenshot 2 — Tidak ada koneksi internet

1. Kembalikan API key asli pada `config/env.json`.
2. Putuskan koneksi internet. Jika menggunakan Chrome: buka DevTools → Network → pilih **Offline**. Jika menggunakan emulator Android: aktifkan Airplane Mode.
3. Muat ulang aplikasi atau tekan tombol Coba Lagi.
4. FutureBuilder seharusnya menampilkan **“Tidak ada koneksi internet. Periksa jaringan Anda.”**
5. Ambil screenshot layar tersebut, lalu aktifkan internet kembali.

Skenario tambahan yang dapat dicoba:

| Skenario | Cara menguji | Pesan yang diharapkan |
|---|---|---|
| Konfigurasi kosong | Jalankan tanpa `--dart-define-from-file` | Konfigurasi belum diisi |
| API key salah | Pakai API key tidak terdaftar | API key GNews salah atau tidak terdaftar (401) |
| Email belum diverifikasi / kuota ditolak | Gunakan akun yang belum terverifikasi atau kuota ditolak | Akses ditolak (403) |
| Terlalu banyak request | Kirim beberapa request dalam waktu sangat dekat | Rate limit (429) |
| Kata kunci tidak valid | Panggil pencarian dengan teks kosong dari kode | Kata kunci pencarian tidak boleh kosong |
| Endpoint salah | Ubah path endpoint saat pengujian service | Endpoint tidak ditemukan (404) |
| Timeout | Atur receive timeout sangat kecil saat pengujian | Koneksi terlalu lambat |
| JSON tidak sesuai | Ubah struktur parsing sementara | Struktur data tidak sesuai format/model |

**Penting:** setelah mengambil screenshot, pulihkan API key asli, koneksi internet, dan semua kode yang sempat diubah. Jangan commit API key.

## 5. Push ke GitHub

Buat repository baru di akun GitHub sendiri, misalnya `tekno-news-flutter`. Pastikan `config/env.json` tidak ikut terpilih. Dari terminal folder proyek:

```bash
git init
git add .
git commit -m "Initial commit - TeknoNews Flutter"
git branch -M main
git remote add origin https://github.com/USERNAME/tekno-news-flutter.git
git push -u origin main
```

Ganti `USERNAME` dengan username GitHub sendiri. Link yang dikumpulkan adalah URL repository yang benar-benar sudah dibuat dan berhasil di-push.

## 6. Catatan penggunaan API

- API menggunakan `https://gnews.io/api/v4`.
- Request mengirim parameter `lang=id`, `country=id`, dan `max=10`.
- Paket gratis GNews memiliki batas request harian dan pembatasan kecepatan. Karena itu cache kategori dipakai untuk mengurangi request berulang.
- Berita pada paket gratis dapat mengalami keterlambatan publikasi. Data aktual yang tampil tergantung respons GNews dan API key masing-masing.
