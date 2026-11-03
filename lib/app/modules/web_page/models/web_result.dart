class WebResult {
  int code;
  String message;
  dynamic data;
  WebResult({required this.code, required this.message, this.data});

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "message": message,
      "data": data,
    };
  }
}