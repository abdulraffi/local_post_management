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
  PostModel? postModel;

  QueueModel({
    this.id,
    this.createdDate,
    this.uploadedDate,
    this.name,
    this.status,
    this.filePath,
  });

  PostModel get readData {
    try {
      //baca file dari file path
      String data = File(filePath!).readAsStringSync();
      //convert ke PostModel
      postModel = PostModel.fromJson(jsonDecode(data));
      return postModel ?? PostModel();
    } catch (e) {
      return PostModel();
    }
  }

  Future<File> save() {
    return File(filePath ?? "").writeAsString(jsonEncode(postModel!.toJson()));
  }

  void updateFileName(Directory? directory) {
    String fileName =
        '$id#$name#${createdDate!.toIso8601String().replaceAll(':', '_').replaceAll('.', '--')}##$status.json';
    File(filePath ?? "").renameSync('${directory!.path}/$fileName');
    filePath = '${directory.path}/$fileName';
  }
}
