import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataManager {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  static int balance = 500;
  static List<Map<String, dynamic>> shopProducts = [];
  static List<Map<String, dynamic>> newsList = [];
  static List<Map<String, dynamic>> lotteryList = [];
  static Map<String, dynamic> lotteryBanner = {};
  static List<Map<String, dynamic>> winnersList = [];
  static Map<String, dynamic> userData = {};
  static List<Map<String, dynamic>> ordersList = [];
  static List<Map<String, dynamic>> gameHistory = [];
  static List<Map<String, dynamic>> allUsers = []; // برای ادمین

  static Map<String, dynamic> appContent = {
    'security_policy': 'اطلاعات شما محفوظ است.',
    'support_info': 'پشتیبانی: ۰۹۹۲۷۸۹۱۶۰۸',
  };

  static List<Map<String, dynamic>> coinPackages = [
    {'name': 'بسته پایه', 'coins': 1000, 'price': '۱۰,۰۰۰ تومان', 'icon': Icons.monetization_on},
    {'name': 'بسته ویژه', 'coins': 5000, 'price': '۴۵,۰۰۰ تومان', 'icon': Icons.diamond},
    {'name': 'بسته حرفه‌ای', 'coins': 15000, 'price': '۱۲۰,۰۰۰ تومان', 'icon': Icons.auto_awesome},
  ];

  static Map<String, dynamic> gameSettings = {
    'entryFee': 50,
    'winReward': 15,
    'activeGames': {
      'مار و پله': true, 'منچ سکه‌ای': true, 'ضربه طلایی': true,
      'کوییز طلایی': true, 'حدس عدد جادویی': true, 'حافظه برتر': true, 'گردونه شانس': true,
    }
  };

  // --- متدهای ارتباط با سرور (Supabase) ---

  static Future<bool> checkConnection() async {
    try {
      await _supabase.from('global_config').select('id').limit(1);
      return true;
    } catch (e) {
      debugPrint("خطای اتصال به Supabase: $e");
      return false;
    }
  }

  static Future<void> loadData() async {
    try {
      // ۱. بارگذاری اطلاعات کاربر از لوکال (برای تشخیص ورود قبلی)
      final prefs = await SharedPreferences.getInstance();
      String? savedPhone = prefs.getString('user_phone');
      
      if (savedPhone != null) {
        await syncUserWithServer(savedPhone);
      }

      // ۲. بارگذاری اطلاعات عمومی اپلیکیشن از سرور (جدول global_config)
      final List<dynamic> config = await _supabase.from('global_config').select();
      
      for (var row in config) {
        String id = row['id'];
        Map<String, dynamic> data = row['data'];
        
        if (id == 'shop') shopProducts = List<Map<String, dynamic>>.from(data['items']);
        if (id == 'news') newsList = List<Map<String, dynamic>>.from(data['items']);
        if (id == 'lottery') {
          lotteryList = List<Map<String, dynamic>>.from(data['items']);
          lotteryBanner = Map<String, dynamic>.from(data['banner']);
          winnersList = List<Map<String, dynamic>>.from(data['winners']);
        }
        if (id == 'settings') {
          gameSettings = Map<String, dynamic>.from(data['gameSettings']);
          appContent = Map<String, dynamic>.from(data['appContent']);
        }
      }
      
      // اگر دیتابیس خالی بود (اولین بار)، مقادیر پیش‌فرض را آپلود کن
      if (config.isEmpty) await uploadInitialConfig();

    } catch (e) {
      debugPrint("خطا در بارگذاری آنلاین (Supabase): $e");
    }
  }

  static Future<void> syncUserWithServer(String phone) async {
    try {
      final List<dynamic> response = await _supabase
          .from('users')
          .select()
          .eq('phone', phone);

      if (response.isNotEmpty) {
        final data = response.first;
        userData = Map<String, dynamic>.from(data['user_data']);
        balance = data['balance'];
        ordersList = List<Map<String, dynamic>>.from(data['orders_list']);
        gameHistory = List<Map<String, dynamic>>.from(data['game_history']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_phone', phone);
      }
    } catch (e) {
      debugPrint("خطا در همگام‌سازی کاربر (Supabase): $e");
    }
  }

  static Future<void> saveData() async {
    if (userData['phone'] == null) return;
    String phone = userData['phone'];

    try {
      // ذخیره اطلاعات کاربر در سرور (Upsert)
      await _supabase.from('users').upsert({
        'phone': phone,
        'user_data': userData,
        'balance': balance,
        'orders_list': ordersList,
        'game_history': gameHistory,
        'last_seen': DateTime.now().toIso8601String(),
      });

      // ذخیره لوکال برای دفعات بعدی
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', phone);
    } catch (e) {
      debugPrint("خطا در ذخیره آنلاین (Supabase): $e");
    }
  }

  // متد مخصوص ادمین برای ذخیره تنظیمات در کلود
  static Future<void> saveGlobalConfig() async {
    await _supabase.from('global_config').upsert({'id': 'shop', 'data': {'items': shopProducts}});
    await _supabase.from('global_config').upsert({'id': 'news', 'data': {'items': newsList}});
    await _supabase.from('global_config').upsert({'id': 'lottery', 'data': {
      'items': lotteryList,
      'banner': lotteryBanner,
      'winners': winnersList,
    }});
    await _supabase.from('global_config').upsert({'id': 'settings', 'data': {
      'gameSettings': gameSettings,
      'appContent': appContent,
    }});
  }

  static Future<void> fetchAllUsersForAdmin() async {
    try {
      final List<dynamic> response = await _supabase.from('users').select();
      allUsers = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("خطا در دریافت لیست کاربران (Supabase): $e");
    }
  }

  // --- متدهای کمکی بازی ---

  static bool canPlay(int stake) => balance >= stake;

  static Future<void> deductEntryFee(int stake) async {
    balance -= stake;
    await saveData();
  }

  static Future<void> addWinReward(int stake) async {
    int profit = (stake * 0.3).round();
    balance += stake + profit;
    await logGameEvent("برد در بازی", stake, profit);
    await saveData();
  }

  static Future<void> logGameEvent(String title, int stake, int result) async {
    gameHistory.insert(0, {
      'title': title,
      'stake': stake,
      'result': result,
      'date': DateTime.now().toString().substring(0, 10),
      'time': DateTime.now().toString().substring(11, 16),
    });
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_phone');
    userData = {};
    balance = 500;
    ordersList = [];
    gameHistory = [];
  }

  static Future<void> uploadInitialConfig() async {
    await saveGlobalConfig();
  }
}
