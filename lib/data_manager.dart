import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DataManager {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  static Map<String, dynamic> userData = {};
  static List<Map<String, dynamic>> ordersList = [];
  
  // داده‌های جهانی که ادمین تغییر می‌دهد
  static List<Map<String, dynamic>> shopProducts = [];
  static List<Map<String, dynamic>> newsList = [];
  static List<Map<String, dynamic>> lotteryList = [];
  static Map<String, dynamic> lotteryBanner = {'title': 'قرعه‌کشی طلایی', 'subtitle': '', 'image': ''};
  static List<Map<String, dynamic>> winnersList = [];
  
  static Map<String, dynamic> appContent = {
    'security_policy': 'اطلاعات شما محفوظ است.',
    'support_info': 'پشتیبانی: ۰۹۹۲۷۸۹۱۶۰۸',
    'card_number': '۶۰۳۷-۹۹۷۹-XXXX-XXXX',
    'card_name': 'مدیریت دیدینو',
  };

  static List<Map<String, dynamic>> allUsers = []; 

  // بررسی وضعیت اینترنت
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ۱. بارگذاری اطلاعات کاربر از حافظه گوشی (آفلاین)
    String? localUser = prefs.getString('local_user_data');
    if (localUser != null) {
      userData = jsonDecode(localUser);
      ordersList = List<Map<String, dynamic>>.from(jsonDecode(prefs.getString('local_orders') ?? '[]'));
    }

    // ۲. بارگذاری تنظیمات از سرور (اگر اینترنت بود)
    if (await hasInternet()) {
      try {
        final List<dynamic> config = await _supabase.from('global_config').select();
        for (var row in config) {
          String id = row['id'];
          Map<String, dynamic> data = row['data'];
          if (id == 'shop') shopProducts = List<Map<String, dynamic>>.from(data['items'] ?? []);
          if (id == 'news') newsList = List<Map<String, dynamic>>.from(data['items'] ?? []);
          if (id == 'lottery') {
            lotteryList = List<Map<String, dynamic>>.from(data['items'] ?? []);
            lotteryBanner = Map<String, dynamic>.from(data['banner'] ?? {});
            winnersList = List<Map<String, dynamic>>.from(data['winners'] ?? []);
          }
          if (id == 'settings') {
            appContent = Map<String, dynamic>.from(data['appContent'] ?? appContent);
          }
        }
      } catch (e) {
        debugPrint("Server Load Error: $e");
      }
    }
  }

  // ذخیره محلی (آفلاین)
  static Future<void> saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_user_data', jsonEncode(userData));
    await prefs.setString('local_orders', jsonEncode(ordersList));
    if (userData['phone'] != null) await prefs.setString('user_phone', userData['phone']);
  }

  // ارسال سفارش و اطلاعات کاربر به سرور (آنلاین)
  static Future<bool> syncOrderToServer() async {
    if (!await hasInternet()) return false;
    if (userData['phone'] == null) return false;

    try {
      await _supabase.from('users').upsert({
        'phone': userData['phone'],
        'user_data': userData,
        'orders_list': ordersList,
        'last_seen': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint("Sync Error: $e");
      return false;
    }
  }

  // عملیات ادمین (فقط آنلاین)
  static Future<void> saveGlobalConfig() async {
    if (!await hasInternet()) return;
    await _supabase.from('global_config').upsert({'id': 'shop', 'data': {'items': shopProducts}});
    await _supabase.from('global_config').upsert({'id': 'news', 'data': {'items': newsList}});
    await _supabase.from('global_config').upsert({'id': 'lottery', 'data': {'items': lotteryList, 'banner': lotteryBanner, 'winners': winnersList}});
    await _supabase.from('global_config').upsert({'id': 'settings', 'data': {'appContent': appContent}});
  }

  static Future<void> fetchAllUsersForAdmin() async {
    if (!await hasInternet()) return;
    try {
      final response = await _supabase.from('users').select();
      allUsers = List<Map<String, dynamic>>.from(response);
    } catch (e) { debugPrint("Fetch Error: $e"); }
  }

  static Future<void> saveSpecificUserToCloud(Map<String, dynamic> user) async {
    if (!await hasInternet()) return;
    await _supabase.from('users').upsert({
      'phone': user['phone'],
      'user_data': user['user_data'],
      'orders_list': user['orders_list'],
    });
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userData = {};
    ordersList = [];
  }
}
