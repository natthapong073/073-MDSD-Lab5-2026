import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/item.dart';
import 'models/favorites_model.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Ephemeral State สำหรับเก็บข้อความคำค้นหาภายในหน้านี้เท่านั้น
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล FavoritesModel มาใช้งาน (ใช้ watch เพื่อให้อัปเดต UI อัตโนมัติ)
    final favoritesModel = context.watch<FavoritesModel>();
    final savedItems = favoritesModel.items;

    // กรองรายการสินค้าจาก catalog ตามคำค้นหา (ไม่สนตัวพิมพ์เล็ก-ใหญ่)
    final filteredCatalog = catalog.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Marketplace'),
        actions: [
          // แสดงปุ่มและตัวนับจำนวนรายการโปรดที่ AppBar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite, color: Colors.red),
              label: Text(
                '${savedItems.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ช่องค้นหาสินค้า (Search Box) ใช้ Ephemeral State ธรรมดาตามโจทย์ข้อ 1
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'ค้นหาสินค้า...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // อัปเดต State ทันทีที่พิมพ์ข้อความ
                });
              },
            ),
          ),
          // แสดงรายการสินค้าที่ผ่านการกรองแล้ว พร้อมปุ่มบันทึกรายการโปรด
          Expanded(
            child: ListView.builder(
              itemCount: filteredCatalog.length,
              itemBuilder: (context, index) {
                final item = filteredCatalog[index];
                final isSaved = savedItems.any((i) => i.id == item.id);

                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('฿${item.price.toStringAsFixed(0)}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      if (isSaved) {
                        favoritesModel.remove(item);
                      } else {
                        favoritesModel.add(item);
                      }
                    },
                    child: Text(isSaved ? '❤️ บันทึกแล้ว' : '🤍 บันทึก'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
