import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class DataManager {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Map<String, dynamic> userData = {};
  static List<Map<String, dynamic>> ordersList = [];

  static List<Map<String, dynamic>> shopProducts = [];
  static List<Map<String, dynamic>> newsList = [];
  static List<Map<String, dynamic>> lotteryList = [];

  static Map<String, dynamic> lotteryBanner = {
    'title': 'قرعه‌کشی طلایی',
    'subtitle': '',
    'image': ''
  };

  static List<Map<String, dynamic>> winnersList = [];

  static Map<String, dynamic> appContent = {
    'security_policy': 'اطلاعات شما محفوظ است.',
    'support_info': 'پشتیبانی: ۰۹۹۲۷۸۹۱۶۰۸',
    'card_number': '۶۰۳۷-۹۹۷۹-XXXX-XXXX',
    'card_name': 'مدیریت دیدینو',
  };

  static List<Map<String, dynamic>> allUsers = [];


  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }


  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String? localUser =
        prefs.getString('local_user_data');

    if (localUser != null) {
      userData = jsonDecode(localUser);

      ordersList =
          List<Map<String, dynamic>>.from(
        jsonDecode(
          prefs.getString('local_orders') ?? '[]',
        ),
      );
    }


    if (await hasInternet()) {
      try {
        final config =
            await _supabase.from('global_config').select();

        for (var row in config) {
          String id = row['id'];
          Map<String, dynamic> data = row['data'];

          if (id == 'shop') {
            shopProducts =
                List<Map<String, dynamic>>.from(
                    data['items'] ?? []);
          }

          if (id == 'news') {
            newsList =
                List<Map<String, dynamic>>.from(
                    data['items'] ?? []);
          }

          if (id == 'lottery') {
            lotteryList =
                List<Map<String, dynamic>>.from(
                    data['items'] ?? []);

            lotteryBanner =
                Map<String, dynamic>.from(
                    data['banner'] ?? {});

            winnersList =
                List<Map<String, dynamic>>.from(
                    data['winners'] ?? []);
          }

          if (id == 'settings') {
            appContent =
                Map<String, dynamic>.from(
                    data['appContent'] ?? appContent);
          }
        }

      } catch (e) {
        debugPrint("Server Load Error: $e");
      }
    }
  }



  static Future<void> saveLocally() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
        'local_user_data',
        jsonEncode(userData));

    await prefs.setString(
        'local_orders',
        jsonEncode(ordersList));

    if (userData['phone'] != null) {
      await prefs.setString(
          'user_phone',
          userData['phone']);
    }
  }



  // تابع مورد نیاز profile_screen
  static Future<void> saveData() async {

    if (userData['phone'] == null) return;

    await saveLocally();

    if (!await hasInternet()) return;

    await _supabase.from('users').upsert({

      'phone': userData['phone'],

      'user_data': userData,

      'orders_list': ordersList,

      'last_seen':
          DateTime.now().toIso8601String(),

    });
  }



  // تابع مورد نیاز my_orders_screen
  static Future<void> syncUserWithServer(
      String phone) async {

    if (!await hasInternet()) return;

    try {

      final response =
          await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();


      if (response != null) {

        userData =
            Map<String, dynamic>.from(
              response['user_data'] ?? {},
            );


        ordersList =
            List<Map<String, dynamic>>.from(
              response['orders_list'] ?? [],
            );


        await saveLocally();
      }

    } catch(e){

      debugPrint(
          "Sync User Error: $e");

    }
  }



  // تابع مورد نیاز login_screen
  static Future<String?> login(
      String phone,
      String password) async {


    if (!await hasInternet()) {

      return "اتصال اینترنت برقرار نیست";

    }


    try {

      final response =
          await _supabase
          .from('users')
          .select()
          .eq('phone', phone)
          .maybeSingle();


      if (response == null) {

        return "کاربر پیدا نشد";

      }


      userData =
          Map<String, dynamic>.from(
              response['user_data'] ?? {});


      ordersList =
          List<Map<String, dynamic>>.from(
              response['orders_list'] ?? []);


      await saveLocally();


      return null;


    } catch(e){

      return "خطا در ورود";

    }

  }



  static Future<bool> syncOrderToServer() async {

    if (!await hasInternet()) return false;

    if (userData['phone'] == null)
      return false;


    try {

      await saveData();

      return true;

    } catch(e){

      return false;

    }
  }



  static Future<void> saveGlobalConfig() async {

    if (!await hasInternet()) return;


    await _supabase.from('global_config').upsert({
      'id':'shop',
      'data':{
        'items':shopProducts
      }
    });


    await _supabase.from('global_config').upsert({
      'id':'news',
      'data':{
        'items':newsList
      }
    });


    await _supabase.from('global_config').upsert({
      'id':'lottery',
      'data':{
        'items':lotteryList,
        'banner':lotteryBanner,
        'winners':winnersList
      }
    });

  }



  static Future<void> fetchAllUsersForAdmin() async {

    if (!await hasInternet()) return;


    final response =
        await _supabase.from('users').select();


    allUsers =
        List<Map<String,dynamic>>.from(response);

  }



  static Future<void> saveSpecificUserToCloud(
      Map<String,dynamic> user) async {


    if (!await hasInternet()) return;


    await _supabase.from('users').upsert({

      'phone':user['phone'],

      'user_data':user['user_data'],

      'orders_list':user['orders_list'],

    });

  }



  static Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    userData = {};

    ordersList = [];

  }

}
