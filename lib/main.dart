import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'data_manager.dart';

void main() async {
  // اطمینان از مقداردهی اولیه برای استفاده از پلاگین‌ها
  WidgetsFlutterBinding.ensureInitialized();
  
  // بارگذاری داده‌ها از حافظه دائمی
  await DataManager.loadData();
  
  runApp(const SekkehChiApp());
}

class SekkehChiApp extends StatelessWidget {
  const SekkehChiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سکه چی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Tahoma',
      ),
      home: const RegisterScreen(),
    );
  }
}
