import 'package:flutter/material.dart';
import 'data_manager.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('تاریخچه سفارشات من'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: DataManager.ordersList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 15),
                    const Text('هنوز هیچ سفارشی ثبت نکردید!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: DataManager.ordersList.length,
                itemBuilder: (context, index) {
                  final order = DataManager.ordersList[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              _buildStatusChip(order['status']),
                            ],
                          ),
                          const Divider(height: 25),
                          _buildInfoRow(Icons.numbers, 'تعداد:', '${order['quantity']}'),
                          _buildInfoRow(Icons.monetization_on, 'مبلغ پرداخت شده:', '${order['totalPrice']} سکه'),
                          _buildInfoRow(Icons.calendar_today, 'تاریخ ثبت:', order['date']),
                          if (order['target'] != null && order['target'].toString().isNotEmpty)
                            _buildInfoRow(Icons.link, 'آیدی/لینک مقصد:', order['target']),
                          if (order['note'] != null && order['note'].toString().isNotEmpty)
                            _buildInfoRow(Icons.description, 'یادداشت شما:', order['note']),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.orange;
    if (status == 'تکمیل شده') color = Colors.green;
    if (status == 'رد شده') color = Colors.red;
    if (status == 'در حال انجام') color = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
