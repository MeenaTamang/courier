import 'package:get/get.dart';

class OrdersController extends GetxController {
  //TODO: Implement OrdersController
  // final ItemScrollController itemScrollController = ItemScrollController();
  // final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  // void scrollToIndex(int index) {
  //   itemScrollController.scrollTo(
  //     index: index,
  //     duration: const Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }

  final count = 0.obs;

  get boxHeight => null;

  get boxColor => null;

  get toggleBox => null;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
