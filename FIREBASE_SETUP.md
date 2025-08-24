# Firebase Setup Instructions

## Firestore Security Rules Setup

Untuk mengatasi error `PERMISSION_DENIED` di Firestore, ikuti langkah-langkah berikut:

### 1. Melalui Firebase Console (Recommended)

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih proyek Firebase Anda
3. Navigasi ke **Firestore Database** > **Rules**
4. Ganti rules yang ada dengan kode berikut:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Allow read/write access to users collection for initialization
    match /users/{userId} {
      allow read, write: if true;
    }
    
    // Allow read/write access to products collection for initialization
    match /products/{productId} {
      allow read, write: if true;
    }
    
    // Allow read/write access to transactions collection
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Klik **Publish** untuk menerapkan rules

### 2. Melalui Firebase CLI (Alternative)

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login ke Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase di proyek:
   ```bash
   firebase init firestore
   ```

4. Deploy rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

## Authentication Setup

Pastikan Firebase Authentication sudah diaktifkan:

1. Di Firebase Console, navigasi ke **Authentication**
2. Pilih tab **Sign-in method**
3. Aktifkan **Email/Password** provider
4. Klik **Save**

## Testing

Setelah mengatur rules, restart aplikasi Flutter:

```bash
flutter run
```

Aplikasi seharusnya dapat:
- Membuat user default (admin@kopikita.com)
- Membuat produk default (Cappuccino, Latte)
- Login dengan kredensial default

## Default Credentials

- **Admin**: admin@kopikita.com / admin123
- **Kasir**: kasir@kopikita.com / kasir123

## Troubleshooting

Jika masih ada error:

1. Pastikan `google-services.json` sudah benar
2. Periksa koneksi internet
3. Restart aplikasi setelah mengubah rules
4. Periksa Firebase Console untuk error logs

## Security Note

Rules di atas dibuat untuk development. Untuk production, gunakan rules yang lebih restrictive:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are read-only for authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Transactions belong to authenticated users
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```