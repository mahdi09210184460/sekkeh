import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'home_hub_screen.dart';
import 'data_manager.dart';

void main() async {
  // اطمینان از مقداردهی اولیه برای استفاده از پلاگین‌ها
  WidgetsFlutterBinding.ensureInitialized();
  
  // مقداردهی اولیه Supabase
  await Supabase.initialize(
    url: 'https://ulcdktspxoziviwhlrcg.supabase.co',
    anonKey: 'sb_publishable_fJQtMQBYlKCj7g-1ruRp3Q_KWc5U_3H',
  );
  
  // بارگذاری داده‌ها از سرور و حافظه
  await DataManager.loadData();

  // تست اتصال
  bool isConnected = await DataManager.checkConnection();
  if (isConnected) {
    debugPrint("✅ اپلیکیشن با موفقیت به Supabase متصل شد.");
  } else {
    debugPrint("❌ خطا در اتصال به Supabase. لطفاً اینترنت و تنظیمات پروژه را چک کنید.");
  }
  
  runApp(const SekkehChiApp());
}

class SekkehChiApp extends StatelessWidget {
  const SekkehChiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // بررسی اینکه آیا کاربر قبلاً ثبت‌نام کرده است یا خیر
    bool isRegistered = DataManager.userData['phone'] != null && 
                       DataManager.userData['phone'].toString().isNotEmpty;

    return MaterialApp(
      title: 'سکه چی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Tahoma',
      ),
      // اگر ثبت‌نام کرده بود به هاب اصلی و در غیر این صورت به صفحه ثبت‌نام برود
      home: isRegistered ? const HomeHubScreen() : const RegisterScreen(),
    );
  }
}
