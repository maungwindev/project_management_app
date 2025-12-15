import 'package:flutter/material.dart';
import 'package:pm_app/core/component/custom_error_widget.dart';
import 'package:pm_app/core/component/internet_error.dart';
import 'package:pm_app/core/component/loading_widget.dart';
import 'package:pm_app/view/theme/swith_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Frame"),
        actions: [
          ThemeSwitch()
        ],
      ),
      body: ScreenTypeLayout.builder(
        mobile: (context) => _buildMobileLayout(),
        tablet: (context) => _buildTabletLayout(),
        desktop: (context) => _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.phone_android, size: 60),
          SizedBox(height: 16),
          Text("Mobile Layout", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.tablet, size: 80),
          SizedBox(height: 16),
          Text("Tablet Layout", style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          Icon(Icons.desktop_windows, size: 100),
          SizedBox(height: 16),
          Text("Desktop Layout", style: TextStyle(fontSize: 28)),
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text("Hello world!"),
                  Text("How are you!"),
                ],
              ),
            ),
          ),
          CustomErrorWidget(errorText: "errorText"),
          InternetErrorWidget(),
          LoadingWidget(radius: 33),
        ],
      ),
    );
  }
}

