import 'package:flutter/material.dart';

import '../../models/assistance_request.dart';
import '../../models/mechanic.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../chat/chat_screen.dart';

class RequestCreatedScreen extends StatelessWidget {
  final AssistanceRequest request;
  final List<Mechanic> nearbyMechanics;

  const RequestCreatedScreen({
    super.key,
    required this.request,
    required this.nearbyMechanics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request submitted'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success, size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Help is on the way!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your assistance request ${request.id} was submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.confirmation_number_outlined, color: AppTheme.primary),
                  title: const Text('Request ID', style: TextStyle(fontSize: 13)),
                  subtitle: Text(request.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: const Icon(Icons.build_outlined, color: AppTheme.primary),
                  title: const Text('Issue', style: TextStyle(fontSize: 13)),
                  subtitle: Text(request.issueType, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car_outlined, color: AppTheme.primary),
                  title: const Text('Vehicle', style: TextStyle(fontSize: 13)),
                  subtitle: Text(request.vehicleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                  title: const Text('Location', style: TextStyle(fontSize: 13)),
                  subtitle: Text(
                    '${request.latitude.toStringAsFixed(4)}, ${request.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: AppTheme.primary),
                  title: const Text('Submitted', style: TextStyle(fontSize: 13)),
                  subtitle: Text(formatDateTime(request.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                ListTile(
                  leading: const Icon(Icons.radar, color: AppTheme.primary),
                  title: const Text('Status', style: TextStyle(fontSize: 13)),
                  subtitle: Text(request.status, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Suggested nearby mechanics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...nearbyMechanics.map(
            (m) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.car_repair, color: AppTheme.primary),
                ),
                title: Text(m.businessName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${m.specialty} · ${m.distanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        mechanicId: m.id,
                        ownerEmail: AuthService.instance.email,
                      ),
                    ),
                  ),
                  child: const Text('Message'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}