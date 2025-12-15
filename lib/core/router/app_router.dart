import 'package:get/get.dart';
import 'package:project_frame/view/about/about.dart';
import 'package:project_frame/view/home/home.dart';
import 'package:project_frame/view/home/test.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const HomeScreen(),
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
