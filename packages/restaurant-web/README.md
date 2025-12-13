# Restaurant Owner Web App

## 🏢 Overview

Web application for restaurant owners to manage their business on Zhigo platform.

## ✨ Features

- Restaurant dashboard
- Menu management (add, edit, delete items)
- Order management
- Hours configuration
- Review management
- Analytics

## 🚀 Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3003](http://localhost:3003)

## 📁 Structure

```
restaurant-web/
├── app/
│   ├── page.tsx              # Dashboard
│   ├── menu/                 # Menu management
│   ├── orders/               # Order management
│   ├── hours/                # Opening hours
│   └── reviews/              # Customer reviews
└── components/               # Restaurant-specific components
```

## 🔧 Environment Variables

Create `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## 📊 Pages

- `/` - Restaurant dashboard
- `/menu` - Menu management
- `/orders` - Order management
- `/hours` - Opening hours configuration
- `/reviews` - Customer reviews

## 🎨 Components

Reuses components from `shared-ui`:
- PartnerOnboarding
- RestaurantDashboard
- MenuManagement
- HoursManager
- OrderManager
- ReviewManager

---

**Port:** 3003
**Role:** Restaurant Owner
