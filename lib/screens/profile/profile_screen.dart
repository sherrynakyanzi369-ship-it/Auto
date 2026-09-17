import 'package:flutter/material.dart';

import '../../data/app_images.dart';
import '../../models/assistance_request.dart';
import '../../models/vehicle.dart';
import '../../services/assistance_service.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_entry.dart';
import '../../widgets/app_image.dart';

class ProfileScreen extends StatefulWidget {
  final String ownerEmail;

  /// Invoked after a successful sign out so the shell can return the user to
  /// the guest dashboard instead of tearing down the navigation stack.
  final Future<void> Function()? onSignOut;

  const ProfileScreen({
    super.key,
    required this.ownerEmail,
    this.onSignOut,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Vehicle> _vehicles = [];
  List<AssistanceRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AuthService.instance.isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _vehicles = [];
        _requests = [];
      });
      return;
    }
    final vehicles = await VehicleService.instance.getVehicles(widget.ownerEmail);
    final requests =
        await AssistanceService.instance.getRequests(widget.ownerEmail);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _requests = requests;
    });
  }

  Future<void> _logout() async {
    if (widget.onSignOut != null) {
      await widget.onSignOut!();
      return;
    }
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final initials = (user?.name ?? 'D')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    AppImages.profileHeader,
                    fit: BoxFit.cover,
                    radius: null,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0D3B66),
                          Color(0xF20D3B66),
                        ],
                        stops: [0.25, 0.65, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.emergency],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: AppTheme.primary,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user?.name ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                              if (user?.phone.isNotEmpty ?? false)
                                Text(
                                  user!.phone,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      value: _vehicles.length.toString(),
                      label: 'Vehicles',
                      icon: Icons.directions_car_outlined,
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.grey.shade200),
                  Expanded(
                    child: _Stat(
                      value: _requests.length.toString(),
                      label: 'Requests',
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.grey.shade200),
                  Expanded(
                    child: _Stat(
                      value: _requests
                          .where((r) => r.status == 'Pending')
                          .length
                          .toString(),
                      label: 'Pending',
                      icon: Icons.schedule,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            AnimatedEntry(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _menuTile(
                      icon: Icons.directions_car_outlined,
                      title: 'Registered vehicles',
                      subtitle: '${_vehicles.length} vehicle(s) on this account',
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy',
                      subtitle:
                          'Your location is shared only with service providers you engage.',
                    ),
                    _divider(),
                    _menuTile(
                      icon: Icons.rule_outlined,
                      title: 'AI Assistant disclaimer',
                      subtitle:
                          'AI guidance does not replace professional mechanical diagnosis.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out'),
                    content:
                        const Text('Are you sure you want to sign out of AutoAssist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _logout();
                        },
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 58, color: Colors.grey.shade100);

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: AppTheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}