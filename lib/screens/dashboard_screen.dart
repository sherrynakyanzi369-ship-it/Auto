import 'package:flutter/material.dart';

import '../data/app_images.dart';
import '../models/assistance_request.dart';
import '../models/vehicle.dart';
import '../services/assistance_service.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/animated_entry.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/section_header.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF8F0), AppTheme.background],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.emergency],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good day,',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            firstName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppTheme.success),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                HeroCarousel(
                  images: AppImages.carouselImages,
                  captions: AppImages.carouselCaptions,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: AppTheme.brandGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: AnimatedPress(
                          onTap: () => _open(const EmergencyRequestScreen()),
                          child: Row(
                            children: [
                              const SizedBox(width: 6),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sos,
                                  color: AppTheme.emergency,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Need help now?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Request emergency assistance',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionHeader(
                  title: 'Services',
                  subtitle: 'Everything you need, one tap away',
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                  children: [
                    ImageServiceCard(
                      image: AppImages.serviceVehicles,
                      title: 'My Vehicles',
                      subtitle: '$_vehiclesCount registered',
                      tagColor: AppTheme.primary,
                      trailing: _vehicles.length.toString(),
                      onTap: () => _open(const VehiclesScreen()),
                    ),
                    ImageServiceCard(
                      image: AppImages.serviceMechanics,
                      title: 'Mechanics',
                      subtitle: 'Trusted nearby pros',
                      tagColor: const Color(0xFF00838F),
                      onTap: () => _open(const MechanicsScreen()),
                    ),
                    ImageServiceCard(
                      image: AppImages.serviceParts,
                      title: 'Spare Parts',
                      subtitle: 'Quality auto parts',
                      tagColor: const Color(0xFF7B2CBF),
                      onTap: () => _open(const SparePartsScreen()),
                    ),
                    ImageServiceCard(
                      image: AppImages.serviceAi,
                      title: 'AI Assistant',
                      subtitle: 'Fix-it guidance 24/7',
                      tagColor: const Color(0xFFD04A00),
                      onTap: () => _open(const AiAssistantScreen()),
                    ),
                    ImageServiceCard(
                      image: AppImages.serviceChat,
                      title: 'Messages',
                      subtitle: 'Chat with mechanics',
                      tagColor: const Color(0xFF1565C0),
                      trailing: pendingCount.toString(),
                      onTap: () => _open(ChatListScreen(ownerEmail: AuthService.instance.email)),
                    ),
                    ImageServiceCard(
                      image: AppImages.serviceHelp,
                      title: 'Request Help',
                      subtitle: 'Send an SOS alert',
                      tagColor: AppTheme.emergency,
                      onTap: () => _open(const EmergencyRequestScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const SectionHeader(
                  title: 'Recent requests',
                  subtitle: 'Your latest assistance activity',
                ),
                const SizedBox(height: 12),
                if (_requests.isEmpty)
                  AnimatedEntry(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 44, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'No assistance requests yet',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If your vehicle breaks down, use Request Help above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._requests.take(3).map(
                        (r) => AnimatedEntry(
                          index: _requests.indexOf(r),
                          child: _RequestRow(request: r),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _vehiclesCount {
    final n = _vehicles.length;
    return n == 0 ? 'Add your first' : n.toString();
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.build_circle_outlined, color: statusColor),
        ),
        title: Text(
          request.issueType,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          '${request.vehicleName} · ${formatDateTime(request.createdAt)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            request.status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}