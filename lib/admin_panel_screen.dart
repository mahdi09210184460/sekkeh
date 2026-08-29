import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data_manager.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);
    try {
      await DataManager.loadData();
      await DataManager.fetchAllUsersForAdmin();
    } catch (e) {
      _showError("خطا: $e");
    }
    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  Future<String?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Widget _buildImagePreview(String? path) {
    if (path == null || path.isEmpty) {
      return Container(height: 80, width: 80, color: Colors.grey[200], child: const Icon(Icons.image));
    }
    if (path.startsWith('http')) {
      return Image.network(path, height: 80, width: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image));
    }
    return Image.file(File(path), height: 80, width: 80, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('پنل مدیریت دیدینو'),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'کاربران'), Tab(text: 'سفارشات/واریزی‌ها'), Tab(text: 'فروشگاه'),
                Tab(text: 'محتوا و تنظیمات'),
              ],
            ),
            actions: [IconButton(onPressed: _refreshAll, icon: const Icon(Icons.refresh))],
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUserMonitor(), _buildOrdersManager(), _buildShopManager(),
                  _buildAppSettings(),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildUserMonitor() {
    if (DataManager.allUsers.isEmpty) return const Center(child: Text('کاربری یافت نشد.'));
    return ListView.builder(
      itemCount: DataManager.allUsers.length,
      itemBuilder: (context, index) {
        final user = DataManager.allUsers[index];
        final userData = user['user_data'] ?? {};
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(child: Text(userData['name']?[0] ?? '?')),
            title: Text(userData['name'] ?? 'بدون نام'),
            subtitle: Text('شماره: ${user['phone']}'),
            onTap: () => _showUserDetails(user),
          ),
        );
      },
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final orders = List<Map<String, dynamic>>.from(user['orders_list'] ?? []);
    final userData = user['user_data'] ?? {};

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('جزئیات: ${user['phone']}'),
          content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('نام: ${userData['name']}'),
              Text('نام کاربری: ${userData['username']}'),
              Text('رمز عبور: ${userData['password']}'),
              const Divider(),
              const Text('سوابق سفارشات:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (orders.isEmpty) const Text('سفارشی ندارد'),
              ...orders.map((o) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text('• ${o['productName']} (${o['totalPrice']}ت) - ${o['status']}\n  هدف: ${o['target']}'),
              )),
            ]),
          )),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
        ),
      ),
    );
  }

  Widget _buildOrdersManager() {
    List<Map<String, dynamic>> allOrders = [];
    for (var u in DataManager.allUsers) {
      List orders = u['orders_list'] ?? [];
      for (var o in orders) allOrders.add({...o, 'uPhone': u['phone'], 'uName': u['user_data']['name']});
    }
    if (allOrders.isEmpty) return const Center(child: Text('سفارشی ثبت نشده است.'));
    
    // لیست استاتوس‌های استاندارد
    final List<String> statusOptions = [
      'در انتظار تایید واریز',
      'واریز تایید شد',
      'در حال انجام',
      'تکمیل شده',
      'رد شده'
    ];

    return ListView.builder(
      itemCount: allOrders.length,
      itemBuilder: (context, i) {
        final order = allOrders[i];
        bool isPending = order['status'] == 'در انتظار تایید واریز';
        
        return Card(
          margin: const EdgeInsets.all(10),
          color: isPending ? Colors.blue[50] : Colors.white,
          child: ExpansionTile(
            title: Text(order['productName']),
            subtitle: Text('کاربر: ${order['uName']} | مبلغ: ${order['totalPrice']} تومان'),
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('تعداد: ${order['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('آیدی/لینک هدف: ${order['target']}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('کیفیت انتخاب شده: ${order['quality'] ?? 'نامشخص'}'),
                  const SizedBox(height: 5),
                  Text('شماره تماس هماهنگی: ${order['contact'] ?? 'ثبت نشده'}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 5),
                  Text('توضیح کاربر: ${order['note'] ?? '---'}'),
                  const SizedBox(height: 5),
                  Text('تاریخ و زمان: ${order['date']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const Divider(),
                  const Text('تغییر وضعیت سفارش:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: statusOptions.contains(order['status']) ? order['status'] : statusOptions[0],
                    items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) async {
                      int uIdx = DataManager.allUsers.indexWhere((u) => u['phone'] == order['uPhone']);
                      if (uIdx != -1) {
                        List uOrders = DataManager.allUsers[uIdx]['orders_list'];
                        int oIdx = uOrders.indexWhere((o) => o['productName'] == order['productName'] && o['date'] == order['date']);
                        if (oIdx != -1) {
                          setState(() => uOrders[oIdx]['status'] = val);
                          await DataManager.saveSpecificUserToCloud(DataManager.allUsers[uIdx]);
                          _showSuccess("وضعیت سفارش به '$val' تغییر یافت");
                        }
                      }
                    },
                  ),
                ]),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopManager() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton.icon(onPressed: () => _showAddProductDialog(), icon: const Icon(Icons.add), label: const Text('افزودن محصول جدید'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green, foregroundColor: Colors.white)),
      ),
      Expanded(child: ListView.builder(
        itemCount: DataManager.shopProducts.length,
        itemBuilder: (context, i) {
          final p = DataManager.shopProducts[i];
          return ListTile(
            leading: _buildImagePreview(p['image']),
            title: Text(p['name']),
            subtitle: Text('${p['price']} تومان'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddProductDialog(product: p, index: i)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                setState(() => DataManager.shopProducts.removeAt(i));
                await DataManager.saveGlobalConfig();
              }),
            ]),
          );
        },
      ))
    ]);
  }

  void _showAddProductDialog({Map? product, int? index}) {
    final n = TextEditingController(text: product?['name'] ?? '');
    final p = TextEditingController(text: product != null ? '${product['price']}' : '');
    final d = TextEditingController(text: product?['desc'] ?? '');
    String? img = product?['image'];
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, st) => Directionality(textDirection: TextDirection.rtl, child: AlertDialog(
      title: const Text('جزئیات محصول'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: () async { String? path = await _pickImage(); if (path != null) st(() => img = path); }, child: _buildImagePreview(img)),
        TextField(controller: n, decoration: const InputDecoration(labelText: 'نام محصول')),
        TextField(controller: p, decoration: const InputDecoration(labelText: 'قیمت (تومان)'), keyboardType: TextInputType.number),
        TextField(controller: d, decoration: const InputDecoration(labelText: 'توضیحات')),
      ])),
      actions: [ElevatedButton(onPressed: () async {
        final np = {'name': n.text, 'price': int.parse(p.text), 'desc': d.text, 'image': img ?? '', 'category': 'خدمات'};
        setState(() { if (index == null) DataManager.shopProducts.add(np); else DataManager.shopProducts[index] = np; });
        await DataManager.saveGlobalConfig(); Navigator.pop(context);
      }, child: const Text('ذخیره'))],
    ))));
  }

  Widget _buildAppSettings() {
    final securityCtrl = TextEditingController(text: DataManager.appContent['security_policy']);
    final supportCtrl = TextEditingController(text: DataManager.appContent['support_info']);
    final cardNoCtrl = TextEditingController(text: DataManager.appContent['card_number']);
    final cardNameCtrl = TextEditingController(text: DataManager.appContent['card_name']);

    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اطلاعات بانکی جهت واریز کاربران', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
      const SizedBox(height: 10),
      TextField(decoration: const InputDecoration(labelText: 'شماره کارت مدیریت', border: OutlineInputBorder()), controller: cardNoCtrl),
      const SizedBox(height: 10),
      TextField(decoration: const InputDecoration(labelText: 'نام صاحب حساب', border: OutlineInputBorder()), controller: cardNameCtrl),
      const SizedBox(height: 30),
      const Text('سیاست‌ها و پشتیبانی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 10),
      TextField(decoration: const InputDecoration(labelText: 'سیاست امنیت'), controller: securityCtrl, maxLines: 3),
      const SizedBox(height: 10),
      TextField(decoration: const InputDecoration(labelText: 'اطلاعات پشتیبانی'), controller: supportCtrl, maxLines: 2),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () async {
        setState(() {
          DataManager.appContent['security_policy'] = securityCtrl.text;
          DataManager.appContent['support_info'] = supportCtrl.text;
          DataManager.appContent['card_number'] = cardNoCtrl.text;
          DataManager.appContent['card_name'] = cardNameCtrl.text;
        });
        await DataManager.saveGlobalConfig();
        _showSuccess("تنظیمات با موفقیت ذخیره شد");
      }, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue[800], foregroundColor: Colors.white), child: const Text('بروزرسانی کل تنظیمات')),
      const Divider(height: 50),
      const Text('مدیریت اخبار و جوایز', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ListTile(title: const Text('مدیریت اخبار'), trailing: const Icon(Icons.chevron_right), onTap: () => _showContentManagement('news')),
      ListTile(title: const Text('مدیریت قرعه‌کشی‌ها'), trailing: const Icon(Icons.chevron_right), onTap: () => _showContentManagement('lottery')),
      ListTile(title: const Text('مدیریت برندگان'), trailing: const Icon(Icons.chevron_right), onTap: () => _showContentManagement('winners')),
    ]));
  }

  void _showContentManagement(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('مدیریت $type', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: type == 'news' ? DataManager.newsList.length : (type == 'lottery' ? DataManager.lotteryList.length : DataManager.winnersList.length),
                  itemBuilder: (context, i) {
                    var item = type == 'news' ? DataManager.newsList[i] : (type == 'lottery' ? DataManager.lotteryList[i] : DataManager.winnersList[i]);
                    return ListTile(
                      title: Text(item['title'] ?? item['name'] ?? '---'),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                        setState(() {
                          if (type == 'news') DataManager.newsList.removeAt(i);
                          else if (type == 'lottery') DataManager.lotteryList.removeAt(i);
                          else DataManager.winnersList.removeAt(i);
                        });
                        await DataManager.saveGlobalConfig();
                        Navigator.pop(context);
                      }),
                    );
                  },
                ),
              ),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))
            ],
          ),
        ),
      ),
    );
  }
}
