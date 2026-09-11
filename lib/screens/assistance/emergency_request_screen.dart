import 'package:flutter/material.dart';

import '../../models/assistance_request.dart';
import '../../models/mechanic.dart';
import '../../models/vehicle.dart';
import '../../services/assistance_service.dart';
import '../../services/auth_service.dart';
import '../../services/location_service.dart';
import '../../services/mechanic_service.dart';
import '../../services/mock_data.dart';
import '../../services/vehicle_service.dart';
import '../../theme/app_theme.dart';
import '../vehicles/add_vehicle_screen.dart';
import 'request_created_screen.dart';

class EmergencyRequestScreen extends StatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  State<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends State<EmergencyRequestScreen> {
  List<Vehicle> _vehicles = [];
  String? _vehicleId;
  String _issueType = MockData.issueTypes.first;
  final TextEditingController _description = TextEditingController();
  LocationResult _location = const LocationResult(
    coords: AppLatLng(0.3476, 32.5825),
    label: 'Kampala, Uganda (demo location)',
  );
  bool _locating = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final vehicles = await VehicleService.instance.getVehicles(AuthService.instance.email);
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      if (vehicles.isNotEmpty) _vehicleId ??= vehicles.first.id;
    });
  }

  Future<void> _refreshLocation() async {
    setState(() => _locating = true);
    final result = await LocationService.instance.locate();
    if (!mounted) return;
    setState(() {
      _location = result;
      _locating = false;
    });
  }

  Future<void> _addVehicle() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );
    _loadVehicles();
  }

  Future<void> _submit() async {
    if (_vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please register a vehicle first.')),
      );
      return;
    }
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the problem.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final vehicle = _vehicles.firstWhere((v) => v.id == _vehicleId);
    final nearby = MechanicService.instance.nearDriver(_location.coords);
    final Mechanic? assigned = nearby.isNotEmpty ? nearby.first : null;

    final request = AssistanceRequest(
      id: 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      vehicleName: vehicle.displayName,
      issueType: _issueType,
      description: _description.text.trim(),
      locationLabel: _location.label,
      latitude: _location.coords.latitude,
      longitude: _location.coords.longitude,
      status: 'Pending',
      mechanicName: assigned?.businessName ?? 'Awaiting response',
      createdAt: DateTime.now(),
    );

    await AssistanceService.instance.createRequest(AuthService.instance.email, request);
    if (!mounted) return;
    setState(() => _submitting = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RequestCreatedScreen(
          request: request,
          nearbyMechanics: nearby.take(4).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request assistance'),
        backgroundColor: Colors.red.withValues(alpha: 0.05),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(description:
              'Your request and live location will be shared with nearby mechanics. You can then chat to agree on a service.'),
          const SizedBox(height: 16),
          if (_vehicles.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('You need a registered vehicle to request assistance.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: _addVehicle,
                      icon: const Icon(Icons.add),
                      label: const Text('Register vehicle'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _vehicleId,
              decoration: const InputDecoration(labelText: 'Vehicle'),
              items: _vehicles
                  .map((v) => DropdownMenuItem(
                        value: v.id,
                        child: Text('${v.displayName} · ${v.plate}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _vehicleId = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _issueType,
              decoration: const InputDecoration(labelText: 'What is the problem?'),
              items: MockData.issueTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _issueType = v ?? MockData.issueTypes.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe the problem',
                hintText: 'e.g. The engine stopped suddenly with a burning smell...',
                alignLabelWithHint: true,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your location',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${_location.coords.latitude.toStringAsFixed(4)}, '
                          '${_location.coords.longitude.toStringAsFixed(4)} · ${_location.label}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _locating ? null : _refreshLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting || _vehicles.isEmpty ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.emergency),
            icon: const Icon(Icons.sos),
            label: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Submit Emergency Request'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String description;

  const _InfoCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(description,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}