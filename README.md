# Al Musarmon 💼

**Complete Shop Management System for Textile & Tailoring Business**

Al Musarmon is an offline-first Flutter application built for managing a textile/tailoring shop's complete operations — from customer accounts and inventory to sales, custom orders, suppliers, and workers. Designed specifically for shops dealing in fabric (thaan-based inventory) and custom-stitched garments.

---

## ✨ Features

### 📊 Dashboard
- Real-time overview of today's sales and total outstanding customer balances
- Low stock alerts for products running low
- Quick access to Profit/Loss and Date-wise sales reports

### 👥 Customer Management (Khata System)
- Add customers manually or import directly from phone contacts
- Track customer credit/debit transactions (udhaar system)
- Full transaction history per customer with running balance
- Color-coded balance indicators (red = owed, green = cleared)

### 📦 Product & Stock Management
- Thaan-based purchase entry — enter cost per roll (thaan), app calculates per-meter cost automatically
- Sale pricing per finished suit/top (not per meter) with quick-select price chips
- Automatic stock calculation based on number of thaans purchased
- Low stock threshold alerts

### 🛒 New Sale (POS)
- Quick product selection with "how many suits" input — automatically calculates meters and price
- Shopping cart interface with live total calculation
- Optional customer selection (or walk-in customer)
- Generates professional PDF receipts
- One-tap WhatsApp receipt/message delivery to customers

### 📝 Orders (Advance/Tailoring System)
- Manage custom tailoring orders with advance payment tracking
- Order status workflow: Pending → Ready → Delivered
- Automatic WhatsApp notification when order is marked ready
- Remaining balance automatically added to customer's account if not paid in full at delivery
- PDF advance payment receipts

### 🚚 Supplier Management
- Track goods received and payments made to suppliers
- Total received / Total paid / Net due breakdown (accurate regardless of entry order)
- Full supplier transaction history

### 👷 Worker Management
- Track work assigned and payments made to tailors/workers
- Pre-loaded with default worker names, expandable
- Total work / Total paid / Net due breakdown

### 📈 Reports & Analytics
- Profit/Loss report with product-wise breakdown
- Date-wise sales reports (Today / This Week / This Month / Custom range)
- Sales history with detailed item-level breakdown per transaction

### 💾 Backup & Restore
- One-tap backup export as a shareable ZIP file (via WhatsApp, Drive, etc.)
- Full data restore from backup file

### 🎨 Design
- Modern SaaS-style UI with gradient headers and card-based layouts
- Full Dark Mode support (toggle from Dashboard)
- Bilingual receipts and customer communication (English interface, Arabic customer-facing messages)
- Saudi Riyal (SAR) currency throughout

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **Database:** SQLite (via `sqflite`) — fully offline, no internet required
- **PDF Generation:** `pdf` + `printing` packages
- **Contacts Integration:** `flutter_contacts`
- **Messaging:** WhatsApp deep-linking via `url_launcher`
- **Backup:** `archive` (ZIP compression) + `share_plus` + `file_picker`

---

## 📁 Project Structure

lib/
├── main.dart
├── theme/              # Light/Dark theme controller
├── db/                 # SQLite database helper
├── models/             # Data models (Customer, Product, Order, etc.)
├── utils/              # Receipt generator, WhatsApp helper
└── screens/
├── home_screen.dart
├── customers/
├── products/
├── sales/
├── orders/
├── suppliers/
├── workers/
├── reports/
└── backup/

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android Studio / VS Code with Flutter extension
- An Android device or emulator

### Installation

```bash
git clone https://github.com/YOUR-USERNAME/al_musarmon.git
cd al_musarmon
flutter pub get
flutter run
```

### Building a Release APK

```bash
flutter build apk --release
```

The generated APK will be located at:

build/app/outputs/flutter-apk/app-release.apk

---

## 📱 Offline-First

Al Musarmon works entirely offline. All data is stored locally on the device using SQLite — no internet connection or backend server required for day-to-day operations. Internet is only used for optional WhatsApp message sharing.

---

## 👤 Developed For

Shahid Sahab's Textile Business — a shop management solution tailored to real-world workflows: thaan-based fabric purchasing, per-suit pricing, advance payment tailoring orders, and worker/supplier ledger tracking.

---

## 📄 License

This is a private project built for personal business use.
