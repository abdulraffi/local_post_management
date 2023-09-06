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
      headers = json['headers'] as Map<String, String>;
    } catch (e) {
      headers = {};
    }
    try {
      query = json['query'] as Map<String, String>;
    } catch (e) {
      query = {};
    }
    try {
      body = json['body'] as Map<String, dynamic>;
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
    data['headers'] = headers;
    data['query'] = query;
    data['body'] = body;
    data['lastTryDate'] = lastTryDate?.toIso8601String();
    data['lastError'] = lastError;
    return data;
  }
}
