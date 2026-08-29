import 'package:flutter/material.dart';
import 'dart:math';
import 'data_manager.dart';
import 'sound_manager.dart';

class NumberGameScreen extends StatefulWidget {
  final int stake;
  const NumberGameScreen({super.key, required this.stake});

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  late int _target;
  late int _tries;
  final TextEditingController _controller = TextEditingController();
  String _hint = "یک عدد بین ۱ تا ۱۰۰ حدس بزنید";
  final List<int> _history = [];

  @override
  void initState() {
    super.initState();
    _target = Random().nextInt(100) + 1;
    _tries = widget.stake > 500 ? 4 : 7; // کمتر کردن فرصت برای شرط‌های بالا
  }

  void _guess() {
    int? val = int.tryParse(_controller.text);
    if (val == null || val < 1 || val > 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عددی بین ۱ تا ۱۰۰ وارد کنید')));
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
      await DataManager.addWinReward(widget.stake);
    } else {
      await SoundManager.playLose();
      await DataManager.logGameEvent("باخت در حدس عدد", widget.stake, -widget.stake);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(won ? 'بسیار عالی! 🎉' : 'فرصت تمام شد! ❌', textAlign: TextAlign.center),
          content: Text(won ? 'شما عدد $_target را پیدا کردید و سود واریز شد.' : 'عدد مورد نظر $_target بود.'),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                child: const Text('بازگشت'),
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
        appBar: AppBar(title: const Text('حدس عدد (۱ تا ۱۰۰)'), backgroundColor: Colors.orange[800]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Text('فرصت‌های باقی‌مانده: $_tries', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 20),
              Text(_hint, style: const TextStyle(fontSize: 18, color: Colors.orange)),
              const SizedBox(height: 30),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  hintText: '؟؟',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guess,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], minimumSize: const Size(double.infinity, 50)),
                child: const Text('بررسی حدس', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 30),
              if (_history.isNotEmpty) ...[
                const Text('حدس‌های قبلی:'),
                Wrap(spacing: 10, children: _history.map((h) => Chip(label: Text('$h'))).toList()),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
