import 'package:flutter/material.dart';
import 'home_hub_screen.dart';
import 'data_manager.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final Map<String, dynamic> tempUserData; // اطلاعاتی که کاربر در ثبت‌نام وارد کرده
  const OtpScreen({super.key, required this.phone, required this.tempUserData});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  void _verify() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);
    bool success = await DataManager.verifyOtp(widget.phone, _otpController.text);
    
    if (success) {
      // کد تایید شد، حالا اطلاعات کاربر را در دیتابیس ثبت می‌کنیم
      DataManager.userData = widget.tempUserData;
      await DataManager.saveData();
      
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeHubScreen()),
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('کد وارد شده اشتباه یا منقضی است ❌'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تایید شماره موبایل'), backgroundColor: Colors.orange[800]),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text('کد ۶ رقمی به شماره ${widget.phone} ارسال شد.'),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                letterSpacing: 10,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '------',
                  border: OutlineInputBorder(),
                  labelText: 'کد تایید',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('تایید و ورود', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ویرایش شماره موبایل'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
