import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/stock_recorder_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'School Logistics',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            home: auth.isLoading
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  )
                : auth.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/inventory': (context) => const InventoryScreen(),
              '/requests': (context) => const RequestsScreen(),
              '/add-item': (context) => const AddItemScreen(),
              '/recorder': (context) => const StockRecorderScreen(),
            },
          );
        },
      ),
    );
  }
}
