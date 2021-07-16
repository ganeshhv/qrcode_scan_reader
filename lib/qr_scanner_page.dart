import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io' show Platform, File, Directory;

import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_scan_reader/controller/qr_controller.dart';
import 'package:qrcode_scan_reader/controller/utility/utility.dart';
import 'package:qrcode_scan_reader/db/db_helper.dart';
import 'package:qrcode_scan_reader/models/qr_model.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isFlash = false;
  PermissionStatus cameraStatus;
  DbHelper dbHelper;
  final _qrController = Get.put(QrController());
  String imageType = 'scan';

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCameraPermission();
    this.dbHelper = DbHelper();
    this.dbHelper.initDb();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller?.dispose();
  }

  bool flashStatus = false;

  Future<bool> _onWillPop() {
    print('back pressed');
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(3)
                ),
                child: Text("NO")),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(3)
                ),
              child: Text("YES")),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('QR Scanner'),
        ),
        body: Container(
            child: Column(
          children: [
            Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    processBarCode(context),
                    Positioned(
                        child: IconButton(
                            icon: flashStatus
                                ? Icon(
                                    Icons.flash_off,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                  ),
                            onPressed: () async {
                              await controller.toggleFlash();
                              flashStatus = await controller.getFlashStatus();
                              setState(() {});
                            }))
                  ],
                )),
            // Expanded(
            //   flex: 1,
            //   child: FittedBox(
            //     fit: BoxFit.contain,
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: <Widget>[
            //         if (result != null)
            //           // showQRdialog(result.code, context)
            //           Text(
            //               'Barcode Type: ${describeEnum(result.format)} Data: ${result.code}')
            //         else
            //           Text('Scan a code'),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: <Widget>[
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: ElevatedButton(
            //                   onPressed: () async {
            //                     await controller?.toggleFlash();
            //                     setState(() {});
            //                   },
            //                   child: FutureBuilder(
            //                     future: controller?.getFlashStatus(),
            //                     builder: (context, snapshot) {
            //                       return Text('Flash: ${snapshot.data}');
            //                     },
            //                   )),
            //             ),
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: ElevatedButton(
            //                   onPressed: () async {
            //                     await controller?.flipCamera();
            //                     setState(() {});
            //                   },
            //                   child: FutureBuilder(
            //                     future: controller?.getCameraInfo(),
            //                     builder: (context, snapshot) {
            //                       if (snapshot.data != null) {
            //                         return Text(
            //                             'Camera facing ${describeEnum(snapshot.data)}');
            //                       } else {
            //                         return Text('loading');
            //                       }
            //                     },
            //                   )),
            //             )
            //           ],
            //         ),
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: <Widget>[
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: ElevatedButton(
            //                 onPressed: () async {
            //                   await controller?.pauseCamera();
            //                 },
            //                 child: Text('pause', style: TextStyle(fontSize: 20)),
            //               ),
            //             ),
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: ElevatedButton(
            //                 onPressed: () async {
            //                   await controller?.resumeCamera();
            //                 },
            //                 child: Text('resume', style: TextStyle(fontSize: 20)),
            //               ),
            //             ),
            //             Container(
            //               margin: EdgeInsets.all(8),
            //               child: ElevatedButton(
            //                 onPressed: () async {
            //                   await controller?.pauseCamera();
            //                 },
            //                 child: IconButton(
            //                   icon: Icon(Icons.image),
            //                   tooltip: 'Gallery',
            //                   onPressed: () {
            //                     setState(() {
            //                       // pickImageFromFile();
            //                       // pickImage();
            //                     });
            //                   },
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        )),
      ),
    );
  }

  processBarCode(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red, borderRadius: 10, cutOutSize: scanArea),
    );
  }

  showQRdialog(String text, BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('QR Data'),
          content: Text(text),
        ).build(context);
      },
    );
  }

  _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.asBroadcastStream().listen(
      (scannedData) async {
        print('qr view created');
        print(result.isNullOrBlank);
        if (result.isNullOrBlank || (result.code != scannedData.code)) {
          setState(() {
            result = scannedData;
          });
          if (result.format == BarcodeFormat.qrcode) {
            generateQrImage(result.code);
          }
          // await controller.scannedDataStream.listen((event) { }).cancel();

        } else {
          print(result.code != scannedData.code);
          print('result exists');
        }

        print('scanned result: ${result.rawBytes}');
        print('scanner type:${result.format}');
        print('check:${result.format == BarcodeFormat.qrcode}');
        // if(result.format == BarcodeFormat.qrcode)
        //   {
        //     generateQrImage(result.code);
        //   }
      },
      onDone: () {},
    );
  }

  generateQrImage(String qrResult) async {
    print('qr result: $qrResult');
    QrPainter qrPainter = QrPainter(data: qrResult, version: QrVersions.auto);
    print('painter = $qrPainter');
    final imageData =
        await qrPainter.toImageData(2048, format: ImageByteFormat.png);
    print('image data:$imageData');
    final data = imageData.buffer
        .asUint8List(imageData.offsetInBytes, imageData.lengthInBytes);
    String imageString = Utility.base64String(data);
    final ts = DateTime.now().millisecondsSinceEpoch;
    String imgName = '$ts.png';
    QrModel qrModel = QrModel(
        imgName: imgName, imgPath: imageString, ts: ts, result: qrResult, imgType: imageType);
    Map qrList = await _qrController.getQrData();
    if (qrList != null) {
      // check for image exist or not
      qrList.values.map((val) async {
        if (val.toString() != imageString) {
          await _qrController.addQrData(qrModel);
        }
      }).toList();
    } else {
      await _qrController.addQrData(qrModel);
    }
    setState(() {});
    await _qrController.getQrData();
    print(_qrController.qrList.length);
  }

  // Widget _buildQrView(BuildContext context) {
  //   // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
  //   var scanArea = (MediaQuery.of(context).size.width < 400 ||
  //       MediaQuery.of(context).size.height < 400)
  //       ? 250.0
  //       : 500.0;
  //   // To ensure the Scanner view is properly sizes after rotation
  //   // we need to listen for Flutter SizeChanged notification and update controller
  //   return Barcode(
  //     key: qrKey,
  //     onQRViewCreated: _onQRViewCreated,
  //     overlay: QrScannerOverlayShape(
  //         borderColor: Colors.red,
  //         borderRadius: 10,
  //         borderLength: 30,
  //         borderWidth: 10,
  //         cutOutSize: scanArea),
  //   );
  // }

  getCameraPermission() async {
    cameraStatus = await Permission.camera.status;
    print(cameraStatus);
    if (!cameraStatus.isGranted) await Permission.camera.request();
  }
}
