import 'package:dio/dio.dart';

import '../../constants/constants.dart';

class DioHelper {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "https://maps.googleapis.com/maps/api/place/autocomplete/json",
  ));

  static Future<Response> get({
    Map<String, dynamic>? query,
  }) async {
    Response response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {'key': googleMapsApiKey, ...query!});

    return response;
  }
}
