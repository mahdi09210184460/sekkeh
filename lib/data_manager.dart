import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static int balance = 500;

  static List<Map<String, dynamic>> shopProducts = [
    {
      'name': 'کارت هدیه ۵۰۰ هزار تومانی دیجی‌کالا',
      'desc': 'کد تخفیف ۱۰۰ درصدی برای خرید از دیجی‌کالا.',
      'price': 500,
      'category': 'کارت هدیه',
      'image': 'https://img.freepik.com/free-vector/gift-card-template-with-golden-ribbon_23-2148287514.jpg'
    },
    {
      'name': 'تی‌شرت اختصاصی سکه چی',
      'desc': 'تی‌شرت با کیفیت پنبه‌ای با لوگوی طلایی سکه چی.',
      'price': 1200,
      'category': 'پوشاک',
      'image': 'https://img.freepik.com/free-photo/black-t-shirt-with-copy-space-crescent-moon_23-2148829937.jpg'
    },
    {
      'name': 'پاوربانک ۲۰۰۰۰ شیائومی',
      'desc': 'شارژر همراه قدرتمند با قابلیت فست شارژ.',
      'price': 2500,
      'category': 'کالای دیجیتال',
      'image': 'https://img.freepik.com/free-photo/portable-power-bank-smartphone_23-2148943538.jpg'
    },
    {
      'name': 'هندزفری بلوتوثی هایلو',
      'desc': 'صدای شفاف و باتری قدرتمند برای استفاده روزمره.',
      'price': 1800,
      'category': 'کالای دیجیتال',
      'image': 'https://img.freepik.com/free-photo/wireless-earbuds-with-charging-case_23-2148970163.jpg'
    },
  ];

  static List<Map<String, dynamic>> newsList = [
    {
      'title': 'جشنواره طلایی تابستانه',
      'description': 'با انجام بازی‌ها در این هفته، ۲ برابر سکه جایزه بگیرید.',
      'date': '۱ ساعت پیش',
      'icon_code': 0xe133, // celebration
      'isNew': true,
    },
    {
      'title': 'اضافه شدن بازی جدید: حدس کلمات',
      'description': 'هم‌اکنون می‌توانید بازی حدس کلمات را در بخش بازی‌ها تجربه کنید و سکه ببرید.',
      'date': 'دیروز',
      'icon_code': 0xe2af, // games
      'isNew': false,
    },
  ];

  static List<Map<String, dynamic>> lotteryList = [
    {
      'title': 'قرعه‌کشی بزرگ ماهانه',
      'prize': 'یک دستگاه کنسول PS5',
      'ticketPrice': 200,
      'icon_code': 0xe6ad, // videogame_asset
      'date': '۱۵ شهریور ۱۴۰۵',
      'color_value': 0xFF3F51B5 // indigo
    },
    {
      'title': 'قرعه‌کشی هفتگی',
      'prize': 'کارت هدیه ۱۰ میلیون تومانی',
      'ticketPrice': 50,
      'icon_code': 0xe13f, // card_giftcard
      'date': 'جمعه هر هفته',
      'color_value': 0xFFE91E63 // pink
    },
  ];

  static Map<String, dynamic> lotteryBanner = {
    'title': 'قرعه‌کشی طلایی این هفته',
    'subtitle': 'جایزه ویژه: آیفون ۱۵ پرو مکس',
    'image': 'https://img.freepik.com/free-vector/golden-confetti-background_23-2148287515.jpg',
  };

  static List<Map<String, dynamic>> winnersList = [
    {'name': 'علی محمدی', 'prize': 'کارت هدیه ۵ میلیونی', 'date': '۱۴۰۵/۰۵/۲۰'},
    {'name': 'سارا احمدی', 'prize': 'سکه تمام بهار آزادی', 'date': '۱۴۰۵/۰۵/۱۵'},
    {'name': 'رضا حسینی', 'prize': 'پاوربانک ۲۰۰۰۰', 'date': '۱۴۰۵/۰۵/۱۰'},
  ];

  static Map<String, dynamic> userData = {
    'name': 'کاربر جدید',
    'username': 'guest',
    'phone': '',
    'password': '',
    'joinDate': '۱۴۰۵/۰۱/۰۱',
  };

  static Map<String, dynamic> gameSettings = {
    'entryFee': 50,
    'winReward': 15,
  };

  // متدهای منطق بازی و کیف پول
  static bool canPlay() {
    return balance >= gameSettings['entryFee'];
  }

  static Future<void> deductEntryFee() async {
    balance -= (gameSettings['entryFee'] as int);
    await saveData();
  }

  static Future<void> addWinReward() async {
    // بازگشت هزینه ورودی + ۱۵ سکه سود
    balance += (gameSettings['entryFee'] as int) + (gameSettings['winReward'] as int);
    await saveData();
  }

  static String getCurrencyValue() {
    return "${balance * 1000} تومان";
  }

  // ذخیره و بارگذاری
  static Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_balance', balance);
      await prefs.setString('game_settings', jsonEncode(gameSettings));

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sekkeh_data.json');
      
      Map<String, dynamic> allData = {
        'shopProducts': shopProducts,
        'newsList': newsList,
        'lotteryList': lotteryList,
        'lotteryBanner': lotteryBanner,
        'winnersList': winnersList,
        'userData': userData,
      };
      
      await file.writeAsString(jsonEncode(allData));
    } catch (e) {
      debugPrint("خطا در ذخیره: $e");
    }
  }

  static Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      balance = prefs.getInt('user_balance') ?? 500;
      
      String? settingsJson = prefs.getString('game_settings');
      if (settingsJson != null) {
        gameSettings = jsonDecode(settingsJson);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sekkeh_data.json');
      
      if (await file.exists()) {
        String content = await file.readAsString();
        Map<String, dynamic> allData = jsonDecode(content);
        shopProducts = List<Map<String, dynamic>>.from(allData['shopProducts']);
        newsList = List<Map<String, dynamic>>.from(allData['newsList']);
        if (allData.containsKey('lotteryList')) {
          lotteryList = List<Map<String, dynamic>>.from(allData['lotteryList']);
        }
        if (allData.containsKey('lotteryBanner')) {
          lotteryBanner = Map<String, dynamic>.from(allData['lotteryBanner']);
        }
        if (allData.containsKey('winnersList')) {
          winnersList = List<Map<String, dynamic>>.from(allData['winnersList']);
        }
        if (allData.containsKey('userData')) {
          userData = Map<String, dynamic>.from(allData['userData']);
        }
      }
    } catch (e) {
      debugPrint("خطا در بارگذاری: $e");
    }
  }
}
