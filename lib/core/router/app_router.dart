import 'package:get/get.dart';
import 'package:pm_app/injection.dart';
import 'package:pm_app/view/about/about.dart';
import 'package:pm_app/view/auth/auth_page.dart';
import 'package:pm_app/view/auth/page/login_page.dart';
import 'package:pm_app/view/auth/page/register_page.dart';
import 'package:pm_app/view/home/create_task.dart';
import 'package:pm_app/view/home/home.dart';
import 'package:pm_app/view/home/member_page.dart';
import 'package:pm_app/view/home/setting.dart';
import 'package:pm_app/view/home/task.dart';
import 'package:pm_app/view/home/task_detail.dart';
import 'package:pm_app/view/home/test.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => AuthGate(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginPage(),
  ),
  GetPage(
    name: '/register',
    page: () => const RegisterPage(),
  ),
  GetPage(
    name: '/home',
    page: () => const HomeScreen(),
    binding: AppBindings(), // <-- add this
  ),
  GetPage(
    name: '/test',
    page: () => const TestScreen(),
  ),
  GetPage(
    name: '/tasks',
    page: () => TaskScreen(),
  ),
  GetPage(
    name: '/create-task',
    page: () => NewTaskScreen(),
  ),
  GetPage(
    name: '/about',
    page: () => const AboutPage(),
  ),
  GetPage(
    name: '/setting',
    page: () => const SettingScreen(),
  ),
  GetPage(
    name: '/members',
    page: () => const MemberPage(),
  ),
  GetPage(
    name: '/task-detail',
    page: () => const TaskDetailScreen(),
  ),
];
