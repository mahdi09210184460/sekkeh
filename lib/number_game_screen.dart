import 'package:flutter/material.dart';
import 'dart:math';
import 'data_manager.dart';
import 'sound_manager.dart';

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key});

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  final int _target = Random().nextInt(50) + 1;
  int _tries = 5; // افزایش شانس به ۵ برای جذابیت بیشتر
  final TextEditingController _controller = TextEditingController();
  String _hint = "یک عدد بین ۱ تا ۵۰ حدس بزنید";
  List<int> _history = [];

  void _guess() {
    int? val = int.tryParse(_controller.text);
    if (val == null || val < 1 || val > 50) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً عددی بین ۱ تا ۵۰ وارد کنید')));
      return;
    }

    setState(() {
      SoundManager.playTap();
      _history.insert(0, val);
      if (val == _target) {
        _endGame(true);
      } else {
        _tries--;
        if (_tries > 0) {
          _hint = val > _target ? "عدد هدف کوچکتر از $val است! 👇" : "عدد هدف بزرگتر از $val است! 👆";
        } else {
          _endGame(false);
        }
      }
    });
    _controller.clear();
  }

  void _endGame(bool won) async {
    if (won) {
      await SoundManager.playWin();
      await DataManager.addWinReward();
    } else {
      await SoundManager.playLose();
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(won ? 'هوش سرشار! 🎉' : 'بدشانسی آوردی! ❌', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(won ? Icons.psychology : Icons.help_outline, size: 70, color: won ? Colors.green : Colors.red),
              const SizedBox(height: 15),
              Text(won ? 'شما عدد $_target را درست حدس زدید!' : 'عدد مورد نظر $_target بود.'),
              const Divider(),
              Text(won ? '۱۵ سکه جایزه واریز شد.' : '۵۰ سکه از حساب شما کسر شد.'),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                child: const Text('تایید و بازگشت'),
              ),
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
          title: const Text('حدس عدد جادویی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('فرصت‌های باقی‌مانده:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text('$_tries', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(_hint, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.orange)),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '؟؟',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _tries > 0 ? _guess : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('بررسی حدس من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
              if (_history.isNotEmpty) ...[
                const Text('تاریخچه حدس‌های شما:', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _history.map((h) => Chip(
                    label: Text('$h'),
                    backgroundColor: h == _target ? Colors.green[100] : Colors.grey[200],
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
