import 'package:flutter/material.dart';
import 'home_hub_screen.dart';
import 'register_screen.dart';
import 'data_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    if (!await DataManager.hasInternet()) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای ورود مجدد، اتصال به اینترنت الزامی است 🌐'), backgroundColor: Colors.red));
      return;
    }
    String? error = await DataManager.login(_phoneController.text, _passwordController.text);
    setState(() => _isLoading = false);
    if (error == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeHubScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('ورود به دیدینو'),
          centerTitle: true,
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // لوگوی جدید در صفحه ورود
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange[100]!, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://vjoxfkyvawvuzwscofog.supabase.co/storage/v1/object/public/assets/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'شماره موبایل', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)))),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ورود به حساب کاربری', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text('هنوز عضو نشده‌اید؟ ثبت‌نام کنید'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
