import 'package:flutter/material.dart';
import 'data_manager.dart';
import 'sound_manager.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'همه';
  late TabController _tabController;
  bool _isSyncing = false;

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
    final contactCtrl = TextEditingController(text: DataManager.userData['phone']);
    String quality = 'معمولی';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int totalPrice = product['price'] * quantity;
          bool isVirtual = product['category'] == 'خدمات مجازی' || product['name'].contains('فالوور') || product['name'].contains('لایک');

          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: Text('سفارش ${product['name']}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // انتخاب تعداد
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تعداد سفارش:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(children: [
                            IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setDialogState(() => quantity++)),
                            Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () { if (quantity > 1) setDialogState(() => quantity--); }),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // فیلد آیدی یا لینک (برای خدمات مجازی)
                    if (isVirtual) ...[
                      TextField(
                        controller: targetCtrl,
                        decoration: InputDecoration(
                          labelText: 'آیدی پیج یا لینک پست/کانال',
                          hintText: 'مثال: @username یا لینک مستقیم',
                          prefixIcon: const Icon(Icons.link, color: Colors.blue),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // انتخاب کیفیت
                      DropdownButtonFormField<String>(
                        value: quality,
                        decoration: InputDecoration(
                          labelText: 'نوع سرویس/کیفیت',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        items: ['معمولی', 'باکیفیت (بدون ریزش)', 'فوری (اکسپرس)'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setDialogState(() => quality = v!),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // فیلد تماس ضروری
                    TextField(
                      controller: contactCtrl,
                      decoration: InputDecoration(
                        labelText: 'شماره تماس جهت هماهنگی',
                        prefixIcon: const Icon(Icons.phone_android, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    // توضیحات
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'توضیحات تکمیلی (رنگ، سایز یا ...)',
                        prefixIcon: const Icon(Icons.note_alt, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // مبلغ نهایی
                    Container(
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.green[200]!)),
                      child: Column(
                        children: [
                          const Text('مبلغ نهایی قابل پرداخت:', style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 5),
                          Text('$totalPrice تومان', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                ElevatedButton(
                  onPressed: () {
                    if (isVirtual && targetCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وارد کردن آیدی یا لینک مقصد الزامی است!')));
                      return;
                    }
                    if (contactCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره تماس الزامی است!')));
                      return;
                    }
                    Navigator.pop(context);
                    _showPaymentInstructions(product, quantity, totalPrice, targetCtrl.text, noteCtrl.text, contactCtrl.text, quality);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: const Text('تایید و دریافت شماره کارت'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentInstructions(Map product, int qty, int price, String target, String note, String contact, String quality) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [Icon(Icons.payment, color: Colors.green), SizedBox(width: 10), Text('اطلاعات واریز و ثبت نهایی')]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('لطفاً مبلغ زیر را به کارت مدیریت واریز نمایید:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
              Text('$price تومان', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue[100]!)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DataManager.appContent['card_number'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        IconButton(icon: const Icon(Icons.copy, size: 20), onPressed: () {
                          Clipboard.setData(ClipboardData(text: DataManager.appContent['card_number']));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره کارت کپی شد')));
                        }),
                      ],
                    ),
                    Text('به نام: ${DataManager.appContent['card_name']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('⚠️ نکته: بعد از واریز، روی دکمه زیر کلیک کنید تا تمام جزئیات برای ادمین ارسال شود.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.red)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (!await DataManager.hasInternet()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای ثبت نهایی حتماً به اینترنت وصل شوید! 🌐')));
                  return;
                }
                Navigator.pop(context);
                setState(() => _isSyncing = true);
                
                DataManager.ordersList.insert(0, {
                  'productName': product['name'],
                  'quantity': qty,
                  'totalPrice': price,
                  'target': target,
                  'quality': quality,
                  'contact': contact,
                  'note': note,
                  'date': DateTime.now().toString().substring(0, 19), // زمان دقیق
                  'status': 'در انتظار تایید واریز'
                });
                
                await DataManager.saveLocally();
                bool success = await DataManager.syncOrderToServer();
                
                setState(() => _isSyncing = false);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سفارش با موفقیت ثبت شد! ادمین به زودی بررسی می‌کند. ✅'), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ارسال به سرور! لطفاً دوباره تلاش کنید.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              child: const Text('واریز کردم، ثبت نهایی کن'),
            ),
          ],
        ),
      ),
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
        body: _isSyncing 
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 10), Text('در حال ثبت سفارش در دیدینو...')]))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0, 
                  pinned: true, 
                  backgroundColor: Colors.orange[800], 
                  foregroundColor: Colors.white, 
                  flexibleSpace: FlexibleSpaceBar(title: const Text('فروشگاه خدمات', style: TextStyle(fontWeight: FontWeight.bold)))
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(children: _categories.map((cat) => Padding(padding: const EdgeInsets.only(left: 10), child: ChoiceChip(label: Text(cat), selected: _selectedCategory == cat, onSelected: (val) => setState(() => _selectedCategory = cat), selectedColor: Colors.orange[800], labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.black)))).toList())
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 15, mainAxisSpacing: 15),
                    delegate: SliverChildBuilderDelegate((context, index) => _buildProductItem(filteredProducts[index]), childCount: filteredProducts.length),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    String img = product['image'] ?? '';
    Widget imgW = img.startsWith('http') ? Image.network(img, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)) : (img.isNotEmpty ? Image.file(File(img), fit: BoxFit.cover) : const Icon(Icons.image, size: 50));
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))], border: Border.all(color: Colors.orange[50]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)), child: imgW)),
        Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1),
          const SizedBox(height: 5),
          Text('${product['price']} تومان', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange[900])),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => _buyProduct(product), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 35)), child: const Text('ثبت سفارش')),
        ])),
      ]),
    );
  }
}
