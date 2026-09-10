import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data.dart';
import '../../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  String _type = 'Saloon';
  String _fuelType = 'Petrol';
  bool _saving = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await VehicleService.instance.addVehicle(
      AuthService.instance.email,
      Vehicle(
        id: 'veh-${DateTime.now().millisecondsSinceEpoch}',
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        plate: _plateController.text.trim().toUpperCase(),
        color: _colorController.text.trim(),
        type: _type,
        fuelType: _fuelType,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register vehicle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Make (e.g. Toyota)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Model (e.g. Corolla)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Year (e.g. 2016)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _plateController,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Plate No. (e.g. UBB 123A)'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _colorController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Colour (e.g. White)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Vehicle type'),
                  items: MockData.vehicleTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? 'Saloon'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _fuelType,
                  decoration: const InputDecoration(labelText: 'Fuel type'),
                  items: MockData.fuelTypes
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _fuelType = v ?? 'Petrol'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}