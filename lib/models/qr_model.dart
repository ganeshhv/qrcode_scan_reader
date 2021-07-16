class QrModel
{
  int id;
  String imgName;
  String imgPath;
  String imgType;
  String qrType;
  String result;
  int ts;

  QrModel({this.id, this.imgName, this.imgPath, this.imgType, this.qrType, this.result, this.ts});

  QrModel.fromJson(Map json)
  {
    print('id:${json['id']},${json['id'].runtimeType}');
    print('name:${json['image_name']},${json['image_name'].runtimeType}');
    print('path:${json['img_path']},${json['img_path'].runtimeType}');
    print('ts:${json['ts']},${json['ts'].runtimeType}');

    id = json['id'];
    imgName = json['image_name'];
    imgPath = json['img_path'];
    imgType = json['img_type'];
    qrType = json['qr_type'] ?? '';
    result = json['result'];
    ts = json['ts'];
  }

  Map toJson() {
    final data = Map<String, Object>();
    data['id'] = id;
    data['image_name'] = imgName;
    data['ts'] = ts;
    data['img_type'] = imgType;
    data['qr_type'] = qrType;
    data['result'] = result;
    data['img_path'] = imgPath;

    print('qr model to json: $data');
    return data;
  }
}