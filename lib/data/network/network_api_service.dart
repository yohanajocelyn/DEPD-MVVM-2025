import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:depd_mvvm_2025/data/app_exception.dart';
import 'package:depd_mvvm_2025/data/network/base_api_service.dart';
import 'package:depd_mvvm_2025/shared/shared.dart';
import 'package:http/http.dart' as http;

class NetworkApiService implements BaseApiService {
  @override
  Future getApiResponse(String endpoint) async {
    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.https(Const.baseUrl, Const.subUrl + endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
      );
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network request time out');
    }
  }

  @override
  Future postApiResponse(String url, data) {
    throw UnimplementedError();
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 500:
      case 404:
        throw UnauthorizedException(response.body.toString());
      default:
        throw FetchDataException(
          'Error occured while communicating with server',
        );
    }
  }
}
