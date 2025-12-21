// project_ui_controller.dart
import 'package:get/get.dart';

class ProjectUIController extends GetxController {
  final openCreateDialog = false.obs;

  void openCreate() => openCreateDialog.value = true;
  void reset() => openCreateDialog.value = false;
}
