import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';
import 'awards_screen.dart';
import 'winners_screen.dart';
import 'news_screen.dart';
import 'data_manager.dart';

class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    String userName = DataManager.userData['name'] ?? 'کاربر عزیز';
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  image: DecorationImage(
                    image: NetworkImage('https://vjoxfkyvawvuzwscofog.supabase.co/storage/v1/object/public/assets/logo.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('سلام $userName!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'خوش‌حالیم که دوباره تو رو در دیدینو می‌بینیم. امیدواریم تجربه خوبی داشته باشی ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                  child: const Text('بزن بریم!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('دیدینو'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                ),
                child: Column(
                  children: [
                    // لوگو در هدر صفحه اصلی (نسخه کوچک)
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), image: const DecorationImage(image: NetworkImage('https://vjoxfkyvawvuzwscofog.supabase.co/storage/v1/object/public/assets/logo.jpg'), fit: BoxFit.cover)),
                    ),
                    const SizedBox(height: 15),
                    const Text('به مارکت بزرگ دیدینو خوش آمدید', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text('خدمات مجازی و جوایز میلیونی', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(15),
                child: GridView.count(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
                  children: [
                    _buildMenuCard(context, 'فروشگاه خدمات', Icons.shopping_bag, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen()))),
                    _buildMenuCard(context, 'جوایز و قرعه‌کشی', Icons.card_giftcard, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AwardsScreen()))),
                    _buildMenuCard(context, 'تالار برندگان', Icons.emoji_events, Colors.amber[700]!, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WinnersScreen()))),
                    _buildMenuCard(context, 'آخرین اخبار', Icons.campaign, Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen()))),
                    _buildMenuCard(context, 'پروفایل کاربری', Icons.person, Colors.grey, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))], border: Border.all(color: color.withOpacity(0.2), width: 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 50, color: color), const SizedBox(height: 10), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
      ),
    );
  }
}
