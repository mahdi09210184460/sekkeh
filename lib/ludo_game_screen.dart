import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'data_manager.dart';
import 'sound_manager.dart';

class LudoGameScreen extends StatefulWidget {
  final int stake;
  const LudoGameScreen({super.key, required this.stake});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> {
  int _player1Pos = -1; // -1 means home
  int _player2Pos = -1;
  int _ai1Pos = -1;
  int _ai2Pos = -1;
  
  bool _isPlayerTurn = true;
  bool _isRolling = false;
  int _diceValue = 1;
  String _message = "بازی را شروع کنید!";

  void _rollDice() async {
    if (!_isPlayerTurn || _isRolling) return;
    setState(() => _isRolling = true);
    SoundManager.playTap();

    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _diceValue = Random().nextInt(6) + 1);
    }

    setState(() {
      _isRolling = false;
      _processMove(true);
    });
  }

  void _processMove(bool isPlayer) {
    if (isPlayer) {
      if (_diceValue == 6 && _player1Pos == -1) {
        _player1Pos = 0;
        _message = "مهره اول وارد شد!";
      } else if (_player1Pos != -1) {
        _player1Pos += _diceValue;
        if (_player1Pos >= 40) {
          _endGame(true);
          return;
        }
      } else {
        _message = "برای شروع ۶ لازم است";
      }
      _isPlayerTurn = false;
      Future.delayed(const Duration(seconds: 1), _aiTurn);
    } else {
      if (_diceValue == 6 && _ai1Pos == -1) {
        _ai1Pos = 0;
      } else if (_ai1Pos != -1) {
        _ai1Pos += _diceValue;
        if (_ai1Pos >= 40) {
          _endGame(false);
          return;
        }
      }
      _isPlayerTurn = true;
    }
  }

  void _aiTurn() async {
    setState(() => _isRolling = true);
    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => _diceValue = Random().nextInt(6) + 1);
    }
    setState(() {
      _isRolling = false;
      _processMove(false);
    });
  }

  void _endGame(bool won) async {
    if (won) {
      await SoundManager.playWin();
      await DataManager.addWinReward(widget.stake);
    } else {
      await SoundManager.playLose();
      await DataManager.logGameEvent("باخت در منچ", widget.stake, -widget.stake);
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? 'پیروزی در منچ! 🏆' : 'شکست از هوش مصنوعی 😞'),
        actions: [
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('بازگشت'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('منچ سرعتی'), backgroundColor: Colors.indigo),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Text(_message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            // مسیر بازی (ساده شده)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 41,
                itemBuilder: (context, i) {
                  bool pAt = _player1Pos == i;
                  bool aAt = _ai1Pos == i;
                  return Container(
                    width: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: i == 40 ? Colors.amber[100] : Colors.grey[200],
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          if (pAt) const Icon(Icons.circle, color: Colors.blue, size: 20),
                          if (aAt) const Icon(Icons.circle, color: Colors.red, size: 20),
                          if (!pAt && !aAt) Text('$i', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPieceInfo("شما (آبی)", _player1Pos),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Text('$_diceValue', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _isPlayerTurn && !_isRolling ? _rollDice : null,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        child: const Text('تاس انداختن'),
                      ),
                    ],
                  ),
                  _buildPieceInfo("حریف (قرمز)", _ai1Pos),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieceInfo(String label, int pos) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(pos == -1 ? "در خانه" : "موقعیت: $pos"),
      ],
    );
  }
}
