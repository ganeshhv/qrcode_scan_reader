import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_scan_reader/controller/utility/utility.dart';

import 'controller/qr_controller.dart';
import 'models/qr_model.dart';

class QrGenerateScreen extends StatefulWidget {
  @override
  _QrGenerateScreenState createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  final globalKey = GlobalKey();
  // Name
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  // email and phone
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  //sms
  final _toController = TextEditingController();
  final _messageController = TextEditingController();
  //url
  final _urlController = TextEditingController();
  // vcard
  final _fnameVcardController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailVcardController = TextEditingController();
  final _phoneVcardController = TextEditingController();
  final _urlVcardController = TextEditingController();
  final _faxController = TextEditingController();
  final _cellController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _streetController = TextEditingController();

  // smsFormat = SMSTO:PhoneNumber:Message ex: SMSTO:8123456000:abcdef
  //urlFormat http://www.hvg.co as link
  //phone Format==> tel:1234567890
  // email format ==> EMAIL:abc@gmail.com
  //vCard Format ==>
  // // BEGIN:VCARD
  // // VERSION:3.0
  // // N:a;a
  // // ORG:fab
  // // EMAIL;TYPE=INTERNET:ajatashatru@gmail.com
  // // URL:abc.com
  // // TEL;TYPE=CELL:1234
  // // TEL:09845083994
  // // TEL;TYPE=FAX:125
  // // ADR:;;Flat no.\, A-403\, Meenakshi Classic\, #471\, 27th Main\, 1st Sector\, HSR Layout;Bangalore;Karnataka;560102;India   ==> Format StreetAddress;State;pincode;Country
  // // END:VCARD,

  final String imageType = 'generate';
  String qrType = 'Name';
  List<String> qrTypeItems = [
    'Name',
    'Sms',
    'Phone & Email',
    'Contacts',
    'Url'
  ];

  final _qrController = Get.put(QrController());

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
          title: Text('Generate QR'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            new TextEditingController().clear();
          },
          child: Container(
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Text(
                            'Select QR Type:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          )),
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                buttonTheme: ButtonTheme.of(context).copyWith(
                              alignedDropdown:
                                  true, //If false (the default), then the dropdown's menu will be wider than its button.
                            )),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                isDense: true,
                                isExpanded: true,
                                underline: SizedBox(),
                                value: qrType,
                                onChanged: (String newVal) {
                                  setState(() {
                                    print('changed to $newVal');
                                    qrType = newVal;
                                  });
                                },
                                items: qrTypeItems.map((e) {
                                  return DropdownMenuItem<String>(
                                      value: e, child: Text(e));
                                }).toList(),
                                hint: Text('select'),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color: Colors.black45,
                              width: 0.1,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                qrTextView(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  qrTextView(BuildContext context) {
    switch (qrType) {
      case 'Name':
        return nameView(context);
        break;
      case 'Url':
        return urlView(context);
        break;
      case 'Phone & Email':
        return phoneandEmailView(context);
        break;
      case 'Contacts':
        return contactView(context);
        break;
      case 'Sms':
        return smsView(context);
      default:
        return nameView(context);
    }
  }

  rowTextView(String hint, String title, TextEditingController _controller,
      TextInputType textInputType) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      margin: EdgeInsets.only(top: 2, bottom: 2),
      height: (textInputType == TextInputType.multiline) ? 80 : 40,
      child: TextField(
        style: new TextStyle(
          fontSize: 13.0,
          color: Colors.black,
        ),
        maxLines: (textInputType == TextInputType.multiline) ? 7 : 1,
        keyboardType: textInputType,
        controller: _controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.5),
          ),
          labelText: title,
          hintText: hint,
        ),
      ),
    );
  }

  generateButton(String text, Function onPress) {
    return ElevatedButton(onPressed: onPress, child: Text(text));
  }

  nameView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 10.5,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              rowTextView('Enter the FirstName', 'First Name', _fnameController,
                  TextInputType.name),
              rowTextView('Enter the MiddleName', 'Middle Name',
                  _mnameController, TextInputType.name),
              rowTextView('Enter the LastName', 'Last Name', _lnameController,
                  TextInputType.name),
              generateButton('Generate QR', () {
                print('generate qr');
                generateQR(context);
              })
            ],
          ),
        ),
      ),
    );
  }

  urlView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 10.5,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              rowTextView(
                  'www.google.com', 'Url', _urlController, TextInputType.url),
              generateButton('Generate QR', () {
                print('generate qr');
                generateQR(context);
              })
            ],
          ),
        ),
      ),
    );
  }

  contactView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 10.5,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              rowTextView('Enter Name', 'Name', _fnameVcardController,
                  TextInputType.name),
              rowTextView('Enter the Organization', 'Organization',
                  _organizationController, TextInputType.text),
              rowTextView('Enter the Email', 'Email', _emailVcardController,
                  TextInputType.name),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(right: 2),
                    child: rowTextView('', 'Phone', _phoneVcardController,
                        TextInputType.phone),
                  )),
                  Expanded(
                    child: rowTextView(
                        '', 'Cell', _cellController, TextInputType.phone),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(right: 2),
                    child: rowTextView(
                        '', 'Fax', _faxController, TextInputType.phone),
                  )),
                  Expanded(
                    child: rowTextView('Enter the Url', 'url',
                        _urlVcardController, TextInputType.url),
                  )
                ],
              ),
              rowTextView(
                  '', 'Street', _streetController, TextInputType.multiline),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(right: 2),
                    child: rowTextView('571401', 'Pincode', _pincodeController,
                        TextInputType.number),
                  )),
                  Expanded(
                    child: rowTextView(
                        '', 'City', _cityController, TextInputType.name),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(right: 2),
                    child: rowTextView(
                        '', 'State', _stateController, TextInputType.name),
                  )),
                  Expanded(
                    child: rowTextView(
                        '', 'Country', _countryController, TextInputType.name),
                  )
                ],
              ),
              // buttons
              Row(
                children: [
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(right: 2),
                          child: generateButton('Generate QR', () {
                            print('generate qr');
                            generateQR(context);
                          }))),
                  Expanded(
                      child: generateButton('Clear Fields', () {
                        setState(() {
                          _fnameVcardController.clear();
                          _organizationController.clear();
                          _emailVcardController.clear();
                          _phoneVcardController.clear();
                          _cellController.clear();
                          _faxController.clear();
                          _urlVcardController.clear();
                          _streetController.clear();
                          _pincodeController.clear();
                          _cityController.clear();
                          _stateController.clear();_countryController.clear();
                        });
                    print('clear');
                    // generateQR(context);
                  }))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  phoneandEmailView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 10.5,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              rowTextView('Enter the PhoneNumber', 'Phone number',
                  _phoneController, TextInputType.phone),
              rowTextView('Enter the EmailId', 'Email Id', _emailController,
                  TextInputType.emailAddress),
              generateButton('Generate QR', () {
                print('generate qr');
                generateQR(context);
              })
            ],
          ),
        ),
      ),
    );
  }

  smsView(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Card(
        elevation: 10.5,
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              rowTextView('Enter the Number', 'Number', _toController,
                  TextInputType.phone),
              rowTextView('Enter the Message', 'Message', _messageController,
                  TextInputType.multiline),
              generateButton('Generate QR', () {
                print('generate qr');
                generateQR(context);
              })
            ],
          ),
        ),
      ),
    );
  }

  generateQR(BuildContext context) async
  {
    if (qrType == 'Name')
    {
      if(_fnameController.text.isEmpty || _mnameController.text.isEmpty || _lnameController.text.isEmpty)
      {
        _showSnakbar('Please Fill all fields');
      }
      else
        {
          String data = _fnameController.text +
              '' +
              _mnameController.text +
              '' +
              _lnameController.text;
          final bodyHeight = MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom;
          print(data);
          final ts = DateTime.now().millisecondsSinceEpoch;
          Uint8List pngBytes;
          String imgName;
          try {
            // create future image and convert to Image
            var image = await QrPainter(
              data: data,
              version: QrVersions.auto,
            ).toImage(200);
            // convert image to bytedata
            ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
            //convert bytedata to Uint8List
            pngBytes = byteData.buffer.asUint8List();
            final ts = DateTime.now().millisecondsSinceEpoch;
            // convert Uint8List value to the base64stirng
            String imagePath = Utility.base64String(pngBytes);
            imgName = '$ts.png';
            String result = data;
            // imageType
            String qrSelected = qrType;

            // add data to the db
            QrModel qrModel = QrModel(
                imgName: imgName,
                imgPath: imagePath,
                ts: ts,
                result: result,
                imgType: imageType,
                qrType: qrSelected);
            Map qrList = await _qrController.getGeneratedQrData();
            if (qrList != null) {
              qrList.values.map((val) async {
                // check for path exist or not
                if (val.toString() != imagePath) {
                  await _qrController.addGeneratedQr(qrModel);
                }
              }).toList();
            } else {
              await _qrController.addGeneratedQr(qrModel);
            }
            setState(() {});
            await _qrController.getGeneratedQrData();
            print(_qrController.generatedQrList.length);
          } catch (e) {
            throw (e);
          }

          AlertDialog alert = AlertDialog(
            title: Center(child: Text(imgName)),
            content: Image.memory(pngBytes),
          );
          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
    }
    else if (qrType == 'Sms')
    {
      if(_toController.text.isEmpty || _messageController.text.isEmpty)
        {
          _showSnakbar('Please Fill All the Fields');
        }
      else
        {
          String data = 'SMSTO:${_toController.text}:${_messageController.text}';
          final bodyHeight = MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom;
          print(data);
          Uint8List pngBytes;
          String imgName;
          try {
            // create future image and convert to Image
            var image = await QrPainter(
              data: data,
              version: QrVersions.auto,
            ).toImage(200);
            // convert image to bytedata
            ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
            //convert bytedata to Uint8List
            pngBytes = byteData.buffer.asUint8List();
            final ts = DateTime.now().millisecondsSinceEpoch;
            // convert Uint8List value to the base64stirng
            String imagePath = Utility.base64String(pngBytes);
            imgName = '${ts}_${qrType}.png';
            String result = data;
            // imageType
            String qrSelected = qrType;

            // add data to the db
            QrModel qrModel = QrModel(
                imgName: imgName,
                imgPath: imagePath,
                ts: ts,
                result: result,
                imgType: imageType,
                qrType: qrSelected);
            Map qrList = await _qrController.getGeneratedQrData();
            if (qrList != null) {
              qrList.values.map((val) async {
                // check for path exist or not
                if (val.toString() != imagePath) {
                  await _qrController.addGeneratedQr(qrModel);
                }
              }).toList();
            } else {
              await _qrController.addGeneratedQr(qrModel);
            }
            setState(() {});
            await _qrController.getGeneratedQrData();
            print(_qrController.generatedQrList.length);
          } catch (e) {
            throw (e);
          }

          AlertDialog alert = AlertDialog(
            title: Center(child: Text(imgName)),
            content: Image.memory(pngBytes),
          );
          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
    }
    else if (qrType == 'Url')
    {
      if(_urlController.text.isEmpty)
        {
          _showSnakbar('Please Enter the Url');
        }
      else
        {
          String data = _urlController.text;
          final bodyHeight = MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom;
          print(data);
          Uint8List pngBytes;
          String imgName;
          try {
            // create future image and convert to Image
            var image = await QrPainter(
              data: data,
              version: QrVersions.auto,
            ).toImage(200);
            // convert image to bytedata
            ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
            //convert bytedata to Uint8List
            pngBytes = byteData.buffer.asUint8List();
            final ts = DateTime.now().millisecondsSinceEpoch;
            // convert Uint8List value to the base64stirng
            String imagePath = Utility.base64String(pngBytes);
            imgName = '${ts}_${qrType}.png';
            String result = data;
            // imageType
            String qrSelected = qrType;

            // add data to the db
            QrModel qrModel = QrModel(
                imgName: imgName,
                imgPath: imagePath,
                ts: ts,
                result: result,
                imgType: imageType,
                qrType: qrSelected);
            Map qrList = await _qrController.getGeneratedQrData();
            if (qrList != null) {
              qrList.values.map((val) async {
                // check for path exist or not
                if (val.toString() != imagePath) {
                  await _qrController.addGeneratedQr(qrModel);
                }
              }).toList();
            } else {
              await _qrController.addGeneratedQr(qrModel);
            }
            setState(() {});
            await _qrController.getGeneratedQrData();
            print(_qrController.generatedQrList.length);
          } catch (e) {
            throw (e);
          }

          AlertDialog alert = AlertDialog(
            title: Center(child: Text(imgName)),
            content: Image.memory(pngBytes),
          );
          // show the dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
    }
    else if (qrType == 'Contacts')
    {
      // '''BEGIN:VCARD
      // VERSION:3.0
      // N:${_fnameVcardController.text}
      // ORG:${_organizationController.text}
      // EMAIL;TYPE=INTERNET:${_emailVcardController.text}
      // URL:${_urlVcardController.text}
      // TEL;TYPE=CELL:${_phoneVcardController.text}
      // TEL:${_cellController.text}
      // TEL;TYPE=FAX:${_cellController.text}
      // ADR:;;${_streetController.text};${_cityController.text};${_stateController.text};${_pincodeController.text};${_countryController.text}
      // END:VCARD,''';

      if(_fnameVcardController.text.isEmpty &&
      _organizationController.text.isEmpty &&
      _emailVcardController.text.isEmpty &&
      _phoneVcardController.text.isEmpty &&
      _cellController.text.isEmpty &&
      _faxController.text.isEmpty &&
      _urlVcardController.text.isEmpty &&
      _streetController.text.isEmpty &&
      _pincodeController.text.isEmpty &&
      _cityController.text.isEmpty &&
      _stateController.text.isEmpty )
      {
        _showSnakbar('Please Fill All the Fields');
      }
      else{
        String vCardData =       '''BEGIN:VCARD
VERSION:3.0
N:${_fnameVcardController.text}
ORG:${_organizationController.text}
TEL;TYPE=CELL:${_phoneVcardController.text}
TEL:${_cellController.text}
TEL;TYPE=FAX:${_cellController.text}
ADR:;;${_streetController.text};${_cityController.text};${_stateController.text};${_pincodeController.text};${_countryController.text}
EMAIL;TYPE=INTERNET:${_emailVcardController.text}
URL:${_urlVcardController.text}
END:VCARD''';
        String data = vCardData;
        final bodyHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom;
        print(data);
        Uint8List pngBytes;
        String imgName;
        try {
          // create future image and convert to Image
          var image = await QrPainter(
            data: data,
            version: QrVersions.auto,
          ).toImage(200);
          // convert image to bytedata
          ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
          //convert bytedata to Uint8List
          pngBytes = byteData.buffer.asUint8List();
          final ts = DateTime.now().millisecondsSinceEpoch;
          // convert Uint8List value to the base64stirng
          String imagePath = Utility.base64String(pngBytes);
          imgName = '${ts}_${qrType}.png';
          String result = data;
          // imageType
          String qrSelected = qrType;

          // add data to the db
          QrModel qrModel = QrModel(
              imgName: imgName,
              imgPath: imagePath,
              ts: ts,
              result: result,
              imgType: imageType,
              qrType: qrSelected);
          Map qrList = await _qrController.getGeneratedQrData();
          if (qrList != null) {
            qrList.values.map((val) async {
              // check for path exist or not
              if (val.toString() != imagePath) {
                await _qrController.addGeneratedQr(qrModel);
              }
            }).toList();
          } else {
            await _qrController.addGeneratedQr(qrModel);
          }
          setState(() {});
          await _qrController.getGeneratedQrData();
          print(_qrController.generatedQrList.length);
        } catch (e) {
          throw (e);
        }

        AlertDialog alert = AlertDialog(
          title: Center(child: Text(imgName)),
          content: Image.memory(pngBytes),
        );
        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }
    else
      {
        if(_emailController.text.isEmpty && _phoneController.text.isEmpty)
        {
          _showSnakbar('Fill All the Fields');
        }
        else
          {
            String data;
            if (_phoneController.text.isEmpty) {
              data = 'EMAIL;TYPE=INTERNET:${_emailController.text}';
            } else if (_emailController.text.isEmpty) {
              data = 'tel:${_phoneController.text}';
            }
            else
              data = 'tel:${_phoneController.text}'
                  'EMAIL;TYPE=INTERNET:${_emailController.text}';

            final bodyHeight = MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom;
            print(data);
            Uint8List pngBytes;
            String imgName;
            try {
              // create future image and convert to Image
              var image = await QrPainter(
                data: data,
                version: QrVersions.auto,
              ).toImage(200);
              // convert image to bytedata
              ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
              //convert bytedata to Uint8List
              pngBytes = byteData.buffer.asUint8List();
              final ts = DateTime.now().millisecondsSinceEpoch;
              // convert Uint8List value to the base64stirng
              String imagePath = Utility.base64String(pngBytes);
              imgName = '${ts}_${qrType}.png';
              String result = data;
              // imageType
              String qrSelected = qrType;

              // add data to the db
              QrModel qrModel = QrModel(
                  imgName: imgName,
                  imgPath: imagePath,
                  ts: ts,
                  result: result,
                  imgType: imageType,
                  qrType: qrSelected);
              Map qrList = await _qrController.getGeneratedQrData();
              if (qrList != null) {
                qrList.values.map((val) async {
                  // check for path exist or not
                  if (val.toString() != imagePath) {
                    await _qrController.addGeneratedQr(qrModel);
                  }
                }).toList();
              } else {
                await _qrController.addGeneratedQr(qrModel);
              }
              setState(() {});
              await _qrController.getGeneratedQrData();
              print(_qrController.generatedQrList.length);
            } catch (e) {
              throw (e);
            }

            AlertDialog alert = AlertDialog(
              title: Center(child: Text(imgName)),
              content: Image.memory(pngBytes),
            );
            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );

          }
    }
  }

  // showQrDialog(BuildContext context, var data) async
  // {
  //   print('data.tostring:${data.toString()}');
  //   image = QrImage(
  //     data: data.toString(),
  //     version: QrVersions.auto,
  //     size: 200,
  //   );
  //   print('image:$image');
  //   // print('detector:${BarcodeScanner.scan()}');
  //   // Directory tempDir = await getTemporaryDirectory();
  //   // String tempPath = tempDir.path;
  //   // final ts = DateTime.now().millisecondsSinceEpoch.toString();
  //   // String path = '$tempPath/img_$ts.png';
  //   // final file = await new File(path).create();
  //   //
  //   // // set up the AlertDialog
  //   // AlertDialog alert = AlertDialog(
  //   //   title: Center(child: Text('zone')),
  //   //   content: image,
  //   //   actions: [
  //   //
  //   //   ],
  //   // );
  //   //
  //   // // show the dialog
  //   // showDialog(
  //   //   context: context,
  //   //   builder: (BuildContext context) {
  //   //     return alert;
  //   //   },
  //   // );
  // }

  _showSnakbar(message) {
    var _snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }
}
