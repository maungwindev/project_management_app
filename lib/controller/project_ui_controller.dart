// project_ui_controller.dart
import 'package:get/get.dart';

class ProjectUIController extends GetxController {
  final openCreateDialog = false.obs;

  // Add this
  var selectedFilter = 'All'.obs;

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void openCreate() => openCreateDialog.value = true;
  void reset() => openCreateDialog.value = false;
}
