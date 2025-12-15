import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

enum InternetStatus { initial, loading, connected, disconnected }

class InternetConnectionController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  var status = InternetStatus.initial.obs;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  void _startListening() {
    status.value = InternetStatus.loading;

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        status.value = InternetStatus.loading;

        if (result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi)) {
          status.value = InternetStatus.connected;
        } else {
          status.value = InternetStatus.disconnected;
        }

        // if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        //   status.value = InternetStatus.connected;
        // } else {
        //   status.value = InternetStatus.disconnected;
        // }
      },
      onError: (error) {
        status.value = InternetStatus.disconnected;
      },
    );
  }

  /// Manually check connectivity
  Future<void> tryAgainInternet() async {
    status.value = InternetStatus.loading;

    try {
      final result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        status.value = InternetStatus.connected;
      } else {
        status.value = InternetStatus.disconnected;
      }
    } catch (_) {
      status.value = InternetStatus.disconnected;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
