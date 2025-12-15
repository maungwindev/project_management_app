import 'package:get/get.dart';
import 'package:pm_app/models/response_models/category_model.dart';
import 'package:pm_app/repository/categories_repo.dart';

enum CategoryStatus { initial, loading, success, error }

class CategoryController extends GetxController {
  final CategoryRepository categoryRepo;

  CategoryController({required this.categoryRepo});

  // Reactive state
  var status = CategoryStatus.initial.obs;
  var categoryList = <CategoryModel>[].obs;
  var errorMessage = ''.obs;

  /// Fetch all categories
  Future<void> getAllCategories({required String languageCode}) async {
    status.value = CategoryStatus.loading;
    errorMessage.value = '';

    try {
      final result = await categoryRepo.getAllCategories(queryParams: {
        'lang': languageCode,
      });

      result.fold(
        (error) {
          status.value = CategoryStatus.error;
          errorMessage.value = error;
        },
        (data) {
          categoryList.assignAll(data);
          status.value = CategoryStatus.success;
        },
      );
    } catch (e) {
      status.value = CategoryStatus.error;
      errorMessage.value = e.toString();
    }
  }
}
