import 'package:fpdart/fpdart.dart';
import 'package:pm_app/models/response_models/user_model.dart';
import 'package:pm_app/service/user_service.dart';
import 'package:pm_app/core/utils/custom_logger.dart';

class UserRepository {
  final UserService userService;
  final CustomLogger logger;

  UserRepository({required this.userService, required this.logger});

  Future<Either<String, String>> createUser(
      {required String name,
      required String email,
      required String password}) async {
    final result = await userService.createUser(
        requestBody: {'name': name, 'email': email, 'password': password});
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Stream<Either<String, List<UserResponseModel>>> getUsers() {
    return userService.getUsers();
  }

  Stream<Either<String, UserResponseModel>> getUserInfo() {
    return userService.getCurrentUser();
  }

  Future<Either<String, String>> updateUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    final result =
        await userService.updateUser(userId: userId, name: name, email: email);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

  Future<Either<String, String>> deleteUser({required String userId}) async {
    final result = await userService.deleteUser(userId: userId);
    return result.fold((l) => Left(l), (r) => Right(r));
  }

   Future<Either<bool ,UserResponseModel>> checkUser({required String email}) async{
    return await userService.checkUser(email: email);
  }
}
