import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_frame/controller/connection_controller.dart';
import 'package:project_frame/core/component/internet_error.dart';
import 'package:project_frame/core/component/loading_widget.dart';

class ConnectionAwareWidget extends StatelessWidget {
  const ConnectionAwareWidget({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final InternetConnectionController controller = Get.find();

    return Obx(() {
      switch (controller.status.value) {
        case InternetStatus.connected:
          // Call onRefresh() only once when connected (optional)
          // You can add a mechanism to avoid repeated calls if needed
          WidgetsBinding.instance.addPostFrameCallback((_) => onRefresh());
          return child;

        case InternetStatus.disconnected:
          return Center(child: InternetErrorWidget(onRetry: onRefresh));

        case InternetStatus.loading:
          return const LoadingWidget();

        case InternetStatus.initial:
        return const SizedBox.shrink();
      }
    });
  }
}
