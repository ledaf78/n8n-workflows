# n8n Workflows

Repository ini berisi dokumentasi automation n8n internal.

## Struktur Direktori

```
workflow/
├── README.md
│
├── Automated-Incident-Remediation-Service-Restart/
│   ├── configs/            # Detail konfigurasi tiap node (.yaml)
│   ├── docs/                # Dokumentasi naratif workflow (.md)
│   ├── workflows/           # Export asli (.json) dari n8n
│   ├── .env.example         # Daftar environment variable yang dibutuhkan
│   └── .gitignore
│
└── Server-Decommissioning/
    ├── configs/
    ├── docs/
    ├── workflows/
    ├── .env.example
    └── .gitignore
```

## Cara Import Workflow ke n8n

1. Buka instance n8n Anda.
2. Klik **Workflows** → **Add Workflow** → **Import from File**.
3. Pilih file `.json` yang sesuai dari folder `workflows/`.
4. Setelah import, buka setiap node yang membutuhkan credential (misalnya HTTP Request, Slack, Google Sheets) dan **hubungkan ulang credential-nya secara manual** — credential tidak ikut ter-export demi keamanan.
5. Cek variabel di `.env.example` dan pastikan sudah tersedia di environment n8n Anda (Settings → Variables, atau file `.env` instance n8n).
6. Jalankan workflow dalam mode **test** terlebih dahulu sebelum mengaktifkan trigger produksi.

## Konvensi Penamaan

- File workflow: `workflow-<nama-singkat>.json`
- File dokumentasi: `docs/<nama-file-workflow-tanpa-ekstensi>.md`
- File config node: `configs/<nama-workflow>/node-<tipe-node>-<label>.yaml`

## Keamanan & Credential

 **Jangan pernah commit credential asli** (API key, token, password) ke repository ini, meskipun repo bersifat private.
- Semua referensi credential di dokumentasi menggunakan **nama saja**, bukan value.
- Gunakan `.env.example` sebagai referensi variabel yang perlu diisi di environment n8n masing-masing.
- Sebelum export/push workflow baru, periksa isi JSON untuk memastikan tidak ada data sensitif yang ikut terbawa.

## Cara Kontribusi / Update

1. Export ulang workflow dari n8n setelah ada perubahan.
2. Timpa file `.json` yang sesuai di folder `workflows/`.
3. Update dokumentasi terkait di `docs/` dan `configs/` jika ada perubahan node/parameter.
4. Commit dengan pesan yang jelas, contoh: `update: tambah node filter di workflow-nama-a`.

## Lisensi / Penggunaan Internal

Repository ini untuk keperluan internal tim.