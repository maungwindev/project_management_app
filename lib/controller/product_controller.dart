import 'package:get/get.dart';
import 'package:pm_app/models/response_models/product_model.dart';
import 'package:pm_app/repository/products_repo.dart';

class ProductsController extends GetxController {
  final ProductsRepo productRepo;

  ProductsController({required this.productRepo});

  var isLoading = false.obs;
  var products = <ProductModel>[].obs;
  var errorMessage = ''.obs;

  /// Get products by category
  Future<void> getProductsByCategory({
    required Map<String, dynamic> requestBody,
    required int categoryId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await productRepo.getProductsByCategory(
      categoryId: categoryId,
      requestBody: requestBody,
    );

    result.fold(
      (error) => errorMessage.value = error,
      (data) => products.assignAll(data),
    );

    isLoading.value = false;
  }

  /// Get all products
  Future<void> getAllProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await productRepo.getAllProducts(queryParams: {});

    result.fold(
      (error) => errorMessage.value = error,
      (data) => products.assignAll(data),
    );

    isLoading.value = false;
  }

  /// Test error
  Future<void> testError() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await productRepo.getErrors();

    result.fold(
      (error) => errorMessage.value = error,
      (data) => products.assignAll(data),
    );

    isLoading.value = false;
  }
}
