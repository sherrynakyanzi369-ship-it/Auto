import 'package:flutter/material.dart';

import '../../models/assistance_request.dart';
import '../../models/vehicle.dart';
import '../../services/assistance_service.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String ownerEmail;

  const ProfileScreen({super.key, required this.ownerEmail});

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
    final vehicles = await VehicleService.instance.getVehicles(widget.ownerEmail);
    final requests = await AssistanceService.instance.getRequests(widget.ownerEmail);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _requests = requests;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
      appBar: AppBar(title: const Text('My profile')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    if (user?.phone.isNotEmpty ?? false) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.phone,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            value: _vehicles.length.toString(),
                            label: 'Vehicles',
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        Expanded(
                          child: _Stat(
                            value: _requests.length.toString(),
                            label: 'Requests',
                          ),
                        ),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        Expanded(
                          child: _Stat(
                            value: _requests.where((r) => r.status == 'Pending').length.toString(),
                            label: 'Pending',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: const Text('Registered vehicles'),
                    subtitle: Text('${_vehicles.length} vehicle(s) on this account'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Privacy'),
                    subtitle: const Text('Your location is shared only with service providers you engage.'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.rule_outlined),
                    title: const Text('AI Assistant disclaimer'),
                    subtitle: const Text('AI guidance does not replace professional mechanical diagnosis.'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Are you sure you want to sign out of AutoAssist?'),
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
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}