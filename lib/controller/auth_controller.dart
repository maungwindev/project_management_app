import 'package:get/get.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/repository/auth_repo.dart';
import 'package:fpdart/fpdart.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;
  final SharedPref sharedPref;

  AuthController({
    required this.authRepository,
    required this.sharedPref,
  });

  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  var isLoggedIn = false.obs;

  /// Login
  Future<bool> login({required Map<String, dynamic> requestBody}) async {
    isLoading.value = true;

    final Either<String, UserResponseModel> result =
        await authRepository.login(requestBody: requestBody);

    final success = result.fold(
      (failure) {
        _clearUser();
        return false;
      },
      (userResponse) {
        sharedPref.setString(
          key: sharedPref.bearerToken,
          value: userResponse.user.token ?? "",
        );
        user.value = userResponse.user;
        isLoggedIn.value = true;
        return userResponse.user.token != null;
      },
    );

    isLoading.value = false;
    return success;
  }

  /// Register
  Future<bool> register({required Map<String, dynamic> requestBody}) async {
    isLoading.value = true;

    final Either<String, UserResponseModel> result =
        await authRepository.register(requestBody: requestBody);

    final success = result.fold(
      (failure) {
        _clearUser();
        return false;
      },
      (userResponse) {
        sharedPref.setString(
          key: sharedPref.bearerToken,
          value: userResponse.user.token ?? "",
        );
        user.value = userResponse.user;
        isLoggedIn.value = true;
        return true;
      },
    );

    isLoading.value = false;
    return success;
  }

  /// Logout
  Future<void> logout() async {
    isLoading.value = true;

    final Either<String, UserResponseModel> result =
        await authRepository.logout();

    result.fold(
      (failure) => _clearUser(),
      (response) {
        if (response.status) _clearUser();
      },
    );

    isLoading.value = false;
  }

  /// Delete Account
  Future<void> deleteAccount(String userId) async {
    isLoading.value = true;

    final Either<String, UserResponseModel> result =
        await authRepository.delete(userId: userId);

    result.fold(
      (failure) => _clearUser(),
      (response) {
        if (response.status) _clearUser();
      },
    );

    isLoading.value = false;
  }

  /// Check login status
  Future<void> checkLoginStatus() async {
    isLoading.value = true;

    final token = await sharedPref.getString(key: sharedPref.bearerToken);

    if (token.isEmpty) {
      _clearUser();
    } else {
      final result = await authRepository.checkLoginStatus(
        url: "user/check-user",
      );

      result.fold(
        (failure) => _clearUser(),
        (response) {
          user.value = response.user;
          isLoggedIn.value = true;
        },
      );
    }

    isLoading.value = false;
  }

  /// Clear user
  void _clearUser() {
    sharedPref.setString(key: sharedPref.bearerToken, value: "");
    user.value = null;
    isLoggedIn.value = false;
  }
}
