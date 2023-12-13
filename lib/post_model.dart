class PostModel {
  Uri? url;
  Map<String, String> headers = {};
  Map<String, String> query = {};
  Map<String, dynamic> body = {};
  DateTime? lastTryDate;
  String? lastError;
  int? statusCode;

  PostModel({
    this.url,
    this.headers = const {},
    this.query = const {},
    this.body = const {},
    this.lastTryDate,
    this.lastError,
    this.statusCode,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    url = Uri.parse(json['url']);
    try {
      headers = json['headers']?.cast<String, String>() ?? {};
    } catch (e) {
      headers = {};
    }
    try {
      query = json['query']?.cast<String, String>() ?? {};
    } catch (e) {
      query = {};
    }
    try {
      body = json['body']?.cast<String, dynamic>() ?? {};
    } catch (e) {
      body = {};
    }
    lastTryDate = json['lastTryDate'] == null
        ? null
        : DateTime.parse(json['lastTryDate']);
    lastError = json['lastError'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url.toString();
    data['headers'] = headers;
    data['query'] = query;
    data['body'] = body;
    data['lastTryDate'] = lastTryDate?.toIso8601String();
    data['lastError'] = lastError;
    data['statusCode'] = statusCode;
    return data;
  }
}
