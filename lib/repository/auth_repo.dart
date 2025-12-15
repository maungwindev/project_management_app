import 'package:get/get.dart';
import 'package:pm_app/core/const/api_const.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/service/auth_service.dart';

/// AUTHENTICATION REPOSITORY
class AuthRepository {
  final AuthService authService;
  final DioClient dio;
  final CustomLogger logService;

  AuthRepository({required this.authRepository,required this.dio, required this.logService});

  /// Helper method for handling POST requests
  Future<Either<String, UserResponseModel>> _postRequest({
    required String apiUrl,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final response = await dio.postRequest(
        apiUrl: apiUrl,
        requestBody: requestBody,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        UserResponseModel user = UserResponseModel.fromMap(response.data);
        return Right(user);
      } else {
        return Left("${response.data["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      logService.log(
        "Error log : $e",
      );
      return Left(e.toString()); 
    }
  }

  /// Helper method for handling GET requests
  Future<Either<String, UserResponseModel>> _getRequest({
    required String apiUrl,
  }) async {
    try {
      final response = await dio.getRequest(apiUrl: apiUrl);
      if (response.statusCode == 200 || response.statusCode == 201) {
        UserResponseModel user = UserResponseModel.fromMap(response.data);
        return Right(user);
      } else {
        return Left("${response.data["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      logService.log(
        "Error log : $e",
      );
      return Left(e.toString()); 
    }
  }

  /// Helper method for handling DELETE requests
  Future<Either<String, UserResponseModel>> _deleteRequest({
    required String apiUrl,
  }) async {
    try {
      final response = await dio.deleteRequest(apiUrl: apiUrl, requestBody: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        UserResponseModel user = UserResponseModel.fromMap(response.data);
        return Right(user);
      } else {
        return Left("${response.data["message"] ?? "Unknown error"}");
      }
    } catch (e) {
      logService.log(
        "Error log : $e",
      );
      return Left(e.toString()); 
    }
  }

  /// Register
  Future<Either<String, UserResponseModel>> register({
    required Map<String, dynamic> requestBody,
  }) async {
    return await _postRequest(
      apiUrl: ApiConst.REGISTER,
      requestBody: requestBody,
    );
  }

  /// Login
  Future<Either<String, UserResponseModel>> login({
    required Map<String, dynamic> requestBody,
  }) async {

    final responseData = authService.login(requestBody: requestBody);
    return await _postRequest(
      apiUrl: ApiConst.LOGIN,
      requestBody: requestBody,
    );
  }

  /// Logout
  Future<Either<String, UserResponseModel>> logout() async {
    return await _postRequest(apiUrl: ApiConst.LOGOUT, requestBody: {});
  }

  /// Delete
  Future<Either<String, UserResponseModel>> delete(
      {required String userId}) async {
    return await _deleteRequest(apiUrl: ApiConst.DELETE_ACCOUNT);
  }

  /// Check Login Status
  Future<Either<String, UserResponseModel>> checkLoginStatus({
    required String url,
  }) async {
    return await _getRequest(apiUrl: url);
  }

  /// Forget Password
  Future<Either<String, bool>> forgetPassword(
      {required String phoneNumber}) async {
    final response = await _postRequest(
      apiUrl: ApiConst.FORGET_PASSWORD,
      requestBody: {"phone": phoneNumber},
    );
    return response.map((user) => user.status);
  }

  /// Get OTP to register new account
  Future<Either<String, UserResponseModel>> getOTPtoRegister(
      {required String phoneNumber}) async {
    return await _postRequest(
      apiUrl: ApiConst.GET_OTP,
      requestBody: {"phone": phoneNumber},
    );
  }

  /// Resend OTP
  Future<Either<String, bool>> resendOTP({required String phoneNumber}) async {
    final response = await _postRequest(
      apiUrl: ApiConst.RESEND_OTP,
      requestBody: {"phone": phoneNumber},
    );
    return response.map((user) => user.status);
  }

  /// Verify OTP for Forget Password
  Future<Either<String, bool>> verifyOTPforForgetPassword({
    required String phoneNumber,
    required String code,
  }) async {
    final response = await _postRequest(
      apiUrl: ApiConst.VERIFY_OTP,
      requestBody: {
        "phone": phoneNumber,
        "code": code,
      },
    );
    return response.map((user) => user.status);
  }

  /// Reset Password
  Future<Either<String, UserResponseModel>> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    return await _postRequest(
      apiUrl: ApiConst.RESET_PASSWORD,
      requestBody: {
        "phone": phoneNumber,
        "new_password": newPassword,
      },
    );
  }

  /// Change Password
  Future<Either<String, UserResponseModel>> changePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    return await _postRequest(
      apiUrl: ApiConst.CHANGE_PASSWORD,
      requestBody: {
        "old_password": oldPassword,
        "new_password": newPassword,
      },
    );
  }
}
