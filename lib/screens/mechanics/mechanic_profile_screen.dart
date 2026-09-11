import 'package:flutter/material.dart';

import '../../data/app_images.dart';
import '../../models/mechanic.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_entry.dart';
import '../../widgets/app_image.dart';
import '../assistance/emergency_request_screen.dart';
import '../chat/chat_screen.dart';

class MechanicProfileScreen extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicProfileScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final m = mechanic;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  AppImages.profileHeader,
                  fit: BoxFit.cover,
                  radius: null,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.primary.withValues(alpha: 0.3),
                        AppTheme.ink.withValues(alpha: 0.9),
                      ],
                      stops: const [0.2, 0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.accent, AppTheme.emergency],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            m.businessName
                                .split(' ')
                                .where((w) => w.isNotEmpty)
                                .take(2)
                                .map((w) => w[0].toUpperCase())
                                .join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
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
                              m.businessName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.name} · ${m.experience} experience',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (m.available
                                            ? AppTheme.success
                                            : Colors.orange)
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    m.available ? 'Available' : 'Busy',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: AppTheme.accent),
                                      Text(
                                        ' ${m.rating}  (${m.reviewCount})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 40,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Services offered',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          ...m.services.map(
            (s) => AnimatedEntry(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle_outline,
                          size: 19, color: AppTheme.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                _contactTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  subtitle: m.address,
                ),
                Divider(height: 1, indent: 60, color: Colors.grey.shade100),
                _contactTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  subtitle: m.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                      mechanicId: m.id,
                      ownerEmail: AuthService.instance.email),
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Send a message'),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const EmergencyRequestScreen()),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
              ),
              icon: const Icon(Icons.sos_outlined),
              label: const Text('Request assistance'),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primary),
      ),
      title: Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }
}