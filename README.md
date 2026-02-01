# School Logistics Management System

A modern, full-stack school logistics management application for tracking inventory, managing requests, and generating reports.

## 🎯 Features

- **Role-Based Access Control**: Admin, Storekeeper, and Teacher roles
- **Inventory Management**: Track items, stock levels, and categories
- **Request Workflow**: Teachers request items, admins approve/reject
- **Modern UI**: Clean, responsive dashboard with Tailwind CSS & Shadcn/UI
- **Real-time Updates**: Live inventory and request status tracking

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Git (optional)

### Backend Setup

```bash
cd backend
npm install
npx prisma migrate dev --name init
npm run dev
```

Backend will run on `http://localhost:5000`

**Default Admin Credentials:**
- Email: `admin@school.com`
- Password: `admin123`

### Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

Frontend will run on `http://localhost:3000`

## 📁 Project Structure

```
school_logistics/
├── backend/
│   ├── src/
│   │   ├── controllers/   # Business logic
│   │   ├── routes/        # API endpoints
│   │   └── middleware/    # Auth & error handling
│   ├── prisma/
│   │   ├── schema.prisma  # Database schema
│   │   └── seed.ts        # Initial data
│   └── .env               # Environment variables
│
└── frontend/
    ├── app/
    │   ├── dashboard/     # Protected dashboard pages
    │   └── page.tsx       # Login page
    ├── components/        # Reusable UI components
    └── lib/               # Utilities & API client
```

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - Create user (admin only)

### Inventory
- `GET /api/inventory` - List all items
- `POST /api/inventory` - Create item (admin/storekeeper)
- `PATCH /api/inventory/:id/stock` - Update stock

### Requests
- `POST /api/requests` - Create request (teacher)
- `PATCH /api/requests/:id/status` - Approve/reject (admin)

## 🎨 Tech Stack

**Backend:**
- Node.js + Express
- Prisma ORM + SQLite
- JWT Authentication
- TypeScript

**Frontend:**
- Next.js 14 (App Router)
- React + TypeScript
- Tailwind CSS
- Shadcn/UI Components

## 📝 Usage

1. **Login** with admin credentials
2. **Navigate** using the sidebar menu
3. **View Inventory** to see all items
4. **Manage Requests** for item approvals
5. **Dashboard** shows quick stats overview

## 🔧 Development

- Backend auto-reloads with `nodemon`
- Frontend has hot-reload via Next.js
- Database changes? Run `npx prisma migrate dev`

## 🚢 Deployment

### Backend
- Deploy to Render, Railway, or any Node.js host
- Set `DATABASE_URL` to PostgreSQL/MySQL for production
- Configure `JWT_SECRET` environment variable

### Frontend
- Deploy to Vercel or Netlify
- Set `NEXT_PUBLIC_API_URL` to backend URL

## 📄 License

MIT License - feel free to use for your school!
