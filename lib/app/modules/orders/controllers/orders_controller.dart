import 'package:courier/app/data/models/order_model.dart';
import 'package:courier/app/data/services/api_service.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  var isLoading = true.obs;
  var orderList = <Order>[].obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  void fetchOrders() async {
    try {
      isLoading(true);
      var orders = await ApiService().fetchOrders();
      orderList.value = orders;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  // final count = 0.obs;

  // get boxHeight => null;

  // get boxColor => null;

  // get toggleBox => null;
  // @override
  // void onInit() {
  //   super.onInit();
  // }

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  // void increment() => count.value++;
}
