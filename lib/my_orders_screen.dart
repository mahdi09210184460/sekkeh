import 'package:flutter/material.dart';
import 'data_manager.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = false;

  Future<void> _refreshOrders() async {
    setState(() => _isLoading = true);
    // همگام‌سازی اطلاعات کاربر از سرور برای دیدن آخرین وضعیت سفارشات
    if (DataManager.userData['phone'] != null) {
      await DataManager.syncUserWithServer(DataManager.userData['phone']);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('پیگیری سفارشات من'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(onPressed: _refreshOrders, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : DataManager.ordersList.isEmpty
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(order['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87))),
                              _buildStatusChip(order['status']),
                            ],
                          ),
                          const Divider(height: 30),
                          _buildInfoRow(Icons.numbers, 'تعداد سفارش:', '${order['quantity']}'),
                          _buildInfoRow(Icons.payments_outlined, 'مبلغ نهایی:', '${order['totalPrice']} تومان'),
                          _buildInfoRow(Icons.access_time, 'زمان ثبت:', order['date']),
                          if (order['target'] != null && order['target'].isNotEmpty)
                            _buildInfoRow(Icons.link, 'هدف (آیدی/لینک):', order['target'], color: Colors.blue),
                          if (order['quality'] != null)
                            _buildInfoRow(Icons.verified_user_outlined, 'کیفیت انتخابی:', order['quality']),
                          
                          const SizedBox(height: 15),
                          // نمایش گرافیکی مراحل (استپ)
                          _buildOrderStepper(order['status']),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOrderStepper(String status) {
    int currentStep = 0;
    if (status == 'واریز تایید شد') currentStep = 1;
    if (status == 'در حال انجام') currentStep = 2;
    if (status == 'تکمیل شده') currentStep = 3;
    if (status == 'رد شده') return const SizedBox();

    return Column(
      children: [
        const Text('وضعیت لحظه‌ای سفارش:', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 10),
        Row(
          children: [
            _stepIcon(Icons.payment, currentStep >= 0),
            _stepLine(currentStep >= 1),
            _stepIcon(Icons.check_circle_outline, currentStep >= 1),
            _stepLine(currentStep >= 2),
            _stepIcon(Icons.settings_suggest, currentStep >= 2),
            _stepLine(currentStep >= 3),
            _stepIcon(Icons.auto_awesome, currentStep >= 3),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('ثبت', style: TextStyle(fontSize: 9)),
              Text('تایید واریز', style: TextStyle(fontSize: 9)),
              Text('در حال انجام', style: TextStyle(fontSize: 9)),
              Text('پایان', style: TextStyle(fontSize: 9)),
            ],
          ),
        )
      ],
    );
  }

  Widget _stepIcon(IconData icon, bool active) {
    return Icon(icon, size: 20, color: active ? Colors.green : Colors.grey[300]);
  }

  Widget _stepLine(bool active) {
    return Expanded(child: Container(height: 2, color: active ? Colors.green : Colors.grey[300]));
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.orange;
    if (status == 'واریز تایید شد') color = Colors.blue;
    if (status == 'در حال انجام') color = Colors.purple;
    if (status == 'تکمیل شده') color = Colors.green;
    if (status == 'رد شده') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? Colors.black87))),
        ],
      ),
    );
  }
}
