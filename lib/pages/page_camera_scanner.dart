import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:marihacks7/pages/page_scan_history.dart';
import 'package:marihacks7/pages/page_username.dart';
import 'package:marihacks7/service/scan_service.dart';
import 'package:marihacks7/pages/page_barcode_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  _BarcodeScanPageState createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  final ScanService _scanService = ScanService();
  String _userName = '';
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');

    if (userName != null) {
      setState(() {
        _userName = userName;
      });
    }
  }

  Future<void> _clearUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userName = prefs.getString('userName');

    if (userName != null) {
      final Uri apiUri = Uri.parse('http://v34l.com:8080/api/$userName');
      try {
        final response = await http
            .delete(apiUri, headers: {"Content-Type": "application/json"});

        if (response.statusCode == 200) {
          await prefs.remove('userName');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
        } else {
          print('Failed to delete user from the server: ${response.body}');
        }
      } catch (e) {
        print('Error making DELETE request: $e');
      }
    }
  }

  void startBarcodeScan() async {
    String barcodeResult = await _scanService.scanBarcode();
    if (barcodeResult.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BarcodeResultPage(barcodeResult: barcodeResult),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Barcode"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_userName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text('Welcome, $_userName',
                    style: Theme.of(context).textTheme.headline6),
              ),
            ElevatedButton(
              onPressed: startBarcodeScan,
              child: Text('Start Scanning'),
            ),
            SizedBox(height: 10), // Spacing between buttons
            ElevatedButton(
              onPressed: _clearUserName,
              child: Text('Reset User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .red, // Provide a different color to indicate a destructive action
              ),
            ),
          ],
        ),
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
                    startBarcodeScan;
                  }
                  if (selectedIndex == 2) {
                    /* 
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            pageProfil(), //remplacer par le nom de la  page,
                      ),
                    );
                    */
                  }
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
                GButton(
                  icon: Icons.account_circle,
                  text: 'Profile',
                )
              ],
            ),
          ),
        )
    );
  }
}
