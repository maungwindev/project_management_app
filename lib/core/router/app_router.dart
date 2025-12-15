import 'package:get/get.dart';
import 'package:pm_app/view/about/about.dart';
import 'package:pm_app/view/auth/page/login_page.dart';
import 'package:pm_app/view/home/test.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const LoginPage(),
  ),
  GetPage(
    name: '/test',
    page: () => const TestScreen(),
  ),
  GetPage(
    name: '/about',
    page: () => const AboutPage(),
  ),
];
