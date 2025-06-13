part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const AUTHENTICATION = _Paths.AUTHENTICATION;
  static const SIGNUP = '${_Paths.AUTHENTICATION}${_Paths.SIGNUP}';
  static const LOGIN = '${_Paths.AUTHENTICATION}${_Paths.LOGIN}';
  static const ORDERS = _Paths.ORDERS;
  // static const BUTTOM_NAV_BAR = _Paths.BUTTOM_NAV_BAR;
  static const BOTTOM_NAV_BAR = _Paths.BOTTOM_NAV_BAR;
  static const SELECTED_ORDERS = _Paths.SELECTED_ORDERS;
  static const HISTORY = _Paths.HISTORY;
  static const PROFILE = _Paths.PROFILE;
  static const LOCATION = _Paths.LOCATION;
  // static const AUTHENTICATION = _Paths.AUTHENTICATION;
  // static const SIGNUP = _Paths.SIGNUP; //adding
  // static const LOGIN = _Paths.LOGIN; //adding
  // static const LOGIN = _Paths.LOGIN;
  // static const SIGNUP = _Paths.SIGNUP;
  static const DOCUMENTS = _Paths.DOCUMENTS;
  static const PROFILE_DETAILS = _Paths.PROFILE_DETAILS;
  static const SPLASH = _Paths.SPLASH;
  static const EARNINGS = _Paths.EARNINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTHENTICATION = '/authentication';
  static const SIGNUP = '/signup'; //adding
  static const LOGIN = '/login'; //adding

  static const ORDERS = '/orders';
  // static const BUTTOM_NAV_BAR = '/buttom-nav-bar';
  static const BOTTOM_NAV_BAR = '/bottom-nav-bar';
  static const SELECTED_ORDERS = '/selected-orders';
  static const HISTORY = '/history';
  static const PROFILE = '/profile';
  static const LOCATION = '/location';
  // static const LOGIN = '/login';
  // // static const SIGNUP = '/signup';
  // static const AUTHENTICATION = '/authentication';
  static const DOCUMENTS = '/documents';
  static const PROFILE_DETAILS = '/profile-details';
  static const ONBO = '/onbo';
  static const SPLASH = '/splash';
  static const EARNINGS = '/earnings';
}
