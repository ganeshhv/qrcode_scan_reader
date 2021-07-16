import 'package:get/get.dart';
import 'package:qrcode_scan_reader/db/db_helper.dart';
import 'package:qrcode_scan_reader/models/qr_model.dart';

class QrController extends GetxController
{

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getQrData();
    getGeneratedQrData();
  }
  @override
  void onClose() {
    super.onClose();
    qrList.close();
    generatedQrList.close();
  }

  final qrList = <QrModel>[].obs;
  final generatedQrList = <QrModel>[].obs;

  // add qr data to table
  // scanned qr
  addQrData(QrModel model) async
  {
    return await DbHelper().save(model);
  }
  // generated qr
  addGeneratedQr(QrModel model) async{
    return await DbHelper().saveGenerateQr(model);
  }

  // get scanned qr data
  getQrData() async{
    List qrListData = await DbHelper().get();
    print('getcontroller get result:$qrListData');
    if(qrListData == null) qrList.clear();
    else qrList.assignAll(qrListData.map((data) => QrModel.fromJson(data)).toList());
  }

  //get generated qr
  getGeneratedQrData() async{
    List qrListData = await DbHelper().getGeneratedQr();
    print('getGeneratedQrData get result:$qrListData');
    if(qrListData == null) generatedQrList.clear();
    else {
      return generatedQrList
          .assignAll(qrListData.map((data) => QrModel.fromJson(data)).toList());
    }
  }

  // delete the scanned qr  data from db
  void deleteQr(List<int> id) async{
    await DbHelper().removeList(id);
    // once delete call data from list
    getQrData();
  }

  // delete the generated qr  data from db
  void deleteGeneratedQr(List<int> id) async{
    await DbHelper().removeGeneratedQrList(id);
    // once delete call data from list
    getGeneratedQrData();
  }



  // //update list
  // void updateQrList(int id) async
  // {
  //   await DbHelper.update(id);
  //   getQrData();
  // }

}