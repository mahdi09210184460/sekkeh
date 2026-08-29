import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_hub_screen.dart';
import 'register_screen.dart';
import 'data_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // مقداردهی اولیه سوپابیس با آدرس و کلید شما
  await Supabase.initialize(
    url: 'https://vjoxfkyvawvuzwscofog.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqb3hma3l2YXd2dXp3c2NvZm9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ4OTU0NzgsImV4cCI6MjA0MDQ3MTQ3OH0.V-Zz7p9P4Y3l1h-v6k3X_oVz5v8z-n-Vv4s-Rz7P4Y3l1h-v6k3X_oVz5v8z-n-Vv4s',
  );

  // بارگذاری داده‌های اولیه (آفلاین و آنلاین)
  await DataManager.loadData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دیدینو',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Vazir', // در صورت وجود فونت در assets
      ),
      home: DataManager.userData.isEmpty 
          ? const RegisterScreen() 
          : const HomeHubScreen(),
    );
  }
}
