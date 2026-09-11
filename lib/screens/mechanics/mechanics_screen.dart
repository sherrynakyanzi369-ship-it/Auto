import 'package:flutter/material.dart';

import '../../data/app_images.dart';
import '../../models/mechanic.dart';
import '../../services/location_service.dart';
import '../../services/mechanic_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_entry.dart';
import '../../widgets/app_image.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nearby mechanics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: IconButton(
                      onPressed: _refresh,
                      icon: const Icon(Icons.my_location),
                      tooltip: 'Refresh location',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _search,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search mechanics or services',
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
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            _specialty =
                                _specialty == m.specialty ? null : m.specialty;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_mechanics.isEmpty)
              const Expanded(child: _NoResults())
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                  itemCount: _mechanics.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final m = _mechanics[index];
                    return AnimatedEntry(
                      index: index,
                      child: _MechanicCard(
                        mechanic: m,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MechanicProfileScreen(mechanic: m),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    AppImages.mechanicCover(mechanic.specialty),
                    radius: BorderRadius.zero,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.primary.withValues(alpha: 0.15),
                          AppTheme.ink.withValues(alpha: 0.72),
                        ],
                        stops: const [0.3, 0.65, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              AppTheme.primary,
                              Color(0xFF13578F),
                            ]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            mechanic.specialty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mechanic.businessName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: mechanic.available
                                ? AppTheme.success
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mechanic.available ? 'Available' : 'Busy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: mechanic.available
                                  ? AppTheme.success
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mechanic.name} · ${mechanic.experience}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 17,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mechanic.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              ' (${mechanic.reviewCount})',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${mechanic.distanceKm.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}