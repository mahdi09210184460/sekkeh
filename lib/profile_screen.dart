import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'my_orders_screen.dart';
import 'app_info_screen.dart';
import 'register_screen.dart';
import 'data_manager.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _adminClickCount = 0;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        DataManager.userData['profileImage'] = image.path;
      });
      await DataManager.saveData();
    }
  }

  ImageProvider _getProfileImage() {
    String? path = DataManager.userData['profileImage'];
    if (path == null || path.isEmpty) {
      String gender = DataManager.userData['gender'] ?? 'آقا';
      return NetworkImage(gender == 'آقا'
          ? 'https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg'
          : 'https://img.freepik.com/free-vector/woman-avatar-profile-round-icon_24877-53559.jpg');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  void _showAdminLogin() {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ورود به پنل مدیریت', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(labelText: 'نام کاربری ادمین', prefixIcon: Icon(Icons.admin_panel_settings)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () {
                if (userCtrl.text == 'amin13912000' && passCtrl.text == 'amin1374') {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('دسترسی غیرمجاز!'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white),
              child: const Text('ورود به پنل'),
            ),
          ],
        ),
      ),
    );
  }

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
                            if (DataManager.userData['phone'] == '09927891608') {
                              setState(() => _adminClickCount++);
                              if (_adminClickCount >= 3) {
                                setState(() => _adminClickCount = 0);
                                _showAdminLogin();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.orange[100],
                              backgroundImage: _getProfileImage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user['name'] ?? 'بی‌نام',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          '@${user['username'] ?? 'user'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone, 'شماره موبایل', user['phone'] ?? '---'),
                    _buildInfoTile(Icons.calendar_month, 'تاریخ عضویت', user['joinDate'] ?? '---', isLast: true),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuOption(Icons.shopping_cart_checkout, 'سفارشات من', Colors.green, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
                    }),
                    _buildMenuOption(Icons.security, 'امنیت و حریم خصوصی', Colors.purple, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppInfoScreen(mode: 'security')));
                    }),
                    _buildMenuOption(Icons.help_center, 'پشتیبانی و تماس با ما', Colors.teal, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AppInfoScreen(mode: 'support')));
                    }),
                    _buildMenuOption(Icons.logout, 'خروج از حساب کاربری', Colors.red, () async {
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: const Text('خروج از حساب'),
                            content: const Text('آیا می‌خواهید از حساب خود خارج شوید؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                              ElevatedButton(
                                onPressed: () async {
                                  await DataManager.logout();
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('خروج نهایی'),
                              ),
                            ],
                          ),
                        ),
                      );
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
