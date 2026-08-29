import 'package:flutter/material.dart';
import 'data_manager.dart';

class AppInfoScreen extends StatelessWidget {
  final String mode; // 'security' or 'support'
  const AppInfoScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    bool isSecurity = mode == 'security';
    String title = isSecurity ? 'امنیت و حریم خصوصی' : 'پشتیبانی و تماس با ما';
    String content = isSecurity 
        ? DataManager.appContent['security_policy'] 
        : DataManager.appContent['support_info'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Icon(
                isSecurity ? Icons.security : Icons.support_agent,
                size: 80,
                color: Colors.orange[800],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.8),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 40),
              if (!isSecurity) ...[
                const Text('راه‌های ارتباطی دیگر:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildContactItem(Icons.email, 'ایمیل: support@sekkehchi.com'),
                _buildContactItem(Icons.language, 'وب‌سایت: www.sekkehchi.com'),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}
