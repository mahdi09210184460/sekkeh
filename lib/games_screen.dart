import 'package:flutter/material.dart';
import 'memory_game_screen.dart';
import 'lucky_wheel_screen.dart';
import 'quiz_game_screen.dart';
import 'tap_game_screen.dart';
import 'number_game_screen.dart';
import 'snake_ladder_game_screen.dart';
import 'ludo_game_screen.dart';
import 'data_manager.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final List<Map<String, dynamic>> _games = [
    {'name': 'مار و پله', 'reward': '۳۰٪ سود', 'icon': Icons.stairs, 'color': Colors.green},
    {'name': 'منچ سکه‌ای', 'reward': '۳۰٪ سود', 'icon': Icons.casino, 'color': Colors.indigo},
    {'name': 'ضربه طلایی', 'reward': '۳۰٪ سود', 'icon': Icons.touch_app, 'color': Colors.red},
    {'name': 'کوییز طلایی', 'reward': '۳۰٪ سود', 'icon': Icons.quiz, 'color': Colors.blue},
    {'name': 'حدس عدد جادویی', 'reward': '۳۰٪ سود', 'icon': Icons.help_center, 'color': Colors.teal},
    {'name': 'حافظه برتر', 'reward': '۳۰٪ سود', 'icon': Icons.psychology, 'color': Colors.purple},
    {'name': 'گردونه شانس', 'reward': 'متغیر', 'icon': Icons.track_changes, 'color': Colors.orange},
  ];

  void _showStakeDialog(String gameName) {
    if (gameName == 'گردونه شانس') {
      _startGame(gameName, 100); // افزایش هزینه ورودی به ۱۰۰ سکه
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('انتخاب مبلغ شرط‌بندی', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هرچه مبلغ بیشتر باشد، سود شما بیشتر است!', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildStakeOption(gameName, 50),
              _buildStakeOption(gameName, 100),
              _buildStakeOption(gameName, 500),
              _buildStakeOption(gameName, 1000),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStakeOption(String gameName, int amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _startGame(gameName, amount);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange[900],
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: Colors.orange[800]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$amount سکه', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('سود برد: ${(amount * 0.3).round()}+', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _startGame(String gameName, int stake) async {
    if (!DataManager.canPlay(stake)) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('موجودی ناکافی'),
            content: Text('برای این مبلغ شرط‌بندی حداقل به $stake سکه نیاز دارید.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('فهمیدم')),
            ],
          ),
        ),
      );
      return;
    }

    await DataManager.deductEntryFee(stake);
    setState(() {});

    Widget gameWidget;
    if (gameName == 'کوییز طلایی') gameWidget = QuizGameScreen(stake: stake);
    else if (gameName == 'ضربه طلایی') gameWidget = TapGameScreen(stake: stake);
    else if (gameName == 'حدس عدد جادویی') gameWidget = NumberGameScreen(stake: stake);
    else if (gameName == 'حافظه برتر') gameWidget = MemoryGameScreen(stake: stake);
    else if (gameName == 'گردونه شانس') gameWidget = const LuckyWheelScreen();
    else if (gameName == 'مار و پله') gameWidget = SnakeLadderGameScreen(stake: stake);
    else if (gameName == 'منچ سکه‌ای') gameWidget = LudoGameScreen(stake: stake);
    else return;

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> activeGames = DataManager.gameSettings['activeGames'] ?? {};
    final filteredGames = _games.where((game) => activeGames[game['name']] ?? true).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('کازینو سکه چی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Text('${DataManager.balance}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
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
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: const Text(
                'بازی کن، شرط ببند و ۳۰٪ سود ببر!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: filteredGames.length,
                itemBuilder: (context, index) {
                  final game = filteredGames[index];
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.orange[50]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: game['color'].withOpacity(0.1),
          child: Icon(game['icon'], color: game['color']),
        ),
        title: Text(game['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('جایزه برد: ${game['reward']}'),
        trailing: ElevatedButton(
          onPressed: () => _showStakeDialog(game['name']),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('شرط‌بندی'),
        ),
      ),
    );
  }
}
