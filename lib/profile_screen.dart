import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _adminClickCount = 0;

  void _editProfile() {
    final nameCtrl = TextEditingController(text: DataManager.userData['name']);
    final phoneCtrl = TextEditingController(text: DataManager.userData['phone']);

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ویرایش پروفایل', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'نام و نام خانوادگی', icon: Icon(Icons.person)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'شماره موبایل', icon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  DataManager.userData['name'] = nameCtrl.text;
                  DataManager.userData['phone'] = phoneCtrl.text;
                });
                await DataManager.saveData();
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تغییرات با موفقیت ذخیره شد'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DataManager.userData;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('پروفایل من'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // هدر پروفایل با طراحی زیبا
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.orange[800],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => _adminClickCount++);
                            if (_adminClickCount >= 5) {
                              _adminClickCount = 0;
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.orange[100],
                              backgroundImage: const NetworkImage('https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user['name'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          '@${user['username']}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // کارت موجودی کیف پول
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                    border: Border.all(color: Colors.orange[50]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('موجودی کیف پول', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                '${DataManager.balance}',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('شارژ حساب'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // اطلاعات شخصی
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone, 'شماره موبایل', user['phone']),
                    _buildInfoTile(Icons.calendar_month, 'تاریخ عضویت', user['joinDate']),
                    _buildInfoTile(Icons.verified_user, 'وضعیت حساب', 'تایید شده', isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // گزینه‌های دیگر
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuOption(Icons.history, 'تاریخچه بازی‌ها', Colors.blue, () {}),
                    _buildMenuOption(Icons.shopping_cart_checkout, 'سفارشات من', Colors.green, () {}),
                    _buildMenuOption(Icons.security, 'امنیت و حریم خصوصی', Colors.purple, () {}),
                    _buildMenuOption(Icons.help_center, 'پشتیبانی و تماس با ما', Colors.teal, () {}),
                    _buildMenuOption(Icons.logout, 'خروج از حساب کاربری', Colors.red, () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange[800], size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
