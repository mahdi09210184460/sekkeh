import 'package:flutter/material.dart';
import 'memory_game_screen.dart';
import 'lucky_wheel_screen.dart';
import 'quiz_game_screen.dart';
import 'tap_game_screen.dart';
import 'number_game_screen.dart';
import 'data_manager.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final List<Map<String, dynamic>> _games = [
    {'name': 'کوییز سکه‌ای', 'reward': '${DataManager.gameSettings['winReward']} سکه سود', 'icon': Icons.quiz, 'color': Colors.blue},
    {'name': 'ضربه طلایی', 'reward': '${DataManager.gameSettings['winReward']} سکه سود', 'icon': Icons.touch_app, 'color': Colors.red},
    {'name': 'حدس عدد سخت', 'reward': '${DataManager.gameSettings['winReward']} سکه سود', 'icon': Icons.help_center, 'color': Colors.green},
    {'name': 'حافظه برتر', 'reward': '${DataManager.gameSettings['winReward']} سکه سود', 'icon': Icons.psychology, 'color': Colors.purple},
    {'name': 'گردونه شانس', 'reward': 'متغیر', 'icon': Icons.track_changes, 'color': Colors.orange},
  ];

  void _tryStartGame(String gameName) async {
    if (!DataManager.canPlay()) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('موجودی ناکافی'),
            content: Text('برای ورود به بازی حداقل به ${DataManager.gameSettings['entryFee']} سکه نیاز دارید.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('فهمیدم')),
            ],
          ),
        ),
      );
      return;
    }

    // کسر ورودی
    await DataManager.deductEntryFee();
    setState(() {});

    // هدایت به بازی مربوطه
    Widget gameWidget;
    if (gameName == 'کوییز سکه‌ای') gameWidget = const QuizGameScreen();
    else if (gameName == 'ضربه طلایی') gameWidget = const TapGameScreen();
    else if (gameName == 'حدس عدد سخت') gameWidget = const NumberGameScreen();
    else if (gameName == 'حافظه برتر') gameWidget = const MemoryGameScreen();
    else if (gameName == 'گردونه شانس') gameWidget = const LuckyWheelScreen();
    else return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    ).then((_) {
      // بعد از بازگشت از بازی، موجودی را آپدیت کن
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('بازی‌های سکه چی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text('${DataManager.balance}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(Icons.monetization_on, color: Colors.amber),
                ],
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              color: Colors.red[50],
              child: Text(
                'ورود: ${DataManager.gameSettings['entryFee']} سکه | برد: +${DataManager.gameSettings['winReward']} سکه سود',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _buildGameItem(game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameItem(Map<String, dynamic> game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
        border: Border.all(color: Colors.orange[50]!),
      ),
      child: ListTile(
        leading: Icon(game['icon'], color: game['color'], size: 30),
        title: Text(game['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('جایزه برد: ${game['reward']}'),
        trailing: ElevatedButton(
          onPressed: () => _tryStartGame(game['name']),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
          child: const Text('پرداخت و شروع'),
        ),
      ),
    );
  }
}
