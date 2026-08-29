import 'package:flutter/material.dart';
import 'data_manager.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('اخبار و اطلاعیه‌ها'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: DataManager.newsList.length,
          itemBuilder: (context, index) {
            final news = DataManager.newsList[index];
            return _buildNewsItem(news);
          },
        ),
      ),
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> news) {
    IconData iconData = IconData(news['icon_code'] ?? Icons.campaign.codePoint, fontFamily: 'MaterialIcons');
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: news['isNew'] ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: news['isNew'] ? Colors.orange[300]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: news['isNew'] ? Colors.orange[800] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: news['isNew'] ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: news['isNew'] ? Colors.orange[900] : Colors.black,
                      ),
                    ),
                    if (news['isNew'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'جدید',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  news['description'],
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      news['date'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
