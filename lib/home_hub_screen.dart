import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'shop_screen.dart';
import 'games_screen.dart';
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('سکه چی'),
          backgroundColor: Colors.orange[800],
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // بخش موجودی کاربر
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[800],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('موجودی کیف پول شما', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${DataManager.balance}',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'معادل: ${DataManager.balance * 1000} تومان',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.all(15),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildMenuCard(context, 'بازی‌های سکه چی', Icons.sports_esports, Colors.blue, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GamesScreen())).then((_) => setState(() {}));
                    }),
                    _buildMenuCard(context, 'فروشگاه طلایی', Icons.shopping_bag, Colors.green, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopScreen())).then((_) => setState(() {}));
                    }),
                    _buildMenuCard(context, 'جوایز و قرعه‌کشی', Icons.card_giftcard, Colors.purple, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AwardsScreen())).then((_) => setState(() {}));
                    }),
                    _buildMenuCard(context, 'تالار برندگان', Icons.emoji_events, Colors.amber[700]!, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const WinnersScreen()));
                    }),
                    _buildMenuCard(context, 'آخرین اخبار', Icons.campaign, Colors.redAccent, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen()));
                    }),
                    _buildMenuCard(context, 'پروفایل کاربری', Icons.person, Colors.grey, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    }),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
