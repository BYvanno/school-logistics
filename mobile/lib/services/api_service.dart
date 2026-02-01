import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/item.dart';
import '../models/transaction.dart';

class ApiService {
  // Use localhost for Web, and local IP for physical Android devices
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    return 'https://school-backend-oiun.onrender.com';
  }

  String? _token;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];

      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(data['user']));

      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
  }

  // Inventory
  Future<List<Item>> getInventory() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/inventory'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory');
    }
  }

  Future<void> createItem(Map<String, dynamic> itemData) async {
    await _loadToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory'),
      headers: _getHeaders(),
      body: jsonEncode(itemData),
    );

    if (response.statusCode != 201) {
      print('Create Item Failed: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to create item: ${response.body}');
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> itemData) async {
    await _loadToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/inventory/$id'),
      headers: _getHeaders(),
      body: jsonEncode(itemData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item: ${response.body}');
    }
  }

  Future<void> updateStock(
    int itemId,
    int quantity,
    String type,
    String reason,
  ) async {
    await _loadToken();
    final user = await getSavedUser();
    if (user == null) throw Exception('User not found');

    final response = await http.patch(
      Uri.parse('$baseUrl/api/inventory/$itemId/stock'),
      headers: _getHeaders(),
      body: jsonEncode({
        'quantity': quantity,
        'type': type, // 'IN' or 'OUT'
        'reason': reason,
        'userId': user.id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update stock: ${response.body}');
    }
  }

  Future<List<Transaction>> getItemTransactions(int itemId) async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/inventory/$itemId/transactions'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<List<Map<String, dynamic>>> getGlobalStockLedger() async {
    await _loadToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/inventory/reports/ledger'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load stock ledger report');
    }
  }

  // Get saved user
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
