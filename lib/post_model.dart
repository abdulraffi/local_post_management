import 'dart:convert';

class PostModel {
  Uri? url;
  Map<String, String> headers = {};
  Map<String, String> query = {};
  Map<String, dynamic> body = {};
  DateTime? lastTryDate;
  String? lastError;

  PostModel({
    this.url,
    this.headers = const {},
    this.query = const {},
    this.body = const {},
    this.lastTryDate,
    this.lastError,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    url = Uri.parse(json['url']);
    try {
      headers = json['headers'];
    } catch (e) {
      headers = {};
    }
    try {
      query = json['query'];
    } catch (e) {
      query = {};
    }
    try {
      body = json['body'];
    } catch (e) {
      body = {};
    }
    lastTryDate = json['lastTryDate'] == null
        ? null
        : DateTime.parse(json['lastTryDate']);
    lastError = json['lastError'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url.toString();
    data['headers'] = json.encode(headers);
    data['query'] = json.encode(query);
    data['body'] = json.encode(body);
    data['lastTryDate'] = lastTryDate?.toIso8601String();
    data['lastError'] = lastError;
    return data;
  }
}
