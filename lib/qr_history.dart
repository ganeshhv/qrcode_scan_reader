import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qrcode_scan_reader/controller/utility/utility.dart';
import 'package:qrcode_scan_reader/utils/vcard_parser.dart';

import 'controller/qr_controller.dart';
import 'db/db_helper.dart';

class QrHistoryScreen extends StatefulWidget {
  @override
  _QrHistoryScreenState createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {

  GlobalKey _globalKey = GlobalKey();
  DbHelper dbHelper;
  final _qrController = Get.put(QrController());
  bool selectAllMode = false;
  List<int> checkedList = [];

  var isSelected = false;
  var mycolor=Colors.white;
  var border = BoxDecoration(border: new Border.all(color: Colors.white));

  int selectedIndex = 0;

  _showSnakbar(message)
  {
    var _snackBar = SnackBar(content: message,);
    ScaffoldMessenger.of(context).showSnackBar(_snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _qrController.qrList.sort((a,b) => b.ts.compareTo(a.ts));
    _qrController.generatedQrList.sort((a,b) => b.ts.compareTo(a.ts));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('binding');
      print(_qrController.generatedQrList);
      return Future.delayed(Duration(seconds: 5), () => CircularProgressIndicator());
    });
  }
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () => _onWillPop(),
        child: Scaffold(
          appBar: (isSelected) ? (selectedIndex == 0) ? AppBar(
            backgroundColor: Colors.white,
            leading: isSelected
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black,),
              onPressed: () {
                setState(() {
                  isSelected = false;
                  checkedList.clear();
                  selectAllMode = false;
                  // complianceModel._complianceInfo
                  //     .forEach((p) => p.selected = false
                  // );
                });
              },
            )
                : null,
            centerTitle: true,
            title: Text(
              "Remove Incidents",
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              isSelected
                  ? IconButton(
                icon: Visibility(
                    visible:
                    (checkedList.isNotEmpty) ? true : false,
                    child: Icon(Icons.delete_outline_outlined, color: Colors.black,)),
                onPressed: (checkedList.isEmpty) ? null : () async {
                  print('delete pressed');
                  await _qrController.deleteQr(checkedList);
                  setState(() {
                    print(_qrController.qrList.length);
                    // paints.forEach((p) {
                    //
                    // });
                  });
                },
              )
                  : Container(),
              isSelected
                  ? IconButton(
                icon: (checkedList.length == _qrController.qrList.length)
                    ? Icon(Icons.playlist_add_check_outlined,color: Colors.blue,)
                    : Icon(Icons.playlist_add_check_outlined, color: Colors.black,),
                onPressed: () {
                  setState(() {
                    selectAllMode = !selectAllMode;
                    if(selectAllMode)
                      {
                        _qrController.qrList.map((list) => checkedList.add(list.id)).toList();
                      }
                    else checkedList.clear();
                    print('select all: $checkedList');
                    // _toggle();
                    // paints.forEach((p) {
                    //
                    // });
                  });
                },
              )
                  : Container(),
            ],
          ) : AppBar(
            backgroundColor: Colors.white,
            leading: isSelected
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black,),
              onPressed: () {
                setState(() {
                  isSelected = false;
                  checkedList.clear();
                  selectAllMode = false;
                  // complianceModel._complianceInfo
                  //     .forEach((p) => p.selected = false
                  // );
                });
              },
            )
                : null,
            centerTitle: true,
            title: Text(
              "Remove Incidents",
              style: TextStyle(color: Colors.black),

            ),
            actions: [
              isSelected
                  ? IconButton(
                icon: Visibility(
                    visible:
                    (checkedList.isNotEmpty) ? true : false,
                    child: Icon(Icons.delete_outline_outlined, color: Colors.black,)),
                onPressed:(checkedList.isEmpty) ? null : () async {
                  print('delete pressed');
                  await _qrController.deleteGeneratedQr(checkedList);
                  setState(() {
                    print(_qrController.generatedQrList.length);
                    // paints.forEach((p) {
                    //
                    // });
                  });
                },
              )
                  : Container(),
              isSelected
                  ? IconButton(
                icon: (checkedList.length == _qrController.generatedQrList.length)
                    ? Icon(Icons.playlist_add_check_outlined,color: Colors.blue,)
                    : Icon(Icons.playlist_add_check_outlined, color: Colors.black,),
                onPressed: () {
                  setState(() {
                    selectAllMode = !selectAllMode;
                    if(selectAllMode)
                    {
                      _qrController.generatedQrList.map((list) => checkedList.add(list.id)).toList();
                    }
                    else checkedList.clear();
                    print('select all: $checkedList');
                    // _toggle();
                    // paints.forEach((p) {
                    //
                    // });
                  });
                },
              )
                  : Container(),
            ],
          ) : AppBar(title: Text('History'),),
          body: DefaultTabController(
            length: 2,
            child: SizedBox(
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    labelPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    onTap: (index) {
                      print('selected index:$index');
                      setState(() {
                        selectedIndex = index;
                        checkedList.clear();
                        isSelected = false;
                      });
                    },
                    tabs: [
                      Tab(
                        child: Text('QR Scanned List'),
                      ),
                      Tab(
                        child: Text('QR Generate List')
                      )
                    ]
                  ),
                  Expanded(
                    child: TabBarView(
                      //for disable swipe
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        scannedQrListView(context),
                        generatedQrListView(context)
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  scannedQrListView(BuildContext context)
  {
    return Obx(() {
      if(_qrController.qrList.isEmpty)
      {
        return _nolistMsg();
      }
      else
      {
        print('isempty: ${_qrController.qrList.isEmpty}');
        print(_qrController.qrList);
        return ListView.builder(
            itemCount: _qrController.qrList.length,
            itemBuilder: (context, index)
            {
              return InkWell(
                child: Container(
                  color: checkedList.contains(_qrController.qrList[index].id) ? Colors.grey : Colors.white,
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        height: 40,
                        child: _showQrImage(index),
                      ),
                      title: Text(_qrController.qrList[index].imgName,),
                      subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_qrController.qrList[index].ts))}'),
                      trailing: (isSelected) ? (checkedList.contains(_qrController.qrList[index].id)) ? Icon(Icons.check_circle, color: Colors.blueAccent,) : Icon(Icons.check_circle_outline)
                          : null,
                    ),
                  ),
                ),
                onTap: ()  {
                  (!isSelected) ? Get.defaultDialog(
                    title: _qrController.qrList[index].imgName,
                    content: getContent(index),
                  ) : null;

                  setState(() {
                    if(isSelected)
                    {

                      if(checkedList.contains(_qrController.qrList[index].id))
                      {
                        print('already exist');
                        print('before $checkedList');
                        checkedList.remove(_qrController.qrList[index].id);
                        print('After $checkedList');

                      }
                      else
                      {
                        checkedList.add(_qrController.qrList[index].id);
                        print(checkedList);
                      }
                      print('you clicked on index:$index and id:${_qrController.qrList[index].id}');
                    }
                  });
                  // _showQRDialog(context);

                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
                onLongPress: ()
                {
                  setState(() {
                    _toggle();
                    checkedList.clear();
                  });
                },
              );
            }
        );
      }
    });
  }

  generatedQrListView(BuildContext context)
  {
    return Obx( () {
      if(_qrController.generatedQrList.isEmpty)
        {
          return _nolistMsg();
        }
      else
        {
          print('id: ${_qrController.generatedQrList[0].id}');
          return ListView.builder(
            itemCount: _qrController.generatedQrList.length,
            itemBuilder: (context, index)
                {
                  return InkWell(
                    child: Container(
                      color: checkedList.contains(_qrController.generatedQrList[index].id) ? Colors.grey : Colors.white,
                      child: Card(
                        child: ListTile(
                          leading: Container(
                            height: 40,
                            child: _showQrImage(index),
                          ),
                          title: Text(_qrController.generatedQrList[index].imgName,),
                          subtitle: Text('${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_qrController.generatedQrList[index].ts))}'),
                          trailing: (isSelected) ? (checkedList.contains(_qrController.generatedQrList[index].id)) ? Icon(Icons.check_circle, color: Colors.blueAccent,) : Icon(Icons.check_circle_outline)
                              : Text(_qrController.generatedQrList[index].qrType),
                        ),
                      ),
                    ),
                    onTap: ()  {
                      (!isSelected) ? Get.defaultDialog(
                        title: _qrController.generatedQrList[index].imgName,
                        content: getContent(index),
                      ) : null;

                      setState(() {
                        if(isSelected)
                        {

                          if(checkedList.contains(_qrController.generatedQrList[index].id))
                          {
                            print('already exist');
                            print('before $checkedList');
                            checkedList.remove(_qrController.generatedQrList[index].id);
                            print('After $checkedList');

                          }
                          else
                          {
                            checkedList.add(_qrController.generatedQrList[index].id);
                            print(checkedList);
                          }
                          print('you clicked on index:$index and id:${_qrController.generatedQrList[index].id}');
                        }
                      });
                      // _showQRDialog(context);

                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                    },
                    onLongPress: ()
                    {
                      setState(() {
                        _toggle();
                        checkedList.clear();
                      });
                    },
                  );
                }
          );
        }
    });
  }

  _toggle()
  {
      setState(() {
        if (isSelected) {
          border=new BoxDecoration(border: new Border.all(color: Colors.white));
          mycolor = Colors.white;
          isSelected = false;
        } else {
          border=new BoxDecoration(border: new Border.all(color: Colors.grey));
          mycolor = Colors.grey[300];
          isSelected = true;
        }
      });
      print('isSelected: $isSelected');
  }

  // _toggle() {
  //   setState(() {
  //     selectAllMode = !selectAllMode;
  //     _qrController.qrList.forEach((paint) {
  //       paint.selected = selectAllMode;
  //       if (paint.selected) {
  //         checkedList.add(paint.incidentId);
  //       } else {
  //         checkedList.clear();
  //       }
  //     });
  //   });
  //   print(checkedList.toSet().toList());
  // }


  getContent(int index)
  {
    if(selectedIndex == 0)
      {
        String name, email;
        Map address_name = {};
        final map = {};
        List contact = [];
        List address = [], phone = [];
        print('result contains vcard:${_qrController.qrList[index].result.contains('VCARD')}');
        VCard vc = VCard(_qrController.qrList[index].result);
        print(_qrController.qrList[index].result);
        vc.name.forEach((element) => name = element );
        vc.typedEmail.forEach((element) => email = element.toString() );
        vc.typedAddress.map((e) => address.addNonNull(e)).toList();
        vc.typedTelephone.map((e) => phone.addNonNull(e)).toList();
        // vc.typedAddress.forEach((element) => address = element.toString() );
        // vc.typedTelephone.forEach((element) => phone = element.toString() );
        // print('address:${address}');
        // print('phone: ${phone}');
        if(address.length > 0)
        {
          int size = address.length;
          print('size: $size');
          for(int i=0; i< size ; i++)
          {
            // replaceAll(RegExp(r'[^\w\s]+'), ',') will removes symbols
            // before Flat no.\, A-403\, Meenakshi Classic\, #471\, 27th Main\, 1st Sector\, HSR Layout;Bangalore;Karnataka;560102;India
            //after Flat no, A,403, Meenakshi Classic, ,471, 27th Main, 1st Sector, HSR Layout, Bangalore, Karnataka, 560102, India
            address_name.addAll({'address_${i+1}' : (address[i][0]).toString().replaceAll(RegExp(r'[^\w\s]+'), ',')});
          }
          // to remove [#305, aa, bb, , Bangalore, Karnataka, 595666, India] use
          // substring(1, address_name['address_1'].toString().length - 1)
          print('address_name: ${address_name['address_1'].toString().substring(1, address_name['address_1'].toString().length - 1).replaceAll(RegExp(r'[^\w\s]+'), ',')}');
        }
        if(phone.length > 0)
        {
          int size = phone.length;
          print('size: $size');

          for(int i=0; i< size ; i++)
          {
            print(phone[i][1].toString().contains('[CELL]'));
            if(phone[i][1].toString().contains('[CELL]'))
              {
                contact.add('Cell : ${phone[i][0]}');
              }
            else if(phone[i][1].toString().contains('[FAX]'))
            {
              contact.add('Fax : ${phone[i][0]}');
            }
            else
            {
              contact.add('Phone : ${phone[i][0]}');
            }
            print('${phone[i][0]} --> ${phone[i][1]}');
          }
          // map.forEach((key, value) {
          //   contact.add('${key}:${value}');
          // });

          print('phone: $contact');
        }
        return (_qrController.qrList[index].result.contains('VCARD')) ? Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: _showQrImage(index),),
            textView('Name:', name),
            textView('Email:', vc.email),
            (vc.gender == '') ? Container() :textView('Gender:', vc.gender),
            (vc.typedAddress.isEmpty) ? Container() : textView('Address', (address == null) ? '' : address_name['address_1'].toString().substring(1, address_name['address_1'].toString().length - 1)),
            ...contact.map((element) => Align(alignment: Alignment.centerLeft,child: Text(element, textAlign: TextAlign.left,))),
            // textView('Phone', (phone == null) ? [] : map['phone_1']),
            // textView('Phone2', (phone == null) ? [] : contact['phone_2']),

          ],
        ) : Column(
          children: [
            _showQrImage(index),
            Text('Result: ${_qrController.qrList[index].result}')

          ],
        );
      }
    else
      {
        String name, email;
        Map address_name = {};
        VCard vc;
        List contact = [];
        List address = [], phone = [];
        print('selected index: 1 and index: $index');
        print('result contains vcard:${_qrController.generatedQrList[index].result.contains('VCARD')}');
        if(_qrController.generatedQrList[index].result.contains('VCARD'))
          {
            print(_qrController.generatedQrList[index].result);
            vc = VCard(_qrController.generatedQrList[index].result);
            print(_qrController.generatedQrList[index].result);
            vc.name.forEach((element) => name = element );
            vc.typedEmail.forEach((element) => email = element.toString() );
            vc.typedAddress.map((e) => address.addNonNull(e)).toList();
            vc.typedTelephone.map((e) => phone.addNonNull(e)).toList();
          }
        // vc.typedAddress.forEach((element) => address = element.toString() );
        // vc.typedTelephone.forEach((element) => phone = element.toString() );
        // print('address:${address}');
        // print('phone: ${phone}');
        if(address.length > 0)
        {
          int size = address.length;
          print('size: $size');
          for(int i=0; i< size ; i++)
          {
            address_name.addAll({'address_${i+1}' : address[i][0]});
          }
          // to remove [#305, aa, bb, , Bangalore, Karnataka, 595666, India] use
          // substring(1, address_name['address_1'].toString().length - 1)
          print('address_name: ${address_name['address_1'].toString().substring(1, address_name['address_1'].toString().length - 1)}');
        }
        {
          int size = phone.length;
          print('size: $size');

          for(int i=0; i< size ; i++)
          {
            print(phone[i][1].toString().contains('[CELL]'));
            if(phone[i][1].toString().contains('[CELL]'))
            {
              contact.add('Cell : ${phone[i][0]}');
            }
            else if(phone[i][1].toString().contains('[FAX]'))
            {
              contact.add('Fax : ${phone[i][0]}');
            }
            else
            {
              contact.add('Phone : ${phone[i][0]}');
            }
            print('${phone[i][0]} --> ${phone[i][1]}');
          }
          // map.forEach((key, value) {
          //   contact.add('${key}:${value}');
          // });

          print('phone: $contact');
        }
        return (_qrController.generatedQrList[index].result.contains('VCARD')) ? Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: _showQrImage(index),),
            textView('Name:', name),
            textView('Email:', vc.email),
            (vc.gender == '') ? Container() :textView('Gender:', vc.gender),
            (vc.typedAddress.isEmpty) ? Container() : textView('Address', (address == null) ? '' : address_name['address_1'].toString().substring(1, address_name['address_1'].toString().length - 1)),
            ...contact.map((element) => Align(alignment: Alignment.centerLeft,child: Text(element, textAlign: TextAlign.left,))),


          ],
        ) : Column(
          children: [
            _showQrImage(index),
            Text('Result: ${_qrController.generatedQrList[index].result}')

          ],
        );
      }
  }
  
  textView(String key, String value)
  {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(key),
          ),
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(value, maxLines: 2,overflow: TextOverflow.clip,
                  softWrap: true,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _showQRDialog(BuildContext context)
  {
    // return Get.defaultDialog(
    //   title: "GeeksforGeeks",
    //   middleText: "Hello world!",
    //   backgroundColor: Colors.green,
    //   titleStyle: TextStyle(color: Colors.white),
    //   middleTextStyle: TextStyle(color: Colors.white),
    // );

    return showDialog(
        context: context,
        builder: (ctx)
        {
          return Dialog(
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                new Text("Loading"),
              ],
            ),
          );
        }
    );
  }


  _showQrImage(int index)
  {
    print('_showQrImage at index: $selectedIndex');
    if(selectedIndex == 0)
      {
        Image image = Utility.imageFromBase64String(_qrController.qrList[index].imgPath);
        return image;
      }
    else
      {
        Image image = Utility.imageFromBase64String(_qrController.generatedQrList[index].imgPath);
        return image;
      }
  }

  _nolistMsg()
  {
    return Center(
      child: Text('No QR LIST FOUND'),
    );
  }
}
