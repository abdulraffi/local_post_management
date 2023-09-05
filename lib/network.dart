import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Network {
  static Future<dynamic> post({
    required Uri url,
    Map<String, String>? querys,
    String? relativeUrl = "",
    Map<String, dynamic>? body,
    Encoding? encoding,
    Map<String, String>? headers,
  }) {
    DateTime timeStamp = DateTime.now();
    debugPrint("url $url");
    debugPrint("body $body");
    Map<String, String> newHeaders = headers ?? {};

    newHeaders.addAll(
      {
        "Content-Type": "application/json",
        "Client-Timestamp": formatISOTime(timeStamp),
        "Access-Control_Allow_Origin": "*",
      },
    );

    Map<String, String> newQuery = {};
    if (url.hasQuery) {
      newQuery.addAll(url.queryParameters);
    }
    if (querys != null && querys.isNotEmpty) {
      newQuery.addAll(querys);
    }

    Uri uri = Uri(
      fragment: url.fragment,
      scheme: url.scheme,
      host: url.host,
      path: url.path,
      port: url.port,
      queryParameters: newQuery,
      userInfo: url.userInfo,
    );

    return http
        .post(
      uri,
      body: json.encode(body),
      // encoding: encoding ?? Encoding.getByName("apliaction/json"),
      headers: newHeaders,
    )
        .then(
      (http.Response response) {
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw response;
        }
      },
    ).catchError((e) {
      if (e is SocketException) {
        throw SocketException(e.message);
      } else {
        throw e;
      }
    });
  }

  static Future<dynamic> get({
    required Uri url,
    Map<String, String>? querys,
    String? relativeUrl = "",
    Encoding? encoding,
    Map<String, String>? headers,
  }) {
    DateTime timeStamp = DateTime.now();

    Map<String, String> newHeaders = headers ?? {};

    newHeaders.addAll({
      "Content-Type": "application/json",
      "Client-Timestamp": formatISOTime(timeStamp),
      'Access-Control-Allow-Origin': '*', // Replace your domain
    });

    Map<String, String> newQuery = {};
    if (url.hasQuery) {
      newQuery.addAll(url.queryParameters);
    }
    if (querys != null && querys.isNotEmpty) {
      newQuery.addAll(querys);
    }

    Uri uri = Uri(
      fragment: url.fragment,
      scheme: url.scheme,
      host: url.host,
      path: url.path,
      port: url.port,
      queryParameters: newQuery,
      userInfo: url.userInfo,
    );

    return http
        .get(
      uri,
      headers: newHeaders,
    )
        .then(
      (http.Response response) {
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw response;
        }
      },
    ).catchError((e) {
      if (e is SocketException) {
        throw SocketException(e.message);
      } else {
        throw e;
      }
    }).whenComplete(() {
      debugPrint("GET $uri");
    });
  }

  static String formatISOTime(DateTime date) {
    var duration = date.timeZoneOffset;
    if (duration.isNegative) {
      return ("${DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date)}-${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    } else {
      return ("${DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date)}+${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    }
  }
}
