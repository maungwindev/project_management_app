import 'package:flutter/material.dart';

void main() {
  runApp(const FlowsApp());
}

class FlowsApp extends StatelessWidget {
  const FlowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Inter', // Standard clean UI font
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar
          const SidebarWidget(),
          
          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                const TopNavbar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Integration",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Reconfigure your workflow and handle repetitive tasks with integration.",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        // 3. Grid of Cards
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            mainAxisExtent: 200,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) => const IntegrationCard(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sidebar Component
class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("FlowsApp", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 40),
          const SidebarItem(icon: Icons.person_outline, label: "My details"),
          const SidebarItem(icon: Icons.face_outlined, label: "Profile"),
          const SidebarItem(icon: Icons.auto_awesome_outlined, label: "Appearance"),
          const SidebarItem(icon: Icons.payment_outlined, label: "Billing"),
          const SidebarItem(icon: Icons.group_outlined, label: "Team"),
          const SidebarItem(icon: Icons.bolt, label: "Integration", isActive: true),
          const SidebarItem(icon: Icons.code, label: "API"),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const SidebarItem({super.key, required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isActive ? Colors.black : Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// Card Component
class IntegrationCard extends StatelessWidget {
  const IntegrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notion + Flows list", style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text("Activate", style: TextStyle(color: Colors.green, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              Icon(Icons.notes, size: 24),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.swap_horiz, color: Colors.grey)),
              Icon(Icons.grid_view_rounded, size: 24),
            ],
          ),
          const Spacer(),
          const Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: Colors.blueGrey),
              SizedBox(width: 8),
              Text("by Group", style: TextStyle(fontSize: 12, color: Colors.grey)),
              Spacer(),
              Icon(Icons.more_horiz, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}

class TopNavbar extends StatelessWidget {
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          const Text("Terro Agency", style: TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.keyboard_arrow_down),
          const Spacer(),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, size: 18), label: const Text("Create a custom workflow")),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            child: const Text("Request integration"),
          ),
        ],
      ),
    );
  }

  
}

