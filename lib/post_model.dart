class PostModel{
  Uri? url;
  Map<String,dynamic> headers = {};
  Map<String,dynamic> query = {};
  Map<String,dynamic> body = {};

  PostModel({
    this.url,
    this.headers = const {},
    this.query = const {},
    this.body = const {},
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    url = Uri.parse(json['url']);
    headers = json['headers'];
    query = json['query'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['url'] = url.toString();
    data['headers'] = headers;
    data['query'] = query;
    data['body'] = body;
    return data;
  }
}