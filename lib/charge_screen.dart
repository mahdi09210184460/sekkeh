import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'sound_manager.dart';

class ChargeScreen extends StatelessWidget {
  const ChargeScreen({super.key});

  void _processCharge(BuildContext context, Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تایید پرداخت', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('آیا از خرید "${package['name']}" اطمینان دارید؟'),
              const SizedBox(height: 10),
              Text('مبلغ قابل پرداخت: ${package['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                // شبیه‌سازی درگاه پرداخت
                Navigator.pop(context);
                _showFakePayment(context, package);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
              child: const Text('اتصال به درگاه'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFakePayment(BuildContext context, Map<String, dynamic> package) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('در حال اتصال به درگاه بانکی...', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('لطفاً منتظر بمانید'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                DataManager.balance += package['coins'] as int;
                await DataManager.saveData();
                await SoundManager.playWin();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('پرداخت موفقیت‌آمیز بود! ${package['coins']} سکه به حساب شما اضافه شد 🎁'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('تایید پرداخت (شبیه‌سازی)'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('شارژ حساب و خرید سکه'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.orange, Colors.redAccent]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('موجودی فعلی شما', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${DataManager.balance}', style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('بسته‌های پیشنهادی:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...DataManager.coinPackages.map((package) => _buildPackageCard(context, package)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> package) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => _processCharge(context, package),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange[50],
                child: Icon(package['icon'], color: Colors.orange[800], size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('مقدار: ${package['coins']} سکه طلایی', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(package['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const Icon(Icons.arrow_back_ios_new, size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
