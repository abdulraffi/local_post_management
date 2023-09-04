library local_post_management;

export 'queue_model.dart';
export 'post_model.dart';
import 'package:flutter/foundation.dart';
import 'package:local_post_management/post_model.dart';
import 'package:local_post_management/queue_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// A Calculator.
class LocalPostManagement {
  Directory? directory;

  LocalPostManagement();

  Future<void> initialize() {
    return getApplicationDocumentsDirectory().then((value) {
      //chek apakah directory 'localpostqueue' sudah ada
      directory = Directory('${value.path}/localpostqueue');
      if (!directory!.existsSync()) {
        //jika belum ada, buat directory 'antrian'
        directory!.createSync();
      }
    });
  }

  Future<List<QueueModel>> getQueue() {
    //format penamaan file [id]#[name]#[createdDate]#[uploadedDate]#[status].json
    List<QueueModel> queue = [];
    //dapatkan semua file pada directory 'localpostqueue'
    return directory!.list().toList().then((value) {
      //urutkan berdasarkan tanggal pembuatan
      value.sort(
          (a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      //ambil file pertama
      for (FileSystemEntity file in value) {
        String fileName = file.path.split('/').last.split('.').first;
        try {
          queue.add(QueueModel(
            id: fileName.split('#')[0],
            name: file.path.split('#')[1],
            createdDate: DateTime.parse(fileName.split('#')[2].replaceAll('_', ':')),
            uploadedDate: fileName.split('#')[3] == '' ? null : DateTime.parse(fileName.split('#')[3].replaceAll('_', ':')),
            status: file.path.split('#')[4],
            filePath: file.path,
          ));
        } catch (e) {
          debugPrint("format file not valid $e");
        }
      }
      return queue;
    });
  }

  Future<QueueModel> addQueue({
    required String? name,
    required PostModel postModel,
  }){
    //format penamaan file [id]#[name]#[createdDate]#[uploadedDate]#[status].json
    String id = getNewId();
    String createdDate = DateTime.now().toIso8601String().replaceAll(':', '_');
    String status = 'pending';
    String fileName = '$id#$name#$createdDate##$status.json';
    //buat file baru
    return File('${directory!.path}/$fileName').create().then((value) {
      //tulis data ke file
      return value.writeAsString(postModel.toJson().toString()).then((value) {
        //buat QueueModel
        return QueueModel(
          id: id,
          name: name,
          createdDate: DateTime.parse(createdDate.replaceAll('_', ':')),
          uploadedDate: null,
          status: status,
          filePath: value.path,
        );
      });
    });
  }

  static String getNewId() {
    return "${DateTime.now().millisecondsSinceEpoch.toInt()}";
  }
}
