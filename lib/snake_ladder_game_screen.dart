import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'data_manager.dart';
import 'sound_manager.dart';

class SnakeLadderGameScreen extends StatefulWidget {
  final int stake;
  const SnakeLadderGameScreen({super.key, required this.stake});

  @override
  State<SnakeLadderGameScreen> createState() => _SnakeLadderGameScreenState();
}

class _SnakeLadderGameScreenState extends State<SnakeLadderGameScreen> {
  int _playerPos = 0;
  int _aiPos = 0;
  bool _isPlayerTurn = true;
  bool _isRolling = false;
  int _diceValue = 1;

  final Map<int, int> _snakes = {16: 6, 47: 26, 49: 11, 56: 53, 62: 19, 64: 60, 87: 24, 93: 73, 95: 75, 98: 78};
  final Map<int, int> _ladders = {1: 38, 4: 14, 9: 31, 21: 42, 28: 84, 36: 44, 51: 67, 71: 91, 80: 100};

  void _rollDice() async {
    if (!_isPlayerTurn || _isRolling) return;

    setState(() => _isRolling = true);
    SoundManager.playTap();

    // انیمیشن تاس
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _diceValue = Random().nextInt(6) + 1);
    }

    setState(() {
      _playerPos += _diceValue;
      if (_playerPos > 100) _playerPos = 100 - (_playerPos - 100);
      
      // چک کردن مار یا پله
      if (_snakes.containsKey(_playerPos)) _playerPos = _snakes[_playerPos]!;
      if (_ladders.containsKey(_playerPos)) _playerPos = _ladders[_playerPos]!;

      _isRolling = false;
      _isPlayerTurn = false;
    });

    if (_playerPos == 100) {
      _endGame(true);
    } else {
      Future.delayed(const Duration(seconds: 1), _aiTurn);
    }
  }

  void _aiTurn() async {
    setState(() => _isRolling = true);
    
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _diceValue = Random().nextInt(6) + 1);
    }

    setState(() {
      _aiPos += _diceValue;
      if (_aiPos > 100) _aiPos = 100 - (_aiPos - 100);
      
      if (_snakes.containsKey(_aiPos)) _aiPos = _snakes[_aiPos]!;
      if (_ladders.containsKey(_aiPos)) _aiPos = _ladders[_aiPos]!;

      _isRolling = false;
      _isPlayerTurn = true;
    });

    if (_aiPos == 100) {
      _endGame(false);
    }
  }

  void _endGame(bool won) async {
    if (won) {
      await SoundManager.playWin();
      await DataManager.addWinReward(widget.stake);
    } else {
      await SoundManager.playLose();
      await DataManager.logGameEvent("باخت در مار و پله", widget.stake, -widget.stake);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(won ? 'پیروزی در مار و پله! 🎉' : 'مار گزیدت! ❌', textAlign: TextAlign.center),
          content: Text(won ? 'شما برنده شدید و سود شرط‌بندی واریز شد.' : 'هوش مصنوعی زودتر به مقصد رسید.'),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); },
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
        appBar: AppBar(title: const Text('مار و پله جادویی'), backgroundColor: Colors.orange[800]),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange[800]!, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.builder(
                  reverse: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    int cellNum = index + 1;
                    bool hasPlayer = _playerPos == cellNum;
                    bool hasAi = _aiPos == cellNum;
                    
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 0.5),
                        color: _getCellColor(cellNum),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('$cellNum', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                          if (hasPlayer) const Icon(Icons.person, color: Colors.blue, size: 20),
                          if (hasAi) const Icon(Icons.android, color: Colors.red, size: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.orange[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatus('شما', _playerPos, Colors.blue),
                  Column(
                    children: [
                      Icon(_getDiceIcon(_diceValue), size: 50, color: Colors.orange[800]),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isPlayerTurn && !_isRolling ? _rollDice : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
                        child: Text(_isPlayerTurn ? 'تاس بنداز' : 'نوبت حریف'),
                      ),
                    ],
                  ),
                  _buildStatus('حریف', _aiPos, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor(int n) {
    if (_snakes.containsKey(n)) return Colors.red[50]!;
    if (_ladders.containsKey(n)) return Colors.green[50]!;
    return Colors.white;
  }

  IconData _getDiceIcon(int v) {
    switch(v) {
      case 1: return Icons.looks_one;
      case 2: return Icons.looks_two;
      case 3: return Icons.looks_3;
      case 4: return Icons.looks_4;
      case 5: return Icons.looks_5;
      default: return Icons.looks_6;
    }
  }

  Widget _buildStatus(String label, int pos, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text('موقعیت: $pos', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
