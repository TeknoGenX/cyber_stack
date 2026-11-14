# Presentasi Proyek: Cyber Stack - Neon Drop

> **Format:** bahan presentasi berbasis Markdown  
> **Durasi yang disarankan:** 5–7 menit  
> **Status:** prototipe game arcade yang dapat dimainkan

---

## Slide 1 — Cyber Stack - Neon Drop

### Game arcade stacking dengan Flutter dan Flame

- Mulai permainan dengan tap, lalu hentikan balok bergerak dengan tap berikutnya.
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

1. Tap pertama memulai game; balok pertama mulai bergerak dari atas balok dasar.
2. Tap berikutnya menghentikan balok yang sedang bergerak.
3. Sistem menghitung irisan horizontal balok dengan lapisan di bawahnya.
4. Jika ada irisan, balok dipotong menjadi selebar bagian yang bertumpuk dan
   skor dasar bertambah satu.
5. Penempatan di tengah dalam toleransi 3 piksel meningkatkan combo; setiap
   level combo memberi bonus poin sebesar level tersebut.
6. Penempatan yang tidak sempurna mereset combo.
7. Balok berikutnya bergerak dari arah berlawanan.
8. Jika tidak ada irisan atau tumpukan mencapai batas atas, permainan berakhir.

Kecepatan dimulai dari **200** dan bertambah **15** pada setiap penempatan
berhasil, hingga maksimum **600**.

---

## Slide 4 — Alur Pemain

```text
Mulai
  ↓
Tap pertama: mulai game
  ↓
Balok bergerak
  ↓
Pemain melakukan tap untuk menghentikan balok
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
- Skor tertinggi tersimpan secara lokal dan tampil di bawah skor saat ini.
- Tombol di kanan atas menjeda dan melanjutkan permainan.
- Efek audio membedakan penempatan biasa, combo, dan game over.
- Suara dapat dimatikan atau diaktifkan; preferensinya tersimpan secara lokal.
- Pesan **GAME OVER** muncul saat permainan selesai.
- Tap lagi setelah game over untuk memulai ulang.
- Ukuran awal balok dan batas gerak mengikuti ukuran viewport.

---

## Slide 6 — Arsitektur Aplikasi

- **`lib/main.dart`** — entry point Flutter, tema aplikasi, dan pemasangan
  `GameWidget`, serta kontrol jeda dan suara.
- **`lib/games/cyber_stack_game.dart`** — game loop, pergerakan, input tap,
  pemotongan balok, skor, dan kondisi game over.
- **`lib/audio/game_sound_effects.dart`** — pemuatan dan pemutaran efek suara.
- **`lib/storage/`** — penyimpanan lokal skor tertinggi dan preferensi suara
  menggunakan Hive.
- **`test/cyber_stack_test.dart`** — pengujian pemuatan komponen dan mekanika
  permainan, penyimpanan, audio, serta kontrol.

Flutter menangani aplikasi dan widget; Flame menangani komponen serta siklus
permainan. Lapisan audio dan penyimpanan dipisahkan agar mudah diuji.

---

## Slide 7 — Teknologi

| Teknologi | Peran |
|---|---|
| Flutter 3.50.0 | Framework aplikasi |
| Dart 3.14.0 | Bahasa pemrograman |
| Flame 1.38.2 | Engine game 2D; constraint proyek `^1.18.0` |
| Flame Audio 2.12.2 | Pemutaran efek suara |
| Material UI 1.11.0 | Komponen dan tema antarmuka |
| Hive | Penyimpanan lokal untuk skor tertinggi dan preferensi suara |

---

## Slide 8 — Pengujian dan Status

Lima belas pengujian mencakup:

- Game dan teks skor berhasil dimuat.
- Tap pertama memulai game tanpa memicu game over.
- Penempatan sebagian memotong balok dan menambah skor.
- Balok yang meleset mengakhiri permainan.
- Delta waktu dibatasi dan kecepatan memiliki batas maksimum.
- Balok tetap berada di dalam viewport sempit.
- Perubahan ukuran viewport tidak mengakhiri permainan.
- Tap setelah game over memulai ulang permainan.
- Skor tertinggi dimuat dan disimpan untuk permainan berikutnya.
- Penyimpanan Hive mempertahankan skor tertinggi.
- Tombol jeda menghentikan dan melanjutkan gerakan permainan.
- Penempatan presisi meningkatkan bonus combo; penempatan sebagian meresetnya.
- Efek suara dipicu untuk penempatan, combo, dan game over.
- Tombol suara mematikan audio dan menyimpan preferensinya.
- Tumpukan yang mencapai bagian atas mengakhiri permainan.

**Hasil verifikasi saat ini:** `flutter test` lulus (15 pengujian) dan
`flutter analyze` tidak menemukan masalah. Build Web berhasil pada validasi
sebelumnya. Build Linux belum diverifikasi karena GStreamer development files
tidak tersedia di lingkungan validasi sebelumnya.

---

## Slide 9 — Batasan dan Pengembangan Berikutnya

### Batasan saat ini

- Belum ada animasi tambahan atau sistem level.
- Build Android belum diverifikasi dalam validasi terakhir.

### Usulan pengembangan

1. Tambahkan animasi untuk penempatan sukses/gagal.
2. Uji layout dan kontrol pada beberapa perangkat Android serta ukuran layar.

---

## Slide 10 — Demo

Jalankan versi Linux:

```sh
flutter run -d linux
```

### Urutan demo

1. Tunjukkan instruksi mulai dan skor awal.
2. Tap untuk memulai, lalu tap untuk menempatkan balok dengan irisan sebagian.
3. Tunjukkan lebar balok berkurang dan skor bertambah.
4. Biarkan balok meleset untuk memperlihatkan kondisi game over.
5. Tap lagi untuk memperlihatkan game dimulai ulang.

---

## Slide 11 — Penutup

Cyber Stack - Neon Drop sudah memiliki fondasi game loop arcade: input satu
tap, stacking dengan pemotongan, peningkatan kecepatan, batas viewport, dan
kondisi game over.

**Fokus tahap berikutnya:** meningkatkan replayability melalui umpan balik
visual dan pengujian pada perangkat target.

### Terima kasih

**Pertanyaan dan diskusi**
