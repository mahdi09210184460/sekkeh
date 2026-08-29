import 'package:flutter/material.dart';
import 'dart:async';
import 'data_manager.dart';
import 'sound_manager.dart';

class TapGameScreen extends StatefulWidget {
  final int stake;
  const TapGameScreen({super.key, required this.stake});

  @override
  State<TapGameScreen> createState() => _TapGameScreenState();
}

class _TapGameScreenState extends State<TapGameScreen> {
  int _taps = 0;
  int _timeLeft = 7; // کاهش زمان از ۱۰ به ۷ ثانیه (سخت‌تر)
  Timer? _timer;
  bool _gameStarted = false;
  double _scale = 1.0;

  void _start() {
    setState(() {
      _gameStarted = true;
      _taps = 0;
      _timeLeft = 7;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _endGame();
      }
    });
  }

  void _onTap() {
    if (!_gameStarted) return;
    SoundManager.playTap();
    setState(() {
      _taps++;
      _scale = 1.2;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _scale = 1.0);
    });
  }

  void _endGame() async {
    bool won = _taps >= 60; // افزایش ضربه مورد نیاز به ۶۰ (سخت‌تر)
    if (won) {
      await SoundManager.playWin();
      await DataManager.addWinReward(widget.stake);
    } else {
      await SoundManager.playLose();
      await DataManager.logGameEvent("باخت در ضربه طلایی", widget.stake, -widget.stake);
    }
    if (!mounted) return;
    
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, anim1, anim2) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(won ? 'فوق‌العاده بود! 🎉' : 'کافی نبود! ❌', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(won ? Icons.emoji_events : Icons.sentiment_very_dissatisfied, 
                   size: 80, color: won ? Colors.amber : Colors.grey),
              const SizedBox(height: 20),
              Text(won ? 'شما با رکورد $_taps ضربه برنده شدید!' : 'رکورد شما: $_taps ضربه. نیاز به ۵۰ ضربه داشتید.'),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                child: const Text('بازگشت به بازی‌ها'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('چالش سرعت ضربه'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Text(
                'زمان: $_timeLeft ثانیه',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, 
                       color: _timeLeft < 4 ? Colors.red : Colors.orange[900]),
              ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _taps / 50,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
                  ),
                ),
                Text('$_taps', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 60),
            if (!_gameStarted)
              ElevatedButton(
                onPressed: _start,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('شروع چالش طلایی', style: TextStyle(fontSize: 20)),
              )
            else
              GestureDetector(
                onTap: _onTap,
                child: AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                      ],
                      gradient: const RadialGradient(colors: [Colors.yellow, Colors.orange]),
                    ),
                    child: const Icon(Icons.touch_app, size: 90, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text('هدف: ۵۰ ضربه', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
