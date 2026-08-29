import 'package:flutter/material.dart';
import 'data_manager.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('جوایز و قرعه‌کشی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بنر زیبا برای جدیدترین قرعه‌کشی
              _buildFeaturedBanner(),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'قرعه‌کشی‌های فعال:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              // لیست قرعه‌کشی‌ها
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: DataManager.lotteryList.length,
                itemBuilder: (context, index) {
                  final lottery = DataManager.lotteryList[index];
                  return _buildLotteryCard(context, lottery);
                },
              ),

              const SizedBox(height: 20),
              
              // جدول اسامی برندگان
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'اسامی برندگان خوش‌شانس:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _buildWinnersTable(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    final banner = DataManager.lotteryBanner;
    String imagePath = banner['image'] ?? '';
    ImageProvider imageProvider;
    if (imagePath.startsWith('http')) {
      imageProvider = NetworkImage(imagePath);
    } else if (imagePath.isNotEmpty) {
      imageProvider = FileImage(File(imagePath));
    } else {
      imageProvider = const NetworkImage('https://via.placeholder.com/400x200');
    }

    return Container(
      margin: const EdgeInsets.all(15),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
              child: const Text('قرعه‌کشی ویژه هفته', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 10),
            Text(
              banner['title'],
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              banner['subtitle'],
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.orange[800]),
          columns: const [
            DataColumn(label: Text('نام برنده', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('جایزه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('تاریخ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: DataManager.winnersList.map((winner) {
            return DataRow(cells: [
              DataCell(Text(winner['name'])),
              DataCell(Text(winner['prize'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              DataCell(Text(winner['date'], style: const TextStyle(fontSize: 12))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLotteryCard(BuildContext context, Map<String, dynamic> lottery) {
    Color lotteryColor = Color(lottery['color_value'] ?? 0xFF000000);
    IconData iconData = IconData(lottery['icon_code'] ?? Icons.card_giftcard.codePoint, fontFamily: 'MaterialIcons');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: lotteryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: lotteryColor,
                  child: Icon(iconData, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lottery['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'جایزه: ${lottery['prize']}',
                        style: TextStyle(color: lotteryColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('زمان قرعه‌کشی:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(lottery['date'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _buyTicket(context, lottery);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    children: [
                      Text('خرید بلیط (${lottery['ticketPrice']}'),
                      const SizedBox(width: 5),
                      const Icon(Icons.monetization_on, size: 18, color: Colors.amber),
                      const Text(')'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _buyTicket(BuildContext context, Map<String, dynamic> lottery) {
    int price = lottery['ticketPrice'];
    String title = lottery['title'];

    if (DataManager.balance < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('موجودی سکه کافی نیست!'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('خرید بلیط شانس'),
          content: Text('آیا می‌خواهید با کسر $price سکه، در "$title" شرکت کنید؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  DataManager.balance -= price;
                });
                await DataManager.saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('بلیط شما برای "$title" با موفقیت ثبت شد. با آرزوی موفقیت!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
              child: const Text('تایید و خرید'),
            ),
          ],
        ),
      ),
    );
  }
}
