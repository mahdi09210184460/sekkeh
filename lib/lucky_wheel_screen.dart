import 'package:flutter/material.dart';
import 'dart:math';
import 'data_manager.dart';
import 'sound_manager.dart';

class LuckyWheelScreen extends StatefulWidget {
  const LuckyWheelScreen({super.key});

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _rotation = 0;
  bool _isSpinning = false;

  final List<Map<String, dynamic>> _prizes = [
    {'label': '۵ سکه', 'value': 5, 'color': Colors.red},
    {'label': '۱۰ سکه', 'value': 10, 'color': Colors.blue},
    {'label': '۰ سکه', 'value': 0, 'color': Colors.grey},
    {'label': '۵۰ سکه', 'value': 50, 'color': Colors.amber},
    {'label': '۱۵ سکه', 'value': 15, 'color': Colors.green},
    {'label': '۲۰ سکه', 'value': 20, 'color': Colors.purple},
    {'label': '۲ سکه', 'value': 2, 'color': Colors.orange},
    {'label': '۱۰۰ سکه', 'value': 100, 'color': Colors.redAccent},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
  }

  void _spinWheel() {
    if (_isSpinning) return;
    SoundManager.playTap();
    setState(() => _isSpinning = true);

    final double randomRotation = (2 * pi * 5) + (Random().nextDouble() * 2 * pi);
    
    _controller.forward(from: 0).then((_) {
      setState(() {
        _rotation = (_rotation + randomRotation) % (2 * pi);
        _isSpinning = false;
        _showResult();
      });
      _controller.reset();
    });
  }

  void _showResult() async {
    int sectorCount = _prizes.length;
    double sectorAngle = 2 * pi / sectorCount;
    double winningAngle = (2 * pi - _rotation + (3 * pi / 2)) % (2 * pi);
    int index = (winningAngle / sectorAngle).floor() % sectorCount;

    String prizeLabel = _prizes[index]['label'];
    int prizeValue = _prizes[index]['value'];

    if (prizeValue > 0) {
      await SoundManager.playWin();
    } else {
      await SoundManager.playLose();
    }

    // اضافه کردن جایزه به موجودی دائمی
    DataManager.balance += prizeValue;
    await DataManager.saveData();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('نتیجه گردونه'),
          content: Text('تبریک! شما برنده $prizeLabel شدید!'),
          actions: [
            ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
              child: const Text('تایید و بازگشت'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('گردونه شانس'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('بچرخون و سکه ببر!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double currentRotation = _rotation + (_animation.value * (2 * pi * 5 + 1.0));
                      return Transform.rotate(
                        angle: _isSpinning ? currentRotation : _rotation,
                        child: CustomPaint(size: const Size(300, 300), painter: WheelPainter(_prizes)),
                      );
                    },
                  ),
                  const Positioned(top: 0, child: Icon(Icons.arrow_drop_down, size: 50)),
                ],
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _isSpinning ? null : _spinWheel,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
                child: Text(_isSpinning ? 'در حال چرخش...' : 'بچرخون!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> prizes;
  WheelPainter(this.prizes);
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double arcAngle = 2 * pi / prizes.length;
    for (int i = 0; i < prizes.length; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), i * arcAngle, arcAngle, true, Paint()..color = prizes[i]['color']);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * arcAngle + arcAngle / 2);
      final tp = TextPainter(text: TextSpan(text: prizes[i]['label'], style: const TextStyle(color: Colors.white, fontSize: 12)), textDirection: TextDirection.rtl);
      tp.layout();
      tp.paint(canvas, Offset(radius * 0.5, -tp.height / 2));
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}
