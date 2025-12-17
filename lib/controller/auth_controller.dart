import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
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
  var userEmail = Rxn<String>();
  var isLoggedIn = false.obs;

  /// Login
  Future<bool> login({required Map<String, dynamic> requestBody}) async {
    isLoading.value = true;

    final Either<String, User> result =
        await authRepository.login(requestBody: requestBody);

    final success = result.fold(
      (failure) {
        clearUser();
        return false;
      },
      (userResponse) {
        sharedPref.setString(
          key: sharedPref.userInfo,
          value: userResponse.email ?? '',
        );
        userEmail.value = userResponse.email;
        isLoggedIn.value = true;
        return true;
      },
    );

    isLoading.value = false;
    return success;
  }

  /// Register
  // Future<bool> register({required Map<String, dynamic> requestBody}) async {
  //   isLoading.value = true;

  //   final Either<String, UserResponseModel> result =
  //       await authRepository.register(requestBody: requestBody);

  //   final success = result.fold(
  //     (failure) {
  //       _clearUser();
  //       return false;
  //     },
  //     (userResponse) {
  //       sharedPref.setString(
  //         key: sharedPref.bearerToken,
  //         value: userResponse.user.token ?? "",
  //       );
  //       user.value = userResponse.user;
  //       isLoggedIn.value = true;
  //       return true;
  //     },
  //   );

  //   isLoading.value = false;
  //   return success;
  // }

  /// Logout
  // Future<void> logout() async {
  //   isLoading.value = true;

  //   final Either<String, UserResponseModel> result =
  //       await authRepository.logout();

  //   result.fold(
  //     (failure) => _clearUser(),
  //     (response) {
  //       if (response.status) _clearUser();
  //     },
  //   );

  //   isLoading.value = false;
  // }

  /// Delete Account
  // Future<void> deleteAccount(String userId) async {
  //   isLoading.value = true;

  //   final Either<String, UserResponseModel> result =
  //       await authRepository.delete(userId: userId);

  //   result.fold(
  //     (failure) => _clearUser(),
  //     (response) {
  //       if (response.status) _clearUser();
  //     },
  //   );

  //   isLoading.value = false;
  // }

  /// Check login status
  Future<void> checkLoginStatus() async {
    isLoading.value = true;

    final userInfo = await sharedPref.getString(key: sharedPref.userInfo);

    if (userInfo.isEmpty) {
      clearUser();
    } else {
      isLoggedIn.value = true;
      userEmail.value = userInfo;
      
    }

    isLoading.value = false;
  }

  /// Clear user
  void clearUser() {
    sharedPref.setString(key: sharedPref.userInfo, value: "");
    userEmail.value = null;
    isLoggedIn.value = false;
  }
}
