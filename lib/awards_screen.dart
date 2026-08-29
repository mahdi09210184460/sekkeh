import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data_manager.dart';
import 'dart:io';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  bool _isSyncing = false;

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
        ),
        body: _isSyncing 
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text('در حال ارسال درخواست به سرور...')]))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeaturedBanner(),
                  const SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('قرعه‌کشی‌های فعال:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: DataManager.lotteryList.length,
                    itemBuilder: (context, index) => _buildLotteryCard(context, DataManager.lotteryList[index]),
                  ),
                  const SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('اسامی برندگان خوش‌شانس:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
    if (imagePath.startsWith('http')) imageProvider = NetworkImage(imagePath);
    else if (imagePath.isNotEmpty) imageProvider = FileImage(File(imagePath));
    else imageProvider = const NetworkImage('https://via.placeholder.com/400x200');

    return Container(
      margin: const EdgeInsets.all(15), height: 180, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), image: DecorationImage(image: imageProvider, fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken))),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)), child: const Text('قرعه‌کشی ویژه هفته', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          const SizedBox(height: 10),
          Text(banner['title'] ?? '---', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(banner['subtitle'] ?? '---', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _buildWinnersTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.orange[800]),
          columns: const [
            DataColumn(label: Text('نام برنده', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('جایزه', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('تاریخ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: DataManager.winnersList.map((winner) => DataRow(cells: [
            DataCell(Text(winner['name'])),
            DataCell(Text(winner['prize'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
            DataCell(Text(winner['date'], style: const TextStyle(fontSize: 12))),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _buildLotteryCard(BuildContext context, Map<String, dynamic> lottery) {
    Color lotteryColor = Color(lottery['color_value'] ?? 0xFFE91E63);
    IconData iconData = IconData(lottery['icon_code'] ?? 0xe13f, fontFamily: 'MaterialIcons');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: lotteryColor.withOpacity(0.1), borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))), child: Row(children: [
          CircleAvatar(radius: 35, backgroundColor: lotteryColor, child: Icon(iconData, color: Colors.white, size: 35)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lottery['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            Text('جایزه: ${lottery['prize']}', style: TextStyle(color: lotteryColor, fontWeight: FontWeight.w600)),
          ])),
        ])),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('زمان قرعه‌کشی:', style: TextStyle(color: Colors.grey, fontSize: 12)), Text(lottery['date'], style: const TextStyle(fontWeight: FontWeight.w500))]),
            ElevatedButton(onPressed: () => _showLotteryPaymentInstructions(lottery), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text('خرید بلیط (${lottery['ticketPrice']} تومان)')),
          ]),
        ),
      ]),
    );
  }

  void _showLotteryPaymentInstructions(Map lottery) {
    showDialog(context: context, builder: (context) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: const Text('ثبت‌نام در قرعه‌کشی'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('مبلغ واریزی: ${lottery['ticketPrice']} تومان'),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue[50]), child: Column(children: [
          const Text('شماره کارت جهت واریز:', style: TextStyle(fontSize: 12)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(DataManager.appContent['card_number'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.copy), onPressed: () => Clipboard.setData(ClipboardData(text: DataManager.appContent['card_number']))),
          ]),
          Text('بنام: ${DataManager.appContent['card_name']}'),
        ])),
        const SizedBox(height: 15),
        const Text('پس از واریز مبلغ، دکمه تایید را بزنید تا درخواست شما به ادمین ارسال شود.', style: TextStyle(fontSize: 11, color: Colors.red)),
      ]),
      actions: [
        ElevatedButton(onPressed: () async {
          if (!await DataManager.hasInternet()) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای ثبت درخواست حتماً به اینترنت متصل باشید! 🌐'), backgroundColor: Colors.red));
            return;
          }
          Navigator.pop(context);
          setState(() => _isSyncing = true);
          
          DataManager.ordersList.insert(0, {
            'productName': 'بلیط: ${lottery['title']}',
            'quantity': 1,
            'totalPrice': lottery['ticketPrice'],
            'target': 'قرعه‌کشی',
            'date': DateTime.now().toString().substring(0, 10),
            'status': 'در انتظار تایید واریز'
          });
          
          await DataManager.saveLocally();
          bool success = await DataManager.syncOrderToServer();
          
          setState(() => _isSyncing = false);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درخواست شما با موفقیت برای ادمین ارسال شد ✅'), backgroundColor: Colors.green));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور! لطفاً دوباره تلاش کنید.'), backgroundColor: Colors.red));
          }
        }, child: const Text('واریز کردم، ثبت کن')),
      ],
    )));
  }
}
