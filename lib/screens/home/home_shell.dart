import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/session_gate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/collapsible_sidebar.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/services_sheet.dart';
import '../chat/chat_list_screen.dart';
import '../dashboard_screen.dart';
import '../mechanics/mechanics_screen.dart';
import '../parts/spare_parts_screen.dart';
import '../profile/profile_screen.dart';

/// Root shell for both guests and signed-in drivers.
///
/// Guests are never forced into the auth flow on open — they land on the
/// dashboard. Services (mechanics, parts, chats, profile, SOS, …) prompt for
/// an account the moment they are requested.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const double _desktopBreakpoint = 900;

  /// Tab indexes that require a registered account.
  static const Set<int> _protectedTabs = {1, 2, 3, 4};

  bool get _isGuest => AuthService.instance.isGuest;

  Future<void> _selectTab(int index) async {
    if (index == _index) return;
    if (_protectedTabs.contains(index) && _isGuest) {
      final ok = await requireAccount(
        context,
        reason: 'Sign in to access this part of AutoAssist.',
      );
      if (!ok || !mounted) return;
    }
    setState(() => _index = index);
  }

  Future<void> _openServices() async {
    final option = await showServicesSheet(context, isGuest: _isGuest);
    if (option == null || !mounted) return;
    await openService(context, option);
  }

  Future<void> _signIn() async {
    await requireAccount(context, reason: 'Sign in to continue with AutoAssist.');
    if (mounted) setState(() {});
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final String ownerEmail = AuthService.instance.email;
    final String userName =
        AuthService.instance.currentUser?.name ?? 'Guest';

    // Locked tabs are not built for guests: this avoids eagerly running
    // location lookups and authenticated API calls they cannot reach anyway.
    final pages = <Widget>[
      const DashboardScreen(),
      _isGuest ? const _LockedTab() : const MechanicsScreen(),
      _isGuest ? const _LockedTab() : const SparePartsScreen(),
      _isGuest
          ? const _LockedTab()
          : ChatListScreen(ownerEmail: ownerEmail),
      _isGuest
          ? const _LockedTab()
          : ProfileScreen(ownerEmail: ownerEmail, onSignOut: _logout),
    ];

    // Rebuild all tabs from scratch whenever the auth state flips so stale
    // account data is never shown to a freshly signed-out guest.
    final body = KeyedSubtree(
      key: ValueKey(_isGuest),
      child: IndexedStack(index: _index, children: pages),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CollapsibleSidebar(
                  selectedIndex: _index,
                  isGuest: _isGuest,
                  onDestinationSelected: _selectTab,
                  onGetService: _openServices,
                  onSignIn: _signIn,
                  onLogout: _logout,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DashboardHeader(
                        userName: userName,
                        userEmail: _isGuest ? null : ownerEmail,
                        isGuest: _isGuest,
                        onSignIn: _signIn,
                        onSelectSection: _selectTab,
                        onGetService: _openServices,
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1360),
                            child: body,
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

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openServices,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.build_circle_outlined),
            label: const Text('Get a service'),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _selectTab,
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

/// Placeholder for protected tabs while browsing as a guest. It is never made
/// visible (the shell blocks navigation to these tabs), but keeps the
/// [IndexedStack] from instantiating authenticated screens for guests.
class _LockedTab extends StatelessWidget {
  const _LockedTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Sign in to access this section.'),
      ),
    );
  }
}
