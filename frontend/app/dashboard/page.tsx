'use client';

import { useAuth } from '@/lib/auth-context';
import { useEffect, useState } from 'react';

export default function Dashboard() {
    const { user, token } = useAuth();
    const [stats, setStats] = useState({
        totalItems: 0,
        lowStock: 0,
        pendingRequests: 0,
    });

    useEffect(() => {
        // Fetch dashboard stats
        const fetchStats = async () => {
            try {
                const response = await fetch('http://localhost:5000/api/inventory', {
                    headers: { 'Authorization': `Bearer ${token}` },
                });
                const items = await response.json();

                setStats({
                    totalItems: items.length,
                    lowStock: items.filter((item: any) => item.quantity < item.minStockLevel).length,
                    pendingRequests: 0, // Would fetch from requests endpoint
                });
            } catch (error) {
                console.error('Failed to fetch stats:', error);
            }
        };

        if (token) {
            fetchStats();
        }
    }, [token]);

    return (
        <div>
            <h1 className="text-3xl font-bold text-gray-900 mb-8">Dashboard Overview</h1>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm font-medium text-gray-600">Total Items</p>
                            <p className="text-3xl font-bold text-gray-900 mt-2">{stats.totalItems}</p>
                        </div>
                        <div className="p-3 bg-blue-50 rounded-full">
                            <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm font-medium text-gray-600">Low Stock Items</p>
                            <p className="text-3xl font-bold text-orange-600 mt-2">{stats.lowStock}</p>
                        </div>
                        <div className="p-3 bg-orange-50 rounded-full">
                            <svg className="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm font-medium text-gray-600">Pending Requests</p>
                            <p className="text-3xl font-bold text-green-600 mt-2">{stats.pendingRequests}</p>
                        </div>
                        <div className="p-3 bg-green-50 rounded-full">
                            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                        </div>
                    </div>
                </div>
            </div>

            {/* Quick Actions */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <a
                        href="/dashboard/inventory"
                        className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition"
                    >
                        <span className="text-2xl">📦</span>
                        <div>
                            <p className="font-medium text-gray-900">View Inventory</p>
                            <p className="text-sm text-gray-500">Manage all items</p>
                        </div>
                    </a>
                    <a
                        href="/dashboard/requests"
                        className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition"
                    >
                        <span className="text-2xl">📝</span>
                        <div>
                            <p className="font-medium text-gray-900">Manage Requests</p>
                            <p className="text-sm text-gray-500">Review and approve</p>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    );
}
