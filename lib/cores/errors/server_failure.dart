import 'package:dio/dio.dart';

abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.dioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('connection timeout with server');
      case DioExceptionType.sendTimeout:
        return ServerFailure('send timeout wiht server');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('receive timeout with server');
      case DioExceptionType.badCertificate:
        return ServerFailure('bad certificate, try again');
      case DioExceptionType.badResponse:
        return ServerFailure.dioResponse(dioException.response?.statusCode ?? 0,
            dioException.response?.data);
      case DioExceptionType.cancel:
        return ServerFailure('operation is canceled, try again');
      case DioExceptionType.connectionError:
        return ServerFailure('check your internet connection');
      case DioExceptionType.unknown:
        return ServerFailure('unknown error, try again');
    }
  }

  factory ServerFailure.dioResponse(int statusCode, dynamic response) {
    if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 402 ||
        statusCode == 403) {
      return ServerFailure(response['errors'].values.toList().first[0]);
    } else if (statusCode == 404) {
      return ServerFailure('Your request not found, try again');
    } else if (statusCode == 500) {
      return ServerFailure('Server Error, try again');
    } else {
      return ServerFailure('Something is wrong, try again');
    }
  }
}
