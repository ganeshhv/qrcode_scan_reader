import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qrcode_scan_reader/qr_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route()
  {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QrHomeScreen()));
  }
  @override
  Widget build(BuildContext context) {
    startTime();
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
              strokeWidth: 1,
            ),
          ),
        ],
      ),
    );
  }
}


