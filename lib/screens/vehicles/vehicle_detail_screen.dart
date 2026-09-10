import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove vehicle'),
        content: Text(
            'Remove ${widget.vehicle.displayName} (${widget.vehicle.plate}) from your registered vehicles?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.emergency),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await VehicleService.instance.removeVehicle(AuthService.instance.email, widget.vehicle.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final rows = <(IconData, String, String)>[
      (Icons.badge_outlined, 'Plate number', v.plate),
      (Icons.calendar_today_outlined, 'Year', v.year),
      (Icons.palette_outlined, 'Colour', v.color),
      (Icons.category_outlined, 'Vehicle type', v.type),
      (Icons.local_gas_station_outlined, 'Fuel type', v.fuelType),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle detail'),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline, color: AppTheme.emergency),
            tooltip: 'Remove vehicle',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car_filled, size: 48, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    v.displayName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: rows
                  .map((r) => ListTile(
                        leading: Icon(r.$1, color: AppTheme.primary),
                        title: Text(r.$2, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        subtitle: Text(r.$3, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}