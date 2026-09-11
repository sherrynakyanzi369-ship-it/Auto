import 'package:flutter/material.dart';

import '../../models/mechanic.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../assistance/emergency_request_screen.dart';
import '../chat/chat_screen.dart';

class MechanicProfileScreen extends StatelessWidget {
  final Mechanic mechanic;

  const MechanicProfileScreen({super.key, required this.mechanic});

  @override
  Widget build(BuildContext context) {
    final m = mechanic;
    final initials = m.businessName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    m.businessName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${m.name} · ${m.experience} experience',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: (m.available ? AppTheme.success : Colors.orange)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      m.available ? 'Available now' : 'Currently busy',
                      style: TextStyle(
                        color: m.available ? AppTheme.success : Colors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppTheme.accent, size: 20),
                      Text(' ${m.rating}  (${m.reviewCount} reviews)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Services',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...m.services.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 18, color: AppTheme.success),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                  title: const Text('Location', style: TextStyle(fontSize: 13)),
                  subtitle: Text(m.address, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: AppTheme.primary),
                  title: const Text('Phone', style: TextStyle(fontSize: 13)),
                  subtitle: Text(m.phone, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(mechanicId: m.id, ownerEmail: AuthService.instance.email),
              ),
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Send a message'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyRequestScreen()),
            ),
            icon: const Icon(Icons.sos_outlined),
            label: const Text('Request assistance'),
          ),
        ],
      ),
    );
  }
}