# Setup Setelah Clone dari GitHub

Setelah clone repository ini, Anda perlu melakukan beberapa konfigurasi untuk menjalankan aplikasi:

## 1. Firebase Configuration

### Android
1. Buat project Firebase baru di [Firebase Console](https://console.firebase.google.com/)
2. Tambahkan aplikasi Android dengan package name: `com.kopikita.rtoedz`
3. Download file `google-services.json`
4. Letakkan file tersebut di: `android/app/google-services.json`

### iOS (Opsional)
1. Tambahkan aplikasi iOS di Firebase Console
2. Download file `GoogleService-Info.plist`
3. Letakkan file tersebut di: `ios/Runner/GoogleService-Info.plist`

## 2. Generate Firebase Options

Jalankan perintah berikut untuk generate `firebase_options.dart`:

```bash
flutter pub get
flutter pub global activate flutterfire_cli
flutterfire configure
```

## 3. Android Local Properties

Buat file `android/local.properties` dengan isi:

```properties
sdk.dir=PATH_TO_YOUR_ANDROID_SDK
flutter.sdk=PATH_TO_YOUR_FLUTTER_SDK
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

## 4. Firebase Services Setup

Di Firebase Console, aktifkan:
- **Authentication** (Email/Password)
- **Firestore Database**
- **Storage**

### Firestore Rules
Gunakan rules yang ada di file `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

## 5. Default User

Setelah setup, aplikasi akan otomatis membuat user default:
- Email: `admin@kopikita.com`
- Password: `admin123`
- Role: `admin`

## 6. Install Dependencies

```bash
flutter pub get
```

## 7. Run Application

```bash
flutter run
```

## File-file yang TIDAK di-commit ke GitHub

Untuk keamanan, file-file berikut tidak di-commit:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `android/local.properties`
- File keystore (`.jks`)
- File environment variables (`.env`)

## Troubleshooting

1. **Build Error**: Pastikan semua file konfigurasi sudah ada
2. **Firebase Error**: Periksa konfigurasi Firebase dan rules
3. **Permission Error**: Pastikan Firestore rules sudah di-deploy

## Kontak

Jika ada masalah dalam setup, silakan buat issue di repository ini.