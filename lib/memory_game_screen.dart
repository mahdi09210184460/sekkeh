import 'package:flutter/material.dart';
import 'dart:async';
import 'data_manager.dart';
import 'sound_manager.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<IconData> _icons = [
    Icons.monetization_on, Icons.monetization_on,
    Icons.card_giftcard, Icons.card_giftcard,
    Icons.stars, Icons.stars,
    Icons.emoji_events, Icons.emoji_events,
    Icons.shopping_cart, Icons.shopping_cart,
    Icons.diamond, Icons.diamond,
    Icons.account_balance_wallet, Icons.account_balance_wallet,
    Icons.auto_awesome, Icons.auto_awesome,
  ];

  late List<bool> _cardFlips;
  late List<bool> _cardMatches;
  int? _firstSelectedIndex;
  bool _wait = false;
  int _score = 0;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupGame();
    _startTimer();
  }

  void _setupGame() {
    _icons.shuffle();
    _cardFlips = List.filled(_icons.length, false);
    _cardMatches = List.filled(_icons.length, false);
    _score = 0;
    _seconds = 0;
    _firstSelectedIndex = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _onCardTap(int index) {
    if (_wait || _cardFlips[index] || _cardMatches[index]) return;

    SoundManager.playTap();
    setState(() {
      _cardFlips[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      if (_icons[_firstSelectedIndex!] == _icons[index]) {
        setState(() {
          _cardMatches[_firstSelectedIndex!] = true;
          _cardMatches[index] = true;
          _firstSelectedIndex = null;
          _score += 20;
        });
        _checkWin();
      } else {
        _wait = true;
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _cardFlips[_firstSelectedIndex!] = false;
              _cardFlips[index] = false;
              _firstSelectedIndex = null;
              _wait = false;
            });
          }
        });
      }
    }
  }

  void _checkWin() async {
    if (_cardMatches.every((element) => element == true)) {
      _timer?.cancel();
      await SoundManager.playWin();
      await DataManager.addWinReward();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('آفرین! شما پیروز شدید 🎉', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology, size: 70, color: Colors.purple),
                const SizedBox(height: 15),
                Text('زمان شما: $_seconds ثانیه'),
                Text('امتیاز نهایی: $_score'),
                const Divider(),
                const Text('۱۵ سکه سود به حساب شما واریز شد.'),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                  child: const Text('تایید و بازگشت'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('بازی حافظه برتر'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('زمان', '$_seconds ثانیه', Icons.timer),
                  _buildStatCard('امتیاز', '$_score', Icons.stars),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  bool isVisible = _cardFlips[index] || _cardMatches[index];
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: isVisible ? Colors.white : Colors.orange[800],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
                        ],
                        border: Border.all(
                          color: isVisible ? Colors.orange : Colors.orange[900]!,
                          width: 2,
                        ),
                      ),
                      child: isVisible
                          ? Icon(_icons[index], size: 35, color: Colors.orange[800])
                          : Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange[800]),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
