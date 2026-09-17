import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_images.dart';
import '../models/assistance_request.dart';
import '../models/mechanic.dart';
import '../models/vehicle.dart';
import '../services/assistance_service.dart';
import '../services/auth_service.dart';
import '../services/mock_data.dart';
import '../services/session_gate.dart';
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
  static const double _desktopBreakpoint = 900;

  List<Vehicle> _vehicles = [];
  List<AssistanceRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _isGuest => AuthService.instance.isGuest;

  Future<void> _load() async {
    if (_isGuest) {
      if (!mounted) return;
      setState(() {
        _vehicles = [];
        _requests = [];
      });
      return;
    }
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
    if (_isGuest) {
      final ok = await requireAccount(
        context,
        reason: 'Sign in to access this service.',
      );
      if (!ok || !mounted) return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load();
  }

  Future<void> _signInPrompt() async {
    final ok = await requireAccount(
      context,
      reason: 'Sign in to unlock your garage and service history.',
    );
    if (!ok || !mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop =
            constraints.maxWidth >= _desktopBreakpoint || constraints.maxHeight >= 800;
        return isDesktop ? _buildDesktop() : _buildMobile();
      },
    );
  }

  // ────────────────────────────────────────────────────────────
  // Desktop
  // ────────────────────────────────────────────────────────────

  Widget _buildDesktop() {
    final user = AuthService.instance.currentUser;
    final firstName =
        _isGuest ? 'Guest' : (user?.name ?? 'Driver').split(' ').first;

    return Container(
      color: const Color(0xFFF6F8FB),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 36),
        children: [
          _buildGreeting(firstName),
          const SizedBox(height: 22),
          HeroCarousel(
            images: AppImages.carouselImages,
            captions: AppImages.carouselCaptions,
            height: 300,
            headline: 'Reliable Mechanics,\nInstant Help',
            subheadline:
                'Roadside rescue, repairs and quality parts — matched to you in minutes.',
            onBookService: () => _open(const EmergencyRequestScreen()),
            onFindMechanic: () => _open(const MechanicsScreen()),
          ),
          const SizedBox(height: 30),
          const SectionHeader(
            title: 'Workspace',
            subtitle: 'Everything you need, one tap away',
            actionLabel: 'Explore all',
          ),
          const SizedBox(height: 16),
          _buildBento(),
        ],
      ),
    );
  }

  Widget _buildGreeting(String firstName) {
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isGuest ? 'Welcome to AutoAssist' : 'Good day, ${_title(firstName)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isGuest
                    ? 'Sign in to unlock your garage, mechanics and parts.'
                    : 'Here is what is happening with your garage today.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        _StatChip(
          icon: Icons.directions_car_outlined,
          label: '${_vehicles.length} vehicles',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.pending_actions_outlined,
          label: '$_pendingCount pending',
          accent: true,
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            today,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  String _title(String name) {
    if (name.isEmpty) return 'there';
    return name[0].toUpperCase() + name.substring(1);
  }

  Widget _buildBento() {
    // Three cards in each row on desktop.
    const double gap = 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BentoRow(
          minHeight: 200,
          children: [
            Flexible(
              child: _EmergencySosCard(
                onTap: () => _open(const EmergencyRequestScreen()),
              ),
            ),
            Flexible(
              child: _NearbyMechanicsCard(
                onTap: () => _open(const MechanicsScreen()),
              ),
            ),
            Flexible(
              child: _VehiclesCard(
                count: _vehicles.length,
                onTap: () => _open(const VehiclesScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: gap),
        _BentoRow(
          minHeight: 200,
          children: [
            Flexible(
              child: _PartsCard(onTap: () => _open(const SparePartsScreen())),
            ),
            Flexible(
              child: _ChatsCard(
                badge: _pendingCount,
                onTap: () => _open(
                  ChatListScreen(ownerEmail: AuthService.instance.email),
                ),
              ),
            ),
            Flexible(
              child: _AiCard(onTap: () => _open(const AiAssistantScreen())),
            ),
          ],
        ),
        const SizedBox(height: gap),
        if (_isGuest)
          _GuestSignInCard(onTap: _signInPrompt)
        else
          _ServiceHistory(requests: _requests),
      ],
    );
  }

  int get _pendingCount => _requests.where((r) => r.status == 'Pending').length;

  String get _vehiclesCount {
    final n = _vehicles.length;
    return n == 0 ? 'Add your first' : n.toString();
  }

  List<Widget> _mobileServiceCards() {
    return [
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
        trailing: _pendingCount.toString(),
        onTap: () =>
            _open(ChatListScreen(ownerEmail: AuthService.instance.email)),
      ),
      ImageServiceCard(
        image: AppImages.serviceHelp,
        title: 'Request Help',
        subtitle: 'Send an SOS alert',
        tagColor: AppTheme.emergency,
        onTap: () => _open(const EmergencyRequestScreen()),
      ),
    ];
  }

  // ────────────────────────────────────────────────────────────
  // Mobile (existing behaviour)
  // ────────────────────────────────────────────────────────────

  Widget _buildMobile() {
    final user = AuthService.instance.currentUser;
    final firstName =
        _isGuest ? 'Guest' : (user?.name ?? 'Driver').split(' ').first;

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
                            _isGuest ? 'Welcome,' : 'Good day,',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                    if (_isGuest)
                      AnimatedPress(
                        onTap: _signInPrompt,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.login_rounded,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: AppTheme.success),
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
                _MobileSosBanner(onTap: () => _open(const EmergencyRequestScreen())),
                const SizedBox(height: 26),
                const SectionHeader(
                  title: 'Services',
                  subtitle: 'Everything you need, one tap away',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      for (final card in _mobileServiceCards())
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(width: 172, child: card),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const SectionHeader(
                  title: 'Recent requests',
                  subtitle: 'Your latest assistance activity',
                ),
                const SizedBox(height: 12),
                if (_isGuest)
                  _GuestSignInCard(onTap: _signInPrompt)
                else if (_requests.isEmpty)
                  const _EmptyRequests()
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
}

// ────────────────────────────────────────────────────────────
// Bento primitives
// ────────────────────────────────────────────────────────────

class _BentoRow extends StatelessWidget {
  final List<Flexible> children;
  final double minHeight;

  const _BentoRow({required this.children, this.minHeight = 0});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _BentoCard({
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      child: AnimatedPress(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Puts a small colored icon chip on the left and an optional arrow on the right.
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CardHeader({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const Spacer(),
        Icon(Icons.arrow_outward, size: 15, color: color),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _CardTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: Color(0xFF0F172A),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Bento cards
// ────────────────────────────────────────────────────────────

class _EmergencySosCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmergencySosCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      child: AnimatedPress(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF97316), Color(0xFFE63946)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE63946).withValues(alpha: 0.3),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sos,
                      color: Color(0xFFE63946),
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
              const Expanded(child: SizedBox.shrink()),
              const Text(
                'Emergency SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'One tap to reach a nearby mechanic instantly.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_in_talk, size: 15, color: Color(0xFFE63946)),
                    SizedBox(width: 7),
                    Text(
                      'Request Help Now',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE63946),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyMechanicsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NearbyMechanicsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final top = MockData.mechanics.take(3).toList();
    final avgRating = MockData.mechanics.fold<double>(0, (s, m) => s + m.rating) /
        MockData.mechanics.length;

    return _BentoCard(onTap: onTap, child: _buildBody(top, avgRating));
  }

  Widget _buildBody(List<Mechanic> top, double avgRating) {
    const palette = [
      Color(0xFF0D3B66),
      Color(0xFF00838F),
      Color(0xFF7B2CBF),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeader(icon: Icons.car_repair_outlined, color: Color(0xFF00838F)),
        const Expanded(child: SizedBox.shrink()),
        const _CardTitle(
          title: 'Nearby Mechanics',
          subtitle: 'Trusted pros verified & rated nearby',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: (3 * 26) - 8,
              height: 26,
              child: Stack(
                children: [
                  for (int i = 0; i < top.length; i++)
                    Positioned(
                      left: i * 22,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette[i % palette.length],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          _initials(top[i].name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${avgRating.toStringAsFixed(1)} · ${top.length} nearby',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _VehiclesCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _VehiclesCard({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.directions_car_outlined, color: AppTheme.primary),
          const Expanded(child: SizedBox.shrink()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  count == 1 ? 'vehicle' : 'vehicles',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _CardTitle(
            title: 'My Vehicles',
            subtitle: 'Keep service records & reminders',
          ),
        ],
      ),
    );
  }
}

class _PartsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PartsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.extension_outlined, color: Color(0xFF7B2CBF)),
          const Expanded(child: SizedBox.shrink()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7B2CBF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '1,200+ parts',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B21A8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _CardTitle(
            title: 'Parts Store',
            subtitle: 'Tyres, brakes, batteries & more',
          ),
        ],
      ),
    );
  }
}

class _ChatsCard extends StatelessWidget {
  final int badge;
  final VoidCallback onTap;

  const _ChatsCard({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(icon: Icons.chat_bubble_outline, color: const Color(0xFF1565C0)),
          const Expanded(child: SizedBox.shrink()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'unread',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _CardTitle(
            title: 'My Chats',
            subtitle: 'Messages from your mechanics',
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AiCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BentoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.auto_awesome_outlined,
            color: Color(0xFFD04A00),
          ),
          const Expanded(child: SizedBox.shrink()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD04A00).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '24/7 guidance',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB45309),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _CardTitle(
            title: 'AI Assistant',
            subtitle: 'Diagnose issues & get fix-it steps',
          ),
        ],
      ),
    );
  }
}

class _GuestSignInCard extends StatelessWidget {
  final VoidCallback onTap;

  const _GuestSignInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFDF3E3), Color(0xFFFFF8EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your garage, mechanics and service history live here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceHistory extends StatelessWidget {
  final List<AssistanceRequest> requests;

  const _ServiceHistory({required this.requests});

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF475569).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    size: 19,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your latest assistance activity',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 10),
            if (requests.isEmpty)
              const _EmptyRequests()
            else
              ...requests.take(3).map(
                    (r) => AnimatedEntry(
                      index: requests.indexOf(r),
                      child: _RequestRow(request: r),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  const _EmptyRequests();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 44, color: Colors.grey.shade400),
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
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MobileSosBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _MobileSosBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: AppTheme.brandGradient),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedPress(
        onTap: onTap,
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
              child: const Icon(Icons.sos, color: AppTheme.emergency, size: 22),
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
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;

  const _StatChip({required this.icon, required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final color = accent ? const Color(0xFFF59E0B) : AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
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