library local_post_management;

export 'queue_model.dart';
export 'post_model.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:local_post_management/error_handling_util.dart';
import 'package:local_post_management/network.dart';
import 'package:local_post_management/post_model.dart';
import 'package:local_post_management/queue_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// A Calculator.
class LocalPostManagement {
  Directory? directory;
  QueueStatus queueStatus = QueueStatus.idle;
  List<QueueModel> queue = [];
  StreamController<List<QueueModel>> queueController =
      StreamController<List<QueueModel>>.broadcast();
  StreamController<QueueStatus> queueStatusController =
      StreamController<QueueStatus>.broadcast();

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
            createdDate: DateTime.parse(fileName
                .split('#')[2]
                .replaceAll('_', ':')
                .replaceAll('--', '.')),
            uploadedDate: fileName.split('#')[3] == ''
                ? null
                : DateTime.parse(fileName
                    .split('#')[3]
                    .replaceAll('_', ':')
                    .replaceAll('--', '.')),
            status: fileName.split('#')[4],
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
  }) {
    //format penamaan file [id]#[name]#[createdDate]#[uploadedDate]#[status].json
    String id = getNewId();
    String createdDate = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '_')
        .replaceAll('.', '--');
    String status = 'pending';
    String fileName = '$id#$name#$createdDate##$status.json';
    //buat file baru
    return File('${directory!.path}/$fileName').create().then(
      (value) {
        //tulis data ke file
        return value.writeAsString(postModel.toJson().toString()).then((value) {
          //buat QueueModel
          return QueueModel(
            id: id,
            name: name,
            createdDate: DateTime.parse(
                createdDate.replaceAll('_', ':').replaceAll('--', '.')),
            uploadedDate: null,
            status: status,
            filePath: value.path,
          );
        });
      },
    );
  }

  //get queue and add to queue
  void loadQueue() {
    getQueue().then((value) {
      queue = value;
      queueController.add(queue);
    });
  }

  //add and load queue
  Future<QueueModel> addAndLoadQueue({
    required String? name,
    required PostModel postModel,
  }) {
    return addQueue(name: name, postModel: postModel).then((value) {
      queue.add(value);
      queueController.add(queue);
      return value;
    });
  }

  //run queue, mulai menjalankan antrian
  void startQueue() {
    if (queueStatus == QueueStatus.running) {
      return;
    } else {
      queueStatus = QueueStatus.running;
      queueStatusController.add(queueStatus);
      runQueue();
    }
  }

  //stop queue, stop menjalankan antrian
  void stopQueue() {
    queueStatus = QueueStatus.idle;
    queueStatusController.add(queueStatus);
  }

  //run queue, mulai menjalankan antrian
  void runQueue() {
    if (queueStatus == QueueStatus.running) {
      //ambil antrian pertama
      QueueModel queueModel =
          queue.firstWhere((element) => element.status == 'pending');
      //ubah status antrian menjadi running
      queueModel.status = 'running';
      //update status antrian
      queueController.add(queue);
      //jalankan antrian
      //read post data model from file
      File(queueModel.filePath ?? "").readAsString().then((value) {
        //upload post data model
        PostModel postModel = PostModel.fromJson(json.decode(value));
        Network.post(
          url: postModel.url!,
          body: postModel.body,
          headers: postModel.headers,
          querys: postModel.query,
        ).then((value) {
          //update sttus antrian menjadi success
          queueModel.status = 'success';
          queueModel.uploadedDate = DateTime.now();
          //update status antrian
          queueController.add(queue);
          //hapus file antrian
          File(queueModel.filePath ?? "").deleteSync();
          //hapus antrian dari list antrian
          queue.remove(queueModel);
          //jalankan antrian berikutnya
          runQueue();
        }).catchError((onError) {
          postModel.lastError = ErrorHandlingUtil.handleApiError(onError);
          postModel.lastTryDate = DateTime.now();
        });
      });
    }
  }

  static String getNewId() {
    return "${DateTime.now().millisecondsSinceEpoch.toInt()}";
  }
}

enum QueueStatus { idle, running }
