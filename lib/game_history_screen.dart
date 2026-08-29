import 'package:flutter/material.dart';
import 'data_manager.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('تاریخچه بازی‌ها'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: DataManager.gameHistory.isEmpty
            ? const Center(child: Text('هنوز بازی نکردید!'))
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: DataManager.gameHistory.length,
                itemBuilder: (context, index) {
                  final log = DataManager.gameHistory[index];
                  bool isWin = log['result'] > 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: Icon(
                        isWin ? Icons.trending_up : Icons.trending_down,
                        color: isWin ? Colors.green : Colors.red,
                        size: 30,
                      ),
                      title: Text(log['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${log['date']} | ${log['time']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('شرط: ${log['stake']}', style: const TextStyle(fontSize: 12)),
                          Text(
                            isWin ? '+${log['result']}' : '${log['result']}',
                            style: TextStyle(
                              color: isWin ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
