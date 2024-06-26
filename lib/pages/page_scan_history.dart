import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:marihacks7/pages/page_barcode_result.dart';
import 'package:marihacks7/pages/page_camera_scanner.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marihacks7/pages/resultTest.dart';

// A mock class to represent a scanned item.
class ScannedItem {
  final String barcode;
  final String date;
  // Préparation pour les futures propriétés
  final String name;
  final String image;
 

  ScannedItem({
    this.barcode = '',
    this.date = '',
    this.name = '',
    this.image =  ''
  });

  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    return ScannedItem(
      barcode: json['barcode'] ?? 'Unknown Barcode',
      date: json['date'] ?? 'Unknown Date',
      name: json['product_name'] ?? 'Unknown Name',
      image: json['image_front_url'] ?? 'https://github.com/simbiss/MariHacks7/blob/main/lib/images/githealthy.png?raw=true'
    );
  }
}

class DetailedItemPage extends StatelessWidget {
  final ScannedItem item;
  const DetailedItemPage({Key? key, required this.item}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.barcode), // Display barcode as title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: item.barcode, // Use the same tag as in HistoryPage
              child: Icon(Icons.qr_code, size: 150.0),
            ),
            Text(item.date),
            // Display other item details here
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ScannedItem> scannedHistory = [];
  int selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    _fetchScannedItems();
  }

  Future<void> _fetchScannedItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('userName');
    int selectedIndex = 0;

    if (username == null) {
      print("Username not found");
      return;
    }

    final Uri uri = Uri.parse('http://v34l.com:8080/api/$username/barcodes');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> fetchedItems = json.decode(response.body);
        setState(() {
          scannedHistory = fetchedItems
              .map((dynamic item) => ScannedItem.fromJson(item))
              .toList();
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique'),
      ),
      body: ListView.builder(
        itemCount: scannedHistory.length,
        itemBuilder: (context, index) {
          final item = scannedHistory[index];
          return InkWell(
            onTap: () {
              // Navigate to a detailed page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>ProductDetailsPage(barcodeResult: item.barcode)
                ),
              );
            },
            child: ListTile(
              leading: Hero(
                tag: item.barcode, // Unique tag for the Hero animation
                child: Image.network(
                  item.image,
                  height: 120, // Adjust the height as needed
                  fit: BoxFit.cover, // Ensure the image covers the entire space
                ),
              ),
              title: Text(item.name),
              subtitle: Text(item.date),
            ),
          );
        },
      ),
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: GNav(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              tabBackgroundColor: Theme.of(context).colorScheme.primary,
              activeColor: Theme.of(context).colorScheme.onPrimary,
              gap: 12,
              padding: const EdgeInsets.all(20),
              selectedIndex: 0,
              onTabChange: (index) {
                setState(() {
                  selectedIndex = index;
                  if (selectedIndex == 0) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            HistoryPage(),
                      ),
                    );
                  }
                  if (selectedIndex == 1) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const BarcodeScanPage(),
                      ),
                    );
                  }
                  //if (selectedIndex == 2) {
                    /* 
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            pageProfil(), //remplacer par le nom de la  page,
                      ),
                    );
                    */
                  //}
                });
              },
              tabs: const [
                GButton(
                  icon: Icons.history,
                  text: 'History',
                ),
                GButton(
                  icon: Icons.barcode_reader,
                  text: 'Scan',
                ),
                //GButton(
                  //icon: Icons.account_circle,
                  //text: 'Profile',
                //)
              ],
            ),
          ),
        )
    );
  }
}

void main() => runApp(MaterialApp(home: HistoryPage()));
