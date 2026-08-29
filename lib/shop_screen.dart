import 'package:flutter/material.dart';
import 'charge_screen.dart';
import 'data_manager.dart';
import 'sound_manager.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'همه';
  late TabController _tabController;

  final List<String> _categories = ['همه', 'کالای دیجیتال', 'خدمات مجازی', 'پوشاک', 'کارت هدیه'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  void _buyProduct(Map<String, dynamic> product) {
    int quantity = 1;
    final targetCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int totalPrice = product['price'] * quantity;
          bool isVirtual = product['category'] == 'خدمات مجازی' || product['name'].contains('فالوور');

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Text('خرید ${product['name']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // انتخاب تعداد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('تعداد:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => setDialogState(() => quantity++),
                            ),
                            Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                if (quantity > 1) setDialogState(() => quantity--);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    // فیلد مخصوص خدمات مجازی (آیدی یا لینک)
                    if (isVirtual) ...[
                      TextField(
                        controller: targetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'آیدی پیج یا لینک مقصد',
                          hintText: '@username / link...',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    // توضیحات اضافی
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'توضیحات یا یادداشت',
                        hintText: 'مثلاً: سایز مدیوم، رنگ آبی و...',
                        prefixIcon: Icon(Icons.note_alt),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // جمع کل
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('مبلغ قابل پرداخت:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Text('$totalPrice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                ElevatedButton(
                  onPressed: () async {
                    if (DataManager.balance < totalPrice) {
                      SoundManager.playLose();
                      Navigator.pop(context); // بستن دیالوگ خرید
                      showDialog(
                        context: context,
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: const Text('موجودی ناکافی'),
                            content: const Text('سکه کافی ندارید! آیا می‌خواهید حساب خود را شارژ کنید؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChargeScreen())).then((_) => setState(() {}));
                                },
                                child: const Text('بله، شارژ حساب'),
                              ),
                            ],
                          ),
                        ),
                      );
                      return;
                    }

                    if (isVirtual && targetCtrl.text.isEmpty) {
                      _showMessage('لطفاً آیدی یا لینک مقصد را وارد کنید!', isError: true);
                      return;
                    }

                    // ثبت سفارش در سیستم
                    setState(() {
                      DataManager.balance -= totalPrice;
                      DataManager.ordersList.insert(0, {
                        'productName': product['name'],
                        'quantity': quantity,
                        'totalPrice': totalPrice,
                        'target': targetCtrl.text,
                        'note': noteCtrl.text,
                        'date': '۱۴۰۵/۰۶/۰۷', // تاریخ امروز
                        'status': 'در حال بررسی'
                      });
                    });

                    await DataManager.saveData();
                    await SoundManager.playWin();
                    if (!mounted) return;
                    Navigator.pop(context);
                    _showMessage('سفارش شما با موفقیت ثبت شد و در حال بررسی است! 🎉');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('تایید و پرداخت نهایی'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = _selectedCategory == 'همه'
        ? DataManager.shopProducts
        : DataManager.shopProducts.where((p) => p['category'] == _selectedCategory).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('فروشگاه طلایی', style: TextStyle(fontWeight: FontWeight.bold)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://img.freepik.com/free-photo/shopping-cart-with-gift-boxes-inside-it-blue-background_23-2148287515.jpg',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Positioned(
                      bottom: 50,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${DataManager.balance}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(width: 5),
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: _categories.map((cat) {
                      bool isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                          },
                          selectedColor: Colors.orange[800],
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductItem(product);
                  },
                  childCount: filteredProducts.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    String imagePath = product['image'] ?? '';
    Widget imageWidget;
    if (imagePath.startsWith('http')) {
      imageWidget = Image.network(imagePath, width: double.infinity, fit: BoxFit.cover);
    } else if (imagePath.isNotEmpty) {
      imageWidget = Image.file(File(imagePath), width: double.infinity, fit: BoxFit.cover);
    } else {
      imageWidget = const Icon(Icons.image, size: 50);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: Colors.orange[50]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              child: Stack(
                children: [
                  imageWidget,
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Text(product['category'] ?? 'عمومی', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  product['desc'],
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${product['price']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                        ),
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                      ],
                    ),
                    InkWell(
                      onTap: () => _buyProduct(product),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange[800], shape: BoxShape.circle),
                        child: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
