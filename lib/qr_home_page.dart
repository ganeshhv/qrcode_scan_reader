import 'package:flutter/material.dart';
import 'package:qrcode_scan_reader/qr_generate.dart';
import 'package:qrcode_scan_reader/qr_history.dart';
import 'package:qrcode_scan_reader/qr_scanner_page.dart';


class QrHomeScreen extends StatefulWidget {
  @override
  _QrHomeScreenState createState() => _QrHomeScreenState();
}

class _QrHomeScreenState extends State<QrHomeScreen>
{
  GlobalKey _bottomNavigationKey = GlobalKey();
  int _currentIndex = 0;
  List<Widget> _children = [
    QrScannerPage(),
    QrGenerateScreen(),
    QrHistoryScreen()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  _onTap() { // this has changed
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) => _children[_currentIndex])); // this has changed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            print('changed to index:$index');
            _currentIndex = index;
          });
        },
        key: _bottomNavigationKey,
        selectedItemColor: Colors.blue,
        showSelectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            label: 'Scan'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_outlined),
              label: 'Generate'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'History'
          ),
        ]
      ),
    );
  }
}
