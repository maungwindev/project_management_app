import 'dart:async';
import 'package:get/get.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/local_data/shared_prefs.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/repository/user_repo.dart';

class UserController extends GetxController {
  final UserRepository userRepository;
   final SharedPref sharedPref;

  UserController({required this.userRepository,required this.sharedPref});

  var isLoading = false.obs;
  var users = <UserResponseModel>[].obs;
  var currentUserInfo = Rxn<UserResponseModel>();
  var errorMessage = ''.obs;

  var isCreating = false.obs;
  var isRegister = false.obs;
  var successMessage = ''.obs;

  StreamSubscription<Either<String, List<UserResponseModel>>>? _userSub;
  StreamSubscription<Either<String, UserResponseModel>>? _currentuserInfo;

  @override
  void onInit() {
    super.onInit();
    _subscribeUsers();
    _subscribeCurrentUser();
  }

  void _subscribeUsers() {
    isLoading.value = true;
    _userSub?.cancel();

    _userSub = userRepository.getUsers().listen(
      (either) {
        either.fold(
          (error) {
            errorMessage.value = error;
            isLoading.value = false;
          },
          (data) {
            users.assignAll(data);
            errorMessage.value = '';
            isLoading.value = false;
          },
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  void _subscribeCurrentUser() {
    isLoading.value = true;
    _currentuserInfo?.cancel();

    _currentuserInfo = userRepository.getUserInfo().listen(
      (either) {
        either.fold(
          (error) {
            errorMessage.value = error;
            isLoading.value = false;
          },
          (data) {
            currentUserInfo.value = data;
            errorMessage.value = '';
            isLoading.value = false;
          },
        );
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  Future<bool> createUser(
      {required String name,
      required String email,
      required String password}) async {
    isRegister.value = true;
    successMessage.value = '';
    errorMessage.value = '';

    final result = await userRepository.createUser(
        name: name, email: email, password: password);

    return await result.fold((l) {
      errorMessage.value = l;
      return false;
    }, (r) {

       sharedPref.setString(
          key: sharedPref.userInfo,
          value: email,
        );
      successMessage.value = r;
      isRegister.value = false;
      return true;
    });
  }

  Future<void> updateUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    final result = await userRepository.updateUser(
        userId: userId, name: name, email: email);
    result.fold((l) => errorMessage.value = l, (r) => successMessage.value = r);
  }

  Future<void> deleteUser({required String userId}) async {
    final result = await userRepository.deleteUser(userId: userId);
    result.fold((l) => errorMessage.value = l, (r) => successMessage.value = r);
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _currentuserInfo?.cancel();
    super.onClose();
  }
}
