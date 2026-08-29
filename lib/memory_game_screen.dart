import 'package:flutter/material.dart';
import 'dart:async';
import 'data_manager.dart';
import 'sound_manager.dart';

class MemoryGameScreen extends StatefulWidget {
  final int stake;
  const MemoryGameScreen({super.key, required this.stake});

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
    Icons.fastfood, Icons.fastfood,
    Icons.directions_car, Icons.directions_car,
  ];

  late List<bool> _cardFlips;
  late List<bool> _cardMatches;
  int? _firstSelectedIndex;
  bool _wait = false;
  int _score = 0;
  int _seconds = 40; // تایمر معکوس برای سختی بیشتر
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
    _seconds = widget.stake > 500 ? 30 : 45; // سختی بر اساس مبلغ شرط
    _firstSelectedIndex = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _timer?.cancel();
            _endGame(false);
          }
        });
      }
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

  void _checkWin() {
    if (_cardMatches.every((element) => element == true)) {
      _endGame(true);
    }
  }

  void _endGame(bool won) async {
    _timer?.cancel();
    if (won) {
      await SoundManager.playWin();
      await DataManager.addWinReward(widget.stake);
    } else {
      await SoundManager.playLose();
      await DataManager.logGameEvent("باخت در حافظه برتر", widget.stake, -widget.stake);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(won ? 'حافظه فوق‌العاده! 🎉' : 'زمان تمام شد! ❌', textAlign: TextAlign.center),
          content: Text(won ? 'شما همه کارت‌ها را پیدا کردید و سود واریز شد.' : 'سرعت عمل شما کافی نبود.'),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                child: const Text('بازگشت'),
              ),
            ),
          ],
        ),
      ),
    );
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
          title: const Text('حافظه برتر (سخت)'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          actions: [
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text('زمان: $_seconds', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  bool isVisible = _cardFlips[index] || _cardMatches[index];
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isVisible ? Colors.white : Colors.orange[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[900]!, width: 2),
                      ),
                      child: isVisible
                          ? Icon(_icons[index], size: 30, color: Colors.orange[800])
                          : const Icon(Icons.help_outline, size: 30, color: Colors.white),
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
}
