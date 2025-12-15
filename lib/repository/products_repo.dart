import 'package:fpdart/fpdart.dart';
import 'package:pm_app/core/const/api_const.dart';
import 'package:pm_app/core/network/dio_client.dart';
import 'package:pm_app/core/utils/custom_logger.dart';
import 'package:pm_app/core/utils/exception.dart';
import 'package:pm_app/models/response_models/product_model.dart';

class ProductsRepo {
  
  final DioClient dioClient;
  final CustomLogger logger;

  ProductsRepo({
    required this.dioClient,
    required this.logger,
  });

  /// Get products by category (POST)
  Future<Either<String, List<ProductModel>>> getProductsByCategory({
    required int categoryId,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final data = await dioClient.postRequest<List<dynamic>>(
        apiUrl: "${ApiConst.productsByCategory}/$categoryId",
        requestBody: requestBody,
      );
      return Right(data.map((e) => ProductModel.fromJson(e)).toList());
    } on ApiException catch (e) {
      logger.log("ProductsRepo : getProductsByCategory': $e");
      return Left(e.message);
    } catch (e) {
      logger.log("ProductsRepo : getProductsByCategory': $e");
      return Left("Something went wrong");
    }
  }

  /// Get all products (GET)
  Future<Either<String, List<ProductModel>>> getAllProducts({
    required Map<String, String> queryParams,
  }) async {
    try {
      final data = await dioClient.getRequest<List<dynamic>>(
        apiUrl: ApiConst.allProducts,
        queryParams: queryParams,
      );
      return Right(data.map((e) => ProductModel.fromJson(e)).toList());
    } on ApiException catch (e) {
      logger.logWarning("Error log : $e",
          error: 'ProductsRepo : getAllProducts');
      return Left(e.message);
    } catch (e) {
      logger.logWarning("Error log : $e",
          error: 'ProductsRepo : getAllProducts');
      return Left("Something went wrong");
    }
  }

  /// Get all products (GET)
  Future<Either<String, List<ProductModel>>> getErrors() async {
    try {
      final data = await dioClient.getRequest(
        apiUrl: ApiConst.error,
      );
      return Right(data.map((e) => ProductModel.fromJson(e)).toList());
    } catch (e) {
      logger.logWarning("Error log : $e",
          error: 'ProductsRepo : getAllProducts');
      return Left(e.toString());
    }
  }
}
