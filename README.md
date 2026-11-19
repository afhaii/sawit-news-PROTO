# SawitNews — Flutter News App

Aplikasi berita Indonesia bernama SawitNews untuk tugas mandiri Pemrograman Mobile. Aplikasi mengambil berita asli dari GNews API, menggunakan Dio untuk HTTP request, GetX hanya untuk routing, dan FutureBuilder untuk menampilkan hasil request.

## Arah desain UI

Versi ini memakai tampilan clean dan minimalis dengan referensi visual yang diberikan:

- Latar off-white dan aksen lavender lembut.
- Header ringkas dengan identitas SawitNews dan tombol pencarian berbentuk lingkaran.
- Pilihan kategori berbentuk pill.
- Berita pertama ditampilkan sebagai kartu utama dengan foto dan judul di atas gradient.
- Berita berikutnya memakai kartu horizontal yang lebih ringkas.
- Halaman hasil pencarian dan detail mengikuti palet, radius, dan tipografi yang sama.
- Tidak ada tombol navigasi dekoratif yang tidak memiliki fungsi.

## Fitur aplikasi

- Daftar berita dari GNews `/top-headlines`.
- Pilihan kategori: Teknologi, Sains, Bisnis, Umum, Nasional, dan Olahraga.
- Cache `Map<String, Future<List<ArticleModel>>>` per kategori agar kembali ke kategori yang pernah dibuka tidak membuat request baru.
- Pencarian berita melalui IconButton di header. Tombol membuka dialog, lalu hasil `searchNews()` ditampilkan pada halaman pencarian dengan FutureBuilder.
- Halaman detail artikel.
- Pull-to-refresh pada daftar berita dan hasil pencarian.
- Empat state FutureBuilder: loading, error, kosong, dan data.
- `ApiException` dengan beberapa pesan berbeda untuk konfigurasi kosong, koneksi terputus, timeout, API key salah, akses/kuota ditolak, endpoint salah, rate limit, server bermasalah, dan format data tidak sesuai.
- Tombol **Coba Lagi** pada tampilan error.
- API key disimpan melalui `--dart-define-from-file` dan file lokalnya dikecualikan dari Git.

## 1. Persiapan proyek

Jika belum memiliki proyek Flutter, buat terlebih dahulu:

```bash
flutter create tekno_news
```

Salin/merge isi folder paket ini ke dalam folder proyek `tekno_news` (folder `lib`, `config`, `.vscode`, `.gitignore`, `pubspec.yaml`, dan `README.md`). Pilih untuk mengganti file source yang diminta.

Jika proyek sudah dibuat tetapi belum memiliki platform web/Windows, jalankan dari root proyek:

```bash
flutter create .
```

Kemudian:

```bash
flutter pub get
```

## 2. Siapkan API key GNews

1. Daftar di https://gnews.io/ dan verifikasi email.
2. Salin API key dari dashboard GNews.
3. Duplikat `config/env.example.json` dan beri nama `config/env.json`.
4. Isi API key milik sendiri. Jangan mengunggah `config/env.json` ke GitHub.

Contoh isi lokal `config/env.json`:

```json
{
  "GNEWS_BASE_URL": "https://gnews.io/api/v4",
  "GNEWS_API_KEY": "ISI_API_KEY_ASLI_DI_SINI"
}
```

Jalankan aplikasi di Chrome:

```bash
flutter run -d chrome --dart-define-from-file=config/env.json
```

Atau jalankan pada perangkat/emulator Android:

```bash
flutter run --dart-define-from-file=config/env.json
```


Konfigurasi VS Code juga tersedia di `.vscode/launch.json`.

## 3. Nama aplikasi

Nama yang tampil di dalam aplikasi adalah **SawitNews**. Jika ingin nama yang sama tampil pada ikon aplikasi Android dan tab browser, sesuaikan file platform yang dibuat oleh `flutter create .`:

- **Android:** pada `android/app/src/main/AndroidManifest.xml`, ubah atribut menjadi `android:label="SawitNews"` pada tag `<application>`.
- **Flutter Web:** pada `web/index.html`, ubah isi tag `<title>` menjadi `SawitNews`. Pada `web/manifest.json`, ubah `name` dan `short_name` menjadi `SawitNews`.

Nama paket internal `tekno_news` sengaja dipertahankan agar cocok dengan proyek lokal yang sudah dibuat sebelumnya. Ini tidak mengubah nama aplikasi yang terlihat oleh pengguna.

> Catatan keamanan: cara `dart-define` ini mengikuti materi untuk development/tugas. API key masih dapat diekstrak dari aplikasi yang sudah dibuild. Jangan memakai konfigurasi ini untuk aplikasi production publik; gunakan proxy server seperti skema pada bagian 10 PDF materi.

## 4. Struktur folder

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
│   ├── featured_article_card.dart
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

## 5. Skenario uji error untuk screenshot tugas

Dua skenario yang mudah dibuktikan:

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

Skenario tambahan:

| Skenario | Cara menguji | Pesan yang diharapkan |
|---|---|---|
| Konfigurasi kosong | Jalankan tanpa `--dart-define-from-file` | Konfigurasi belum diisi |
| API key salah | Pakai API key tidak terdaftar | API key salah/tidak terdaftar (401) |
| Tidak ada internet | Putuskan koneksi | Tidak ada koneksi internet |
| Endpoint salah | Ubah path endpoint saat pengujian service | Endpoint tidak ditemukan (404) |
| Terlalu banyak request | Kirim request terlalu cepat | Rate limit (429) |
| Server bermasalah | Respons server 5xx | Server GNews sedang bermasalah |

**Penting:** setelah mengambil screenshot, pulihkan API key asli, koneksi internet, dan semua kode yang sempat diubah. Jangan commit API key.

## 6. Push ke GitHub

Buat repository baru di akun GitHub sendiri, misalnya `sawit-news-flutter`. Pastikan `config/env.json` tidak ikut terpilih. Dari terminal folder proyek:

```bash
git init
git add .
git commit -m "SawitNews Flutter - clean UI"
git branch -M main
git remote add origin https://github.com/USERNAME/sawit-news-flutter.git
git push -u origin main
```

Ganti `USERNAME` dengan username GitHub sendiri. Link yang dikumpulkan adalah URL repository yang benar-benar sudah dibuat dan berhasil di-push.

## 7. Catatan penggunaan API

- API menggunakan `https://gnews.io/api/v4`.
- Request mengirim parameter `lang=id`, `country=id`, dan `max=10`.
- Paket gratis GNews memiliki batas request harian dan pembatasan kecepatan. Cache kategori dipakai untuk mengurangi request berulang.
- Berita pada paket gratis dapat mengalami keterlambatan publikasi. Data aktual yang tampil tergantung respons GNews dan API key masing-masing.
