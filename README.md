# Smart Point of Sale (SPOS) & ERP Ecosystem | Full-Stack & Mobile Monorepo

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18-61DAFB?style=flat&logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=flat&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3-06B6D4?style=flat&logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Shadcn UI](https://img.shields.io/badge/Shadcn_UI-Latest-000000?style=flat&logo=shadcnui&logoColor=white)](https://ui.shadcn.com)
[![Django](https://img.shields.io/badge/Django-5.x-092E20?style=flat&logo=django&logoColor=white)](https://www.djangoproject.com)
[![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org)

Omnichannel Point of Sale (POS), real-time inventory tracking, delivery logistics, and sales analytics platform.

---

## 🏛️ Architecture Overview

The platform coordinates multi-device retail operations across three dedicated layers:

```text
spos/
├── mobile/            # Mobile & Tablet POS Client (Flutter / Dart)
│   ├── lib/
│   │   ├── screens/   # Catalog, Cart, Checkout, Order Tracking
│   │   ├── services/  # REST API integration & synchronization
│   │   └── utils/     # Cart management & offline-ready state
│   └── pubspec.yaml   # Flutter cross-platform configuration
│
├── web/               # Central Back-Office ERP Console (React + Vite + Shadcn)
│   ├── src/
│   │   ├── modules/   # Sales, Cash register control, Inventory, Customers
│   │   ├── components/# Shadcn UI data grids, dialogs, charts
│   │   └── routes/    # Protected administrative routing
│   └── vite.config.ts # Modern build toolchain
│
├── backend/           # Core Retail & Transaction Engine (Django REST Framework)
│   ├── inventory/     # Stock management, categorizations, and photo storage
│   ├── sale/          # Cash register sessions, shift closures, line transactions
│   ├── order/         # Order orchestration, kitchen/fulfillment routing
│   ├── delivery/      # GPS-enabled courier routing & delivery addresses
│   ├── payment/       # Payment gateway integrations (VeriPagos, QR, Cash)
│   ├── user/          # User management, customer recommendations & auth
│   └── manage.py      # Management scripts
│
└── README.md          # Platform documentation
```

---

## ⚡ Key Capabilities

- **Cash Register Control:** Shift open/close sessions, audit trails, and reconciliation.
- **Inventory Management:** Stock levels, categories, pricing, and product catalogs.
- **Omnichannel Ordering:** Online customer catalog + in-store POS register synchronized to one central stock engine.
- **Delivery Tracking:** Customer delivery addresses with coordinates and driver assignment.
- **Payment Processing:** Support for cash, card, and QR payment gateways.

---

## 🚀 Getting Started

### Backend Setup (Django)

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### Web Back-Office Setup (React + Vite)

```bash
cd web
npm install
npm run dev
# Running on http://localhost:5173
```

### Mobile / POS Client Setup (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## 👤 Author

Architected and developed by **María Ilse Romero Saavedra** ([@miromero13](https://github.com/miromero13)).
