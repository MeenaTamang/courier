import 'package:get/get.dart';

import '../controllers/selected_orders_controller.dart';

class SelectedOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectedOrdersController>(
      () => SelectedOrdersController(),
    );
  }
}
