import 'dart:developer';

import 'package:path/path.dart';
import 'package:qrcode_scan_reader/models/qr_model.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper
{
  static Database _db;
  static final int version = 1;
  static final String tableNameScan = 'qrData';
  static final String tableNameGenerate = 'generateQr';
  static final String databaseName = 'qr.db';

  static final String ID = 'id';
  static final String NAME = 'image_name';
  static final String IMG_PATH = 'img_path';
  static final String IMG_TYPE = 'img_type';
  static final String QR_TYPE = 'qr_type';
  static final String TS = 'ts';

  Future<Database> initDb() async{
    String path = await getDatabasesPath();
    print(await getDatabasesPath());
    print(await databaseExists(path));
    print('db path :${path}/${databaseName}');
    return openDatabase(
        '${path}/${databaseName}',
      version: version,
      onCreate: (db, version) async
        {
          await db.execute(
            "CREATE TABLE $tableNameScan($ID INTEGER PRIMARY KEY AUTOINCREMENT,"
                "$NAME STRING NOT NULL,"
                "$IMG_PATH STRING ,"
                "$IMG_TYPE String, "
                "$QR_TYPE String, "
                "result STRING,"
                "$TS INTEGER"
                ")"
          );
          await db.execute(
              "CREATE TABLE $tableNameGenerate($ID INTEGER PRIMARY KEY AUTOINCREMENT,"
                  "$NAME STRING NOT NULL,"
                  "$IMG_PATH STRING ,"
                  "$IMG_TYPE String, "
                  "$QR_TYPE String, "
                  "result STRING,"
                  "$TS INTEGER"
                  ")"
          );
        }
    );
  }

  //ADD DATA
  save(QrModel model) async
  {
    final Database db = await initDb();
    print('insert called ${model.toJson()}');
    var res = await db.insert(tableNameScan, model.toJson());
    print('dbhelper save result: $res');
    return res;
  }

  // add generated qr
  saveGenerateQr(QrModel model) async
  {
    final Database db = await initDb();
    print('generate qr called');
    var res = await db.insert(tableNameGenerate, model.toJson());
    print('saveGenerateQr result: $res');
  }

  get() async{
    final Database db = await initDb();
    print('get qr data called');
    var res = await db.query(tableNameScan);
    print('dbhelper get qr result: $res');
    if(res.isNotEmpty) return res;
    else return [];
  }

  getGeneratedQr() async{
    final Database db = await initDb();
    print('getGenerateQr called');
    var res = await db.query(tableNameGenerate);
    print('getGenerateQr result: $res');
    if(res.isNotEmpty) return res;
    else return [];
  }

  Future removeList(List<int> id) async{
    var ids;
    var abc;
    _db = await initDb();
    ids = id.join(",");
    abc = await _db.rawDelete('DELETE FROM $tableNameScan WHERE ID IN ($ids)');
    print(ids);
    print('delete called: $abc');
  }

  removeGeneratedQrList(List<int> id) async{
    print('removeGeneratedQrList');
    var ids;
    var abc;
    _db = await initDb();
    ids = id.join(",");
    abc = await _db.rawDelete('DELETE FROM $tableNameGenerate WHERE ID IN ($ids)');
    print(ids);
    print('removeGeneratedQrList delete called: $abc');
  }

}

//vcard type
// BEGIN:VCARD
// VERSION:3.0
// N:a;a
// ORG:fab
// EMAIL;TYPE=INTERNET:ajatashatru@gmail.com
// URL:abc.com
// TEL;TYPE=CELL:1234
// TEL:09845083994
// TEL;TYPE=FAX:125
// ADR:;;Flat no.\, A-403\, Meenakshi Classic\, #471\, 27th Main\, 1st Sector\, HSR Layout;Bangalore;Karnataka;560102;India
// END:VCARD,

//sms
// //SMSTO:8123456000:abcdef
//   nn
//
//url http://www.hvg.co
//phone tel:1234567890
