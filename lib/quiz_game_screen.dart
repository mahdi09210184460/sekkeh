import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'sound_manager.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _isAnswered = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'کدام فلز در دمای اتاق به صورت مایع است؟',
      'options': ['جیوه', 'سدیم', 'پتاسیم', 'منیزیم'],
      'ans': 0
    },
    {
      'q': 'بزرگترین قاره جهان کدام است؟',
      'options': ['آفریقا', 'آمریکا', 'آسیا', 'اروپا'],
      'ans': 2
    },
    {
      'q': 'کدام سیاره به سیاره سرخ معروف است؟',
      'options': ['زهره', 'مشتری', 'مریخ', 'زحل'],
      'ans': 2
    },
  ];

  void _answer(int index) {
    if (_isAnswered) return;
    SoundManager.playTap();
    setState(() {
      _selectedOption = index;
      _isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (index == _questions[_currentQuestion]['ans']) {
        if (_currentQuestion < _questions.length - 1) {
          setState(() {
            _currentQuestion++;
            _selectedOption = null;
            _isAnswered = false;
          });
        } else {
          _endGame(true);
        }
      } else {
        _endGame(false);
      }
    });
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
          title: Text(won ? 'نابغه سکه چی! 🎉' : 'کمی مطالعه بیشتر! ❌', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(won ? Icons.lightbulb : Icons.auto_stories, size: 70, color: won ? Colors.amber : Colors.grey),
              const SizedBox(height: 15),
              Text(won ? 'پاسخ‌های شما صحیح بود و ۱۵ سکه جایزه گرفتید.' : 'پاسخ اشتباه بود. دوباره تلاش کنید!'),
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
    final question = _questions[_currentQuestion];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('کوییز طلایی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: Colors.orange[50],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: Text(
                  question['q'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, i) {
                    Color btnColor = Colors.white;
                    if (_isAnswered) {
                      if (i == question['ans']) btnColor = Colors.green[100]!;
                      else if (i == _selectedOption) btnColor = Colors.red[100]!;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () => _answer(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 60,
                          decoration: BoxDecoration(
                            color: btnColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _selectedOption == i ? Colors.orange : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              question['options'][i],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
