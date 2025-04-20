import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/Documents/bindings/documents_binding.dart';
import '../modules/Documents/views/documents_view.dart';
import '../modules/History/bindings/history_binding.dart';
import '../modules/History/views/history_view.dart';
import '../modules/Profile/bindings/profile_binding.dart';
import '../modules/Profile/views/profile_view.dart';
import '../modules/ProfileDetails/bindings/profile_details_binding.dart';
import '../modules/ProfileDetails/views/profile_details_view.dart';
import '../modules/SelectedOrders/bindings/selected_orders_binding.dart';
import '../modules/SelectedOrders/views/selected_orders_view.dart';
import '../modules/authentication/bindings/authentication_binding.dart';
import '../modules/authentication/views/authentication_view.dart';
import '../modules/authentication/views/login_screen.dart';
import '../modules/authentication/views/signup_screen.dart';
import '../modules/bottomNavBar/bindings/bottom_nav_bar_binding.dart';
import '../modules/bottomNavBar/views/bottom_nav_bar_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';

// import '../modules/authentication/bindings/authentication_binding.dart';
// import '../modules/authentication/views/authentication_view.dart';
// import '../modules/authentication/views/login_screen.dart';
// import '../modules/authentication/views/signup_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME; //HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTHENTICATION,
      page: () => const AuthenticationView(),
      children: [
        //adding
        GetPage(
            name: _Paths.SIGNUP,
            page: () => SignUpScreen(controller: PageController())),
        GetPage(
            name: _Paths.LOGIN,
            page: () => LoginScreen(controller: PageController())),
      ],
      binding: AuthenticationBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV_BAR,
      page: () => BottomNavBarView(userId: Get.arguments as String),
      binding: BottomNavBarBinding(),
    ),
    GetPage(
      name: _Paths.SELECTED_ORDERS,
      page: () => const SelectedOrdersView(),
      binding: SelectedOrdersBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(userId: Get.arguments as String),
      binding: ProfileBinding(),
    ),
    // GetPage(
    //   name: _Paths.AUTHENTICATION,
    //   page: () => const AuthenticationView(),
    //   binding: AuthenticationBinding(),
    // ),
    GetPage(
      name: _Paths.DOCUMENTS,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_DETAILS,
      page: () => const ProfileDetailsView(),
      binding: ProfileDetailsBinding(),
    ),
  ];
}
