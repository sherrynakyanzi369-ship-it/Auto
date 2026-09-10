import 'package:flutter/material.dart';

import '../../models/mechanic.dart';
import '../../services/location_service.dart';
import '../../services/mechanic_service.dart';
import '../../theme/app_theme.dart';
import 'mechanic_profile_screen.dart';

class MechanicsScreen extends StatefulWidget {
  const MechanicsScreen({super.key});

  @override
  State<MechanicsScreen> createState() => _MechanicsScreenState();
}

class _MechanicsScreenState extends State<MechanicsScreen> {
  final TextEditingController _search = TextEditingController();
  String? _specialty;
  AppLatLng _origin = LocationService.defaultKampala;
  List<Mechanic> _mechanics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final result = await LocationService.instance.locate();
    if (!mounted) return;
    setState(() {
      _origin = result.coords;
      _applyFilters();
      _loading = false;
    });
  }

  void _applyFilters() {
    _mechanics = MechanicService.instance.nearDriver(
      _origin,
      query: _search.text,
      specialty: _specialty,
    );
  }

  void _onSearchChanged(String _) => setState(_applyFilters);

  @override
  Widget build(BuildContext context) {
    final specialties = MechanicService.instance.specialties(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby mechanics'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.my_location),
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, specialty or service',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _onSearchChanged('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _specialty == null,
                    onSelected: (_) {
                      setState(() => _specialty = null);
                      _applyFilters();
                    },
                  ),
                ),
                ...specialties.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(m.specialty),
                      selected: _specialty == m.specialty,
                      onSelected: (_) {
                        setState(() {
                          _specialty = _specialty == m.specialty ? null : m.specialty;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_mechanics.isEmpty)
            Expanded(child: _NoResults())
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _mechanics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final m = _mechanics[index];
                  return _MechanicCard(
                    mechanic: m,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MechanicProfileScreen(mechanic: m),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No mechanics match your search.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _MechanicCard extends StatelessWidget {
  final Mechanic mechanic;
  final VoidCallback onTap;

  const _MechanicCard({required this.mechanic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = mechanic.businessName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanic.businessName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${mechanic.specialty} · ${mechanic.experience}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: AppTheme.accent),
                        Text(' ${mechanic.rating} (${mechanic.reviewCount})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey.shade500),
                        Text(' ${mechanic.distanceKm.toStringAsFixed(1)} km',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (mechanic.available ? AppTheme.success : Colors.orange)
                          .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mechanic.available ? 'Available' : 'Busy',
                      style: TextStyle(
                        color: mechanic.available ? AppTheme.success : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}