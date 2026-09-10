import 'package:flutter/material.dart';

import '../../models/assistance_request.dart';
import '../../models/vehicle.dart';
import '../../services/assistance_service.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import 'ai/ai_assistant_screen.dart';
import 'assistance/emergency_request_screen.dart';
import 'chat/chat_list_screen.dart';
import 'mechanics/mechanics_screen.dart';
import 'parts/spare_parts_screen.dart';
import 'vehicles/vehicles_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Vehicle> _vehicles = [];
  List<AssistanceRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = AuthService.instance.email;
    final vehicles = await VehicleService.instance.getVehicles(email);
    final requests = await AssistanceService.instance.getRequests(email);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _requests = requests;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final firstName = (user?.name ?? 'Driver').split(' ').first;
    final pendingCount = _requests.where((r) => r.status == 'Pending').length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'How can we assist your vehicle today?',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _EmergencyBanner(
                onPressed: () => _open(const EmergencyRequestScreen()),
              ),
              const SizedBox(height: 24),
              const Text(
                'Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickAction(
                    icon: Icons.directions_car_filled_outlined,
                    color: AppTheme.primary,
                    label: 'My Vehicles',
                    count: _vehicles.length.toString(),
                    onTap: () => _open(const VehiclesScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.location_on_outlined,
                    color: const Color(0xFF00838F),
                    label: 'Nearby Mechanics',
                    onTap: () => _open(const MechanicsScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.extension_outlined,
                    color: const Color(0xFF6A1B9A),
                    label: 'Spare Parts',
                    onTap: () => _open(const SparePartsScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.smart_toy_outlined,
                    color: const Color(0xFFE65100),
                    label: 'AI Assistant',
                    onTap: () => _open(const AiAssistantScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.chat_outlined,
                    color: const Color(0xFF1565C0),
                    label: 'Messages',
                    count: pendingCount.toString(),
                    onTap: () => _open(ChatListScreen(ownerEmail: AuthService.instance.email)),
                  ),
                  _QuickAction(
                    icon: Icons.sos_outlined,
                    color: AppTheme.emergency,
                    label: 'Request Help',
                    onTap: () => _open(const EmergencyRequestScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => _open(const VehiclesScreen()),
                    child: const Text('View details'),
                  ),
                ],
              ),
              if (_requests.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No assistance requests yet. If your vehicle breaks down, use Request Help.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._requests.take(3).map((r) => _RequestRow(request: r)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmergencyBanner({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.emergency, Color(0xFFB71C2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.sos, size: 44, color: Colors.white),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency assistance',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Broken down? Request help and share your location with nearby mechanics.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: onPressed,
            style: IconButton.styleFrom(backgroundColor: Colors.white),
            icon: const Icon(Icons.arrow_forward, color: AppTheme.emergency),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? count;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 26),
                  if (count != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count!,
                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final AssistanceRequest request;

  const _RequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = request.status == 'Pending'
        ? AppTheme.accent
        : request.status == 'Completed'
            ? AppTheme.success
            : AppTheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: statusColor.withValues(alpha: 0.14),
          child: Icon(Icons.build_circle_outlined, color: statusColor),
        ),
        title: Text(request.issueType, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${request.vehicleName} · ${formatDateTime(request.createdAt)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            request.status,
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}