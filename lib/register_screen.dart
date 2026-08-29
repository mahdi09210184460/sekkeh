import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_hub_screen.dart';
import 'data_manager.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = 'آقا';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('ثبت‌نام در دیدینو', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                ),
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    // لوگوی جدید دیدینو
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage('https://vjoxfkyvawvuzwscofog.supabase.co/storage/v1/object/public/assets/logo.jpg'), // لینک فرضی لوگو یا فایلی که فرستادید
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('به خانواده بزرگ دیدینو خوش آمدید', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(controller: _nameController, label: 'نام و نام خانوادگی', icon: Icons.person),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _usernameController, label: 'نام کاربری', icon: Icons.account_circle),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _phoneController, label: 'شماره موبایل', icon: Icons.phone_android, keyboardType: TextInputType.phone),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _passwordController, label: 'رمز عبور', icon: Icons.lock, isPassword: true),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('جنسیت:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 20),
                          ChoiceChip(label: const Text('آقا'), selected: _selectedGender == 'آقا', onSelected: (val) => setState(() => _selectedGender = 'آقا')),
                          const SizedBox(width: 10),
                          ChoiceChip(label: const Text('خانم'), selected: _selectedGender == 'خانم', onSelected: (val) => setState(() => _selectedGender = 'خانم')),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              DataManager.userData = {
                                'name': _nameController.text,
                                'username': _usernameController.text,
                                'phone': _phoneController.text,
                                'password': _passwordController.text,
                                'gender': _selectedGender,
                                'joinDate': DateTime.now().toString().substring(0, 10),
                                'profileImage': _selectedGender == 'آقا' 
                                  ? 'https://img.freepik.com/free-vector/businessman-character-avatar-isolated_24877-60111.jpg' 
                                  : 'https://img.freepik.com/free-vector/woman-avatar-profile-round-icon_24877-53559.jpg',
                              };
                              await DataManager.saveLocally();
                              setState(() => _isLoading = false);
                              if (!mounted) return;
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeHubScreen()));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ایجاد حساب و ورود به دنیای دیدینو', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        child: const Text('قبلاً عضو شده‌اید؟ وارد شوید'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange[800]),
        filled: true,
        fillColor: Colors.orange[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'اجباری' : null,
    );
  }
}
