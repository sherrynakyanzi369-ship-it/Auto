import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../chat/chat_list_screen.dart';
import '../dashboard_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../parts/spare_parts_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final String ownerEmail = AuthService.instance.email;
    final pages = <Widget>[
      const DashboardScreen(),
      const MechanicsScreen(),
      const SparePartsScreen(),
      ChatListScreen(ownerEmail: ownerEmail),
      ProfileScreen(ownerEmail: ownerEmail),
    ];

    final body = IndexedStack(index: _index, children: pages);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => setState(() => _index = i),
                    extended: true,
                    minExtendedWidth: 220,
                    leading: const _BrandMark(),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.car_repair_outlined),
                        selectedIcon: Icon(Icons.car_repair),
                        label: Text('Mechanics'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.extension_outlined),
                        selectedIcon: Icon(Icons.extension),
                        label: Text('Parts'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.chat_bubble_outline),
                        selectedIcon: Icon(Icons.chat_bubble),
                        label: Text('Chats'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.car_repair_outlined),
                selectedIcon: Icon(Icons.car_repair),
                label: 'Mechanics',
              ),
              NavigationDestination(
                icon: Icon(Icons.extension_outlined),
                selectedIcon: Icon(Icons.extension),
                label: 'Parts',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D3B66), Color(0xFF1F7EB6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'AutoAssist',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D3B66),
                ),
              ),
              Text(
                'Roadside assistance',
                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}