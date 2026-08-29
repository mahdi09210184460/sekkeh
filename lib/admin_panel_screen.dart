import 'package:flutter/material.dart';
import 'data_manager.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('پنل مدیریت سکه چی'),
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'فروشگاه'),
                Tab(text: 'اخبار'),
                Tab(text: 'قرعه‌کشی'),
                Tab(text: 'تنظیمات بازی'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildShopManager(),
              _buildNewsManager(),
              _buildLotteryManager(),
              _buildGameSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('افزودن محصول جدید'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: DataManager.shopProducts.length,
            itemBuilder: (context, index) {
              final prod = DataManager.shopProducts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(prod['image'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image)),
                  title: Text(prod['name']),
                  subtitle: Text('${prod['price']} سکه | ${prod['category']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddProductDialog(product: prod, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          setState(() => DataManager.shopProducts.removeAt(index));
                          await DataManager.saveData();
                        },
                      ),
                    ],
                  ),
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
    final descCtrl = TextEditingController(text: product?['desc'] ?? '');
    final imgCtrl = TextEditingController(text: product?['image'] ?? 'https://via.placeholder.com/150');
    String category = product?['category'] ?? 'کالای دیجیتال';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(product == null ? 'افزودن محصول' : 'ویرایش محصول'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام محصول')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'قیمت (سکه)'), keyboardType: TextInputType.number),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'توضیحات'), maxLines: 2),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'آدرس تصویر')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'دسته بندی'),
                    items: ['کالای دیجیتال', 'پوشاک', 'کارت هدیه', 'سایر']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => category = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () async {
                  final newProd = {
                    'name': nameCtrl.text,
                    'price': int.tryParse(priceCtrl.text) ?? 0,
                    'desc': descCtrl.text,
                    'image': imgCtrl.text,
                    'category': category
                  };
                  setState(() {
                    if (index == null) {
                      DataManager.shopProducts.add(newProd);
                    } else {
                      DataManager.shopProducts[index] = newProd;
                    }
                  });
                  await DataManager.saveData();
                  Navigator.pop(context);
                },
                child: const Text('ذخیره'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsManager() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddNewsDialog(),
            icon: const Icon(Icons.add),
            label: const Text('افزودن خبر جدید'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: DataManager.newsList.length,
            itemBuilder: (context, index) {
              final news = DataManager.newsList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.campaign)),
                  title: Text(news['title']),
                  subtitle: Text(news['date']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      setState(() => DataManager.newsList.removeAt(index));
                      await DataManager.saveData();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddNewsDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('افزودن خبر'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان خبر')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'توضیحات'), maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  DataManager.newsList.insert(0, {
                    'title': titleCtrl.text,
                    'description': descCtrl.text,
                    'date': 'هم‌اکنون',
                    'icon_code': Icons.campaign.codePoint,
                    'isNew': true,
                  });
                });
                await DataManager.saveData();
                Navigator.pop(context);
              },
              child: const Text('ذخیره'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLotteryManager() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBannerEditor(),
          const Divider(height: 40, thickness: 2),
          _buildLotteryTicketsManager(),
          const Divider(height: 40, thickness: 2),
          _buildWinnersManager(),
        ],
      ),
    );
  }

  Widget _buildBannerEditor() {
    final titleCtrl = TextEditingController(text: DataManager.lotteryBanner['title']);
    final subCtrl = TextEditingController(text: DataManager.lotteryBanner['subtitle']);
    final imgCtrl = TextEditingController(text: DataManager.lotteryBanner['image']);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ویرایش بنر قرعه‌کشی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان بنر')),
          TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'زیرنویس بنر')),
          TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'آدرس تصویر')),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                DataManager.lotteryBanner['title'] = titleCtrl.text;
                DataManager.lotteryBanner['subtitle'] = subCtrl.text;
                DataManager.lotteryBanner['image'] = imgCtrl.text;
              });
              await DataManager.saveData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بنر آپدیت شد')));
            },
            child: const Text('بروزرسانی بنر'),
          ),
        ],
      ),
    );
  }

  Widget _buildLotteryTicketsManager() {
    return Column(
      children: [
        const Text('مدیریت بلیط‌های فعال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ElevatedButton.icon(
          onPressed: () => _showAddLotteryDialog(),
          icon: const Icon(Icons.add),
          label: const Text('تعریف قرعه‌کشی جدید'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DataManager.lotteryList.length,
          itemBuilder: (context, index) {
            final lot = DataManager.lotteryList[index];
            return ListTile(
              title: Text(lot['title']),
              subtitle: Text('جایزه: ${lot['prize']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  setState(() => DataManager.lotteryList.removeAt(index));
                  await DataManager.saveData();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWinnersManager() {
    return Column(
      children: [
        const Text('مدیریت اسامی برندگان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ElevatedButton.icon(
          onPressed: () => _showAddWinnerDialog(),
          icon: const Icon(Icons.add),
          label: const Text('افزودن برنده جدید'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], foregroundColor: Colors.white),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: DataManager.winnersList.length,
          itemBuilder: (context, index) {
            final win = DataManager.winnersList[index];
            return ListTile(
              title: Text(win['name']),
              subtitle: Text(win['prize']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  setState(() => DataManager.winnersList.removeAt(index));
                  await DataManager.saveData();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddWinnerDialog() {
    final nameCtrl = TextEditingController();
    final prizeCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('افزودن برنده'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی')),
              TextField(controller: prizeCtrl, decoration: const InputDecoration(labelText: 'جایزه برنده شده')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ')),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  DataManager.winnersList.insert(0, {
                    'name': nameCtrl.text,
                    'prize': prizeCtrl.text,
                    'date': dateCtrl.text,
                  });
                });
                await DataManager.saveData();
                Navigator.pop(context);
              },
              child: const Text('ذخیره'),
            )
          ],
        ),
      ),
    );
  }

  void _showAddLotteryDialog() {
    final titleCtrl = TextEditingController();
    final prizeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final dateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعریف قرعه‌کشی'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'عنوان قرعه‌کشی')),
                TextField(controller: prizeCtrl, decoration: const InputDecoration(labelText: 'نام جایزه')),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'قیمت بلیط (سکه)'), keyboardType: TextInputType.number),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ برگزاری')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  DataManager.lotteryList.add({
                    'title': titleCtrl.text,
                    'prize': prizeCtrl.text,
                    'ticketPrice': int.tryParse(priceCtrl.text) ?? 100,
                    'date': dateCtrl.text,
                    'icon_code': Icons.card_giftcard.codePoint,
                    'color_value': Colors.orange.value,
                  });
                });
                await DataManager.saveData();
                Navigator.pop(context);
              },
              child: const Text('ذخیره'),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildGameSettings() {
    final entryFeeCtrl = TextEditingController(text: '${DataManager.gameSettings['entryFee']}');
    final winRewardCtrl = TextEditingController(text: '${DataManager.gameSettings['winReward']}');

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text('تنظیمات عمومی بازی‌ها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(labelText: 'هزینه ورودی (سکه)'),
            controller: entryFeeCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(labelText: 'سود هر برد (سکه)'),
            controller: winRewardCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                DataManager.gameSettings['entryFee'] = int.tryParse(entryFeeCtrl.text) ?? 50;
                DataManager.gameSettings['winReward'] = int.tryParse(winRewardCtrl.text) ?? 15;
              });
              await DataManager.saveData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تنظیمات با موفقیت ذخیره شد'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('ذخیره تغییرات'),
          )
        ],
      ),
    );
  }
}
