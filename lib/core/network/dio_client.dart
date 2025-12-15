import 'package:dio/dio.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/core/utils/exception.dart';

class DioClient {
  final SharedPref sharedPref;
  final Dio dio;

  DioClient({required this.sharedPref, required this.dio});

  /// Common request headers
  Future<Map<String, String>> _getHeaders() async {
    String? token = await sharedPref.getString(key: sharedPref.bearerToken);
    return {'Authorization': 'Bearer $token'};
  }

  /// Handle the response and throw appropriate exceptions
  T _handleResponse<T>(Response<T> response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data!;
    } else {
      final errorMessage = _getErrorMessage(response);

      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(errorMessage);
        case 404:
          throw NotFoundException(errorMessage);
        case 500:
          throw ServerErrorException(errorMessage);
        default:
          throw ApiException(errorMessage, response.statusCode);
      }
    }
  }

  /// Extract error message from response
  String _getErrorMessage(Response response) {
    try {
      if (response.data is Map && response.data['message'] != null) {
        return response.data['message'];
      }
      final message = response.statusMessage ?? 'Unknown error occurred';

      if (response.statusCode == 404) {
        return "Url not found!";
      }

      if (message.isEmpty) {
        return "Unknow error occured!";
      }

      return message;
    } catch (e) {
      return 'Failed to parse error message';
    }
  }

  /// GET Request
  Future<T> getRequest<T>({
    required String apiUrl,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final defaultHeaders = await _getHeaders();
      final response = await dio.get<T>(
        apiUrl,
        queryParameters: queryParams,
        options: Options(
          headers: {
            ...defaultHeaders,
            ...?headers,
          },
          receiveDataWhenStatusError: true,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
            _getErrorMessage(e.response!), e.response?.statusCode);
      }
      throw ApiException(e.message ?? 'Network error occurred');
    }
  }

  /// POST Request
  Future<T> postRequest<T>({
    required String apiUrl,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post<T>(
        apiUrl,
        data: requestBody,
        options: Options(
          headers: headers,
          receiveDataWhenStatusError: true,
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
            _getErrorMessage(e.response!), e.response?.statusCode);
      }
      throw ApiException(e.message ?? 'Network error occurred');
    }
  }

  /// POST Request with Custom Header
  Future<T> postRequestWithCustomHeader<T>({
    required String apiUrl,
    required Map<String, dynamic> requestBody,
    required Map<String, dynamic> header,
  }) async {
    try {
      final response = await dio.post<T>(
        apiUrl,
        data: requestBody,
        options: Options(headers: header),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
            _getErrorMessage(e.response!), e.response?.statusCode);
      }
      throw ApiException(e.message ?? 'Network error occurred');
    }
  }

  /// DELETE Request
  Future<T> deleteRequest<T>({
    required String apiUrl,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.delete<T>(
        apiUrl,
        data: requestBody,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          _getErrorMessage(e.response!),
          e.response?.statusCode,
        );
      }
      throw ApiException(e.message ?? 'Network error occurred');
    }
  }

  /// PUT Request
  Future<T> putRequest<T>({
    required String apiUrl,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.put<T>(
        apiUrl,
        data: requestBody,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          _getErrorMessage(e.response!),
          e.response?.statusCode,
        );
      }
      throw ApiException(e.message ?? 'Network error occurred');
    }
  }
}
