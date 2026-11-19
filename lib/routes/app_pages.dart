import 'package:get/get.dart';

import '../views/detail_view.dart';
import '../views/home_view.dart';
import '../views/search_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => const DetailView(),
    ),
  ];
}
