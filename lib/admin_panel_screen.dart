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
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    await DataManager.fetchAllUsersForAdmin();
    setState(() => _isLoading = false);
  }

  Future<String?> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('مرکز فرماندهی سکه چی (آنلاین)'),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'مانیتورینگ کاربران'),
                Tab(text: 'سفارشات'),
                Tab(text: 'فروشگاه'),
                Tab(text: 'اخبار و جوایز'),
                Tab(text: 'تنظیمات'),
              ],
            ),
            actions: [
              IconButton(onPressed: _refreshUsers, icon: const Icon(Icons.refresh))
            ],
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUserMonitor(),
                  _buildOrdersManager(),
                  _buildShopManager(),
                  _buildContentManager(),
                  _buildGameSettings(),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildUserMonitor() {
    return ListView.builder(
      itemCount: DataManager.allUsers.length,
      itemBuilder: (context, index) {
        final user = DataManager.allUsers[index];
        final userData = user['user_data'] ?? {};
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(child: Text(userData['name'] != null ? userData['name'][0] : '?')),
            title: Text(userData['name'] ?? 'بدون نام'),
            subtitle: Text('شماره: ${user['phone']} | موجودی: ${user['balance']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showUserDetails(user),
          ),
        );
      },
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final history = List<Map<String, dynamic>>.from(user['game_history'] ?? []);
    final orders = List<Map<String, dynamic>>.from(user['orders_list'] ?? []);
    final userData = user['user_data'] ?? {};

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('جزئیات کاربر: ${user['phone']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('نام: ${userData['name'] ?? '---'}'),
                  Text('نام کاربری: ${userData['username'] ?? '---'}'),
                  const Divider(),
                  const Text('سوابق بازی:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...history.map((h) => Text('• ${h['title']} (${h['stake']} سکه) -> نتیجه: ${h['result']}')),
                  const Divider(),
                  const Text('تاریخچه خریدها:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...orders.map((o) => Text('• ${o['productName']} (${o['status']})')),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
        ),
      ),
    );
  }

  // بقیه متدها با فراخوانی DataManager.saveGlobalConfig() به‌روزرسانی می‌شوند...

  Widget _buildShopManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('افزودن به مارکت سرور'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: DataManager.shopProducts.length,
            itemBuilder: (context, index) {
              final prod = DataManager.shopProducts[index];
              return ListTile(
                leading: Image.network(prod['image'], width: 40, errorBuilder: (c,e,s) => const Icon(Icons.image)),
                title: Text(prod['name']),
                subtitle: Text('${prod['price']} سکه'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    setState(() => DataManager.shopProducts.removeAt(index));
                    await DataManager.saveGlobalConfig();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddProductDialog({Map<String, dynamic>? product, int? index}) {
    final nameCtrl = TextEditingController(text: product?['name'] ?? '');
    final priceCtrl = TextEditingController(text: product != null ? '${product['price']}' : '');
    String category = product?['category'] ?? 'کالای دیجیتال';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن کالا به سرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام')),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'قیمت'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final newProd = {
                'name': nameCtrl.text,
                'price': int.parse(priceCtrl.text),
                'desc': 'محصول آنلاین',
                'image': 'https://via.placeholder.com/150',
                'category': category
              };
              setState(() {
                if (index == null) DataManager.shopProducts.add(newProd);
                else DataManager.shopProducts[index] = newProd;
              });
              await DataManager.saveGlobalConfig();
              Navigator.pop(context);
            },
            child: const Text('ارسال به سرور'),
          )
        ],
      ),
    );
  }

  // سایر بخش‌های مدیریت محتوا مشابه هستند و از saveGlobalConfig استفاده می‌کنند
  Widget _buildContentManager() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('مدیریت اخبار و جوایز آنلاین', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // پیاده‌سازی فیلدهای اخبار و جوایز با دکمه آپدیت دیتابیس
          ElevatedButton(
            onPressed: () async => await DataManager.saveGlobalConfig(),
            child: const Text('بروزرسانی کل محتوا در دیتابیس ابری'),
          )
        ],
      ),
    );
  }

  Widget _buildOrdersManager() {
    return ListView.builder(
      itemCount: DataManager.ordersList.length,
      itemBuilder: (context, index) {
        final order = DataManager.ordersList[index];
        return ListTile(
          title: Text(order['productName']),
          subtitle: Text('وضعیت: ${order['status']}'),
          trailing: IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () async {
              setState(() => order['status'] = 'تکمیل شده');
              await DataManager.saveData(); // ذخیره تغییرات کاربر خاص
            },
          ),
        );
      },
    );
  }

  Widget _buildGameSettings() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('تنظیمات سرور اپلیکیشن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await DataManager.saveGlobalConfig();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تنظیمات در کلود ذخیره شد')));
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange[800]),
            child: const Text('همگام‌سازی با سرور', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
