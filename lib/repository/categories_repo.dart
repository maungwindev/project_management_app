import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/const/api_const.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/models/response_models/category_model.dart';

class CategoryRepository {
  final DioClient dioClient;
  final CustomLogger logger;
  
  CategoryRepository({required this.dioClient, required this.logger});

  /// Get all categories list
  Future<Either<String, List<CategoryModel>>> getAllCategories({
    required Map<String, String> queryParams,
  }) async {
    try {
      final data = await dioClient.getRequest<Map<String, dynamic>>(
        apiUrl: ApiConst.CATEGORIES,
        queryParams: queryParams,
      );

      // The DioClient already verified the status code is successful (2xx)
      // So we can directly process the data
      final dataList = data["data"] as List;
      final categories = dataList.map((e) => CategoryModel.fromMap(e)).toList();
      return Right(categories);
    } catch (e) {
      logger.log("CategoryRepository - getAllCategories - Unexpected error: $e");
      return Left("${e}");
    }
  }
}