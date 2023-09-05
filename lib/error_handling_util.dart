import 'dart:convert';

import 'package:http/http.dart' as http;

class ErrorHandlingUtil {
  static handleApiError(
    dynamic error, {
    String? prefix = "",
    String? onTimeOut = "",
  }) {
    String message = "";
    if (error is FormatException) {
      message = error.toString();
    } else if (error is http.Response) {
      switch (error.statusCode) {
        case 401:
          message = "Unauthorized";
          break;
        default:
          message = error.body;
      }
    } else {
      message = error.toString();
    }

    message = "$prefix $message";

    return message.replaceAll('"', "");
  }

  static String readMessage(http.Response response) {
    try {
      return json.decode(response.body)["Message"].toString() == ""
          ? defaultMessage(response)
          : json.decode(response.body)["Message"].toString();
    } catch (e) {
      return defaultMessage(response);
    }
  }

  static String defaultMessage(http.Response response) {
    return "${response.body.isNotEmpty ? response.body : response.statusCode}";
  }
}
