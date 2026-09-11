import 'package:flutter/material.dart';

import '../../models/assistance_request.dart';
import '../../models/mechanic.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/animated_entry.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3828), AppTheme.background],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              AnimatedEntry(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.success, Color(0xFF27AE60)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.success.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check_circle,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Help is on the way!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your request ${request.id} was submitted successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _infoRow(Icons.confirmation_number_outlined,
                        'Request ID', request.id),
                    _infoRow(Icons.build_outlined, 'Issue',
                        request.issueType),
                    _infoRow(Icons.directions_car_outlined, 'Vehicle',
                        request.vehicleName),
                    _infoRow(
                        Icons.location_on_outlined,
                        'Location',
                        '${request.latitude.toStringAsFixed(4)}, ${request.longitude.toStringAsFixed(4)}'),
                    _infoRow(Icons.access_time, 'Submitted',
                        formatDateTime(request.createdAt)),
                    _infoRow(
                        Icons.radar, 'Status', request.status),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (nearbyMechanics.isNotEmpty) ...[
                const Text(
                  'Suggested nearby mechanics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...nearbyMechanics.map(
                  (m) => AnimatedEntry(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: AppTheme.brandGradient),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.car_repair,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.businessName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                                Text(
                                  '${m.specialty} · ${m.distanceKm.toStringAsFixed(1)} km',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  mechanicId: m.id,
                                  ownerEmail: AuthService.instance.email,
                                ),
                              ),
                            ),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.chat_outlined,
                                  color: AppTheme.primary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}