import 'dart:convert';
import 'dart:io';

import 'package:local_post_management/post_model.dart';

class QueueModel {
  String? id;
  DateTime? createdDate;
  DateTime? uploadedDate;
  String? name;
  String? status;
  String? filePath;

  QueueModel({
    this.id,
    this.createdDate,
    this.uploadedDate,
    this.name,
    this.status,
    this.filePath,
  });

  Future<PostModel> get postModel {
    //read file from filePath
    return File(filePath!).readAsString().then((value) {
      //convert to json
      var json = jsonDecode(value);
      //convert to PostModel
      return PostModel.fromJson(json);
    }).catchError((onError){
      throw onError;
    });
  }
}