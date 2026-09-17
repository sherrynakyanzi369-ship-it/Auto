import 'package:flutter/material.dart';

import '../screens/ai/ai_assistant_screen.dart';
import '../screens/assistance/emergency_request_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/mechanics/mechanics_screen.dart';
import '../screens/parts/spare_parts_screen.dart';
import '../screens/vehicles/vehicles_screen.dart';
import '../services/auth_service.dart';
import '../services/session_gate.dart';
import '../theme/app_theme.dart';

/// A single bookable service shown in the "Get a service" sheet.
class ServiceOption {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Widget Function() builder;

  const ServiceOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.builder,
  });
}

List<ServiceOption> serviceOptions() => [
      ServiceOption(
        icon: Icons.sos,
        label: 'Emergency roadside help',
        description: 'Send an SOS and reach a nearby mechanic now',
        color: AppTheme.emergency,
        builder: () => const EmergencyRequestScreen(),
      ),
      ServiceOption(
        icon: Icons.car_repair,
        label: 'Find a mechanic',
        description: 'Verified professionals rated near you',
        color: const Color(0xFF00838F),
        builder: () => const MechanicsScreen(),
      ),
      ServiceOption(
        icon: Icons.extension,
        label: 'Buy spare parts',
        description: 'Tyres, batteries, brakes and more',
        color: const Color(0xFF7B2CBF),
        builder: () => const SparePartsScreen(),
      ),
      ServiceOption(
        icon: Icons.smart_toy_outlined,
        label: 'AI assistant',
        description: 'Instant fix-it guidance, 24/7',
        color: const Color(0xFFD04A00),
        builder: () => const AiAssistantScreen(),
      ),
      ServiceOption(
        icon: Icons.directions_car_outlined,
        label: 'My vehicles',
        description: 'Register a vehicle and track service',
        color: AppTheme.primary,
        builder: () => const VehiclesScreen(),
      ),
      ServiceOption(
        icon: Icons.chat_bubble_outline,
        label: 'Messages',
        description: 'Chat with your mechanic',
        color: const Color(0xFF1565C0),
        builder: () => ChatListScreen(ownerEmail: AuthService.instance.email),
      ),
    ];

/// Shows the services sheet and returns the selected option (if any).
Future<ServiceOption?> showServicesSheet(
  BuildContext context, {
  bool isGuest = false,
}) {
  return showModalBottomSheet<ServiceOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final options = serviceOptions();
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFF6F8FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Get a service',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGuest
                  ? 'Sign in to book — it only takes a moment'
                  : 'Choose a service to get started',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                itemCount: options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _ServiceTile(
                    option: option,
                    locked: isGuest,
                    onTap: () => Navigator.of(sheetContext).pop(option),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Opens a service, prompting guests to create an account first.
Future<void> openService(BuildContext context, ServiceOption option) async {
  if (AuthService.instance.isGuest) {
    final ok = await requireAccount(
      context,
      reason: 'Sign in to access ${option.label.toLowerCase()}.',
    );
    if (!ok || !context.mounted) return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => option.builder()),
  );
}

class _ServiceTile extends StatelessWidget {
  final ServiceOption option;
  final bool locked;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.option,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option.icon, color: option.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked ? Icons.lock_outline : Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
