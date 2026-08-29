import 'package:flutter/material.dart';
import 'data_manager.dart';

class WinnersScreen extends StatelessWidget {
  const WinnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('تالار افتخارات'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.orange[800],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: const [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 70),
                  SizedBox(height: 10),
                  Text(
                    'برندگان خوش‌شانس دیدینو',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'شاید نام شما در لیست بعدی باشد!',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: DataManager.winnersList.length,
                itemBuilder: (context, index) {
                  final winner = DataManager.winnersList[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[100],
                        child: Icon(Icons.person, color: Colors.orange[800]),
                      ),
                      title: Text(winner['name'] ?? 'بی‌نام', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('جایزه: ${winner['prize'] ?? '---'}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                      trailing: Text(winner['date'] ?? '---', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
