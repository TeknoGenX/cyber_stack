# Presentasi Proyek: Cyber Stack - Neon Drop

> **Format:** bahan presentasi berbasis Markdown  
> **Durasi yang disarankan:** 5–7 menit  
> **Status:** prototipe game arcade yang dapat dimainkan

---

## Slide 1 — Cyber Stack - Neon Drop

### Game arcade stacking dengan Flutter dan Flame

- Hentikan balok bergerak dengan satu tap.
- Susun balok setepat mungkin sebelum tumpukan mencapai bagian atas layar.
- Setiap penempatan yang berhasil membuat permainan lebih menantang.

**Narasi:** Cyber Stack adalah prototipe game arcade yang menguji timing dan
presisi pemain melalui mekanika penumpukan balok sederhana.

---

## Slide 2 — Konsep Permainan

- Pemain melihat balok bergerak horizontal di atas tumpukan.
- Pemain melakukan tap untuk menghentikan balok.
- Bagian balok yang bertumpuk dengan balok sebelumnya menjadi lapisan baru.
- Lebar lapisan berkurang jika penempatannya hanya sebagian tepat.

**Tujuan pemain:** mempertahankan tumpukan selama mungkin dan memperoleh skor
setinggi mungkin.

---

## Slide 3 — Aturan dan Kondisi Game Over

1. Tap menghentikan balok yang sedang bergerak.
2. Sistem menghitung irisan horizontal balok dengan lapisan di bawahnya.
3. Jika ada irisan, balok dipotong menjadi selebar bagian yang bertumpuk dan
   skor bertambah satu.
4. Balok berikutnya bergerak dari arah berlawanan.
5. Jika tidak ada irisan atau tumpukan mencapai batas atas, permainan berakhir.

Kecepatan dimulai dari **200** dan bertambah **15** pada setiap penempatan
berhasil, hingga maksimum **600**.

---

## Slide 4 — Alur Pemain

```text
Mulai
  ↓
Balok bergerak
  ↓
Pemain melakukan tap
  ↓
Hitung irisan dengan balok di bawah
  ├─ Tidak ada irisan → Game Over
  └─ Ada irisan → Potong balok, tambah skor, naikkan kecepatan
                         ↓
                    Balok berikutnya
```

Alur ini berulang sampai pemain gagal menumpuk atau ruang vertikal habis.

---

## Slide 5 — Antarmuka dan Respons

- Gaya visual menggunakan tema gelap dan aksen neon.
- Balok dasar berwarna sian; balok bergerak berwarna ungu.
- Skor tampil di bagian atas layar.
- Pesan **GAME OVER** muncul saat permainan selesai.
- Ukuran awal balok dan batas gerak mengikuti ukuran viewport.

---

## Slide 6 — Arsitektur Aplikasi

- **`lib/main.dart`** — entry point Flutter, tema aplikasi, dan pemasangan
  `GameWidget`.
- **`lib/games/cyber_stack_game.dart`** — game loop, pergerakan, input tap,
  pemotongan balok, skor, dan kondisi game over.
- **`test/cyber_stack_test.dart`** — pengujian pemuatan komponen dan mekanika
  permainan.

Flutter menangani aplikasi dan widget; Flame menangani komponen serta siklus
permainan.

---

## Slide 7 — Teknologi

| Teknologi | Peran |
|---|---|
| Flutter 3.50.0 | Framework aplikasi |
| Dart 3.14.0 | Bahasa pemrograman |
| Flame 1.38.2 | Engine game 2D; constraint proyek `^1.18.0` |
| Material UI 1.11.0 | Komponen dan tema antarmuka |
| Hive | Dependency local storage; belum digunakan untuk menyimpan skor |

---

## Slide 8 — Pengujian dan Status

Enam pengujian widget mencakup:

- Game dan teks skor berhasil dimuat.
- Penempatan sebagian memotong balok dan menambah skor.
- Balok yang meleset mengakhiri permainan.
- Delta waktu dibatasi dan kecepatan memiliki batas maksimum.
- Balok tetap berada di dalam viewport sempit.
- Tumpukan yang mencapai bagian atas mengakhiri permainan.

**Hasil verifikasi terakhir:** `flutter test` lulus, `flutter analyze` tidak
menemukan masalah, dan build Linux debug berhasil.

---

## Slide 9 — Batasan dan Pengembangan Berikutnya

### Batasan saat ini

- Belum ada tombol mulai ulang setelah game over.
- Skor tertinggi belum disimpan; Hive belum diintegrasikan.
- Belum ada efek suara, animasi tambahan, atau sistem level.
- Build Android belum diverifikasi dalam validasi terakhir.

### Usulan pengembangan

1. Tambahkan aksi restart dan alur mulai ulang yang jelas.
2. Integrasikan Hive untuk menyimpan skor tertinggi.
3. Tambahkan umpan balik audio dan visual untuk penempatan sukses/gagal.
4. Uji layout dan kontrol pada beberapa perangkat Android serta ukuran layar.

---

## Slide 10 — Demo

Jalankan versi Linux:

```sh
flutter run -d linux
```

### Urutan demo

1. Tunjukkan balok bergerak dan skor awal.
2. Tap untuk menempatkan balok dengan irisan sebagian.
3. Tunjukkan lebar balok berkurang dan skor bertambah.
4. Biarkan balok meleset untuk memperlihatkan kondisi game over.

---

## Slide 11 — Penutup

Cyber Stack - Neon Drop sudah memiliki fondasi game loop arcade: input satu
tap, stacking dengan pemotongan, peningkatan kecepatan, batas viewport, dan
kondisi game over.

**Fokus tahap berikutnya:** meningkatkan replayability melalui restart,
penyimpanan skor, dan pengujian pada perangkat target.

### Terima kasih

**Pertanyaan dan diskusi**
