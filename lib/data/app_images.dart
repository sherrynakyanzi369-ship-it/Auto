class AppImages {
  AppImages._();

  static const String _base = 'https://images.unsplash.com';

  static String _url(String id, {int w = 800, int q = 75}) =>
      '$_base/$id?auto=format&fit=crop&w=$w&q=$q';

  // ── Hero / Carousel ──────────────────────────────────────────
  static const String _carousel1 = 'photo-1503376780353-7e6692767b70';
  static const String _carousel2 = 'photo-1492144534655-ae79c964c9d7';
  static const String _carousel3 = 'photo-1583121274602-3e2820c69888';
  static const String _carousel4 = 'photo-1494976388531-d1058494cdd8';
  static const String _carousel5 = 'photo-1552519507-da3b142c6e3d';

  static List<String> get carouselImages => [
        _url(_carousel1, w: 1200),
        _url(_carousel2, w: 1200),
        _url(_carousel3, w: 1200),
        _url(_carousel4, w: 1200),
        _url(_carousel5, w: 1200),
      ];

  static const List<String> carouselCaptions = [
    'Premium roadside assistance',
    'Trusted mechanics near you',
    'Get back on the road fast',
    '24/7 emergency support',
    'Quality parts & service',
  ];

  // ── Splash / Login background ────────────────────────────────
  static String get splashBg => _url(_carousel3, w: 1400, q: 80);
  static String get loginBg => _url(_carousel1, w: 1400, q: 80);

  // ── Service card images ──────────────────────────────────────
  static String get serviceVehicles => _url(_carousel4, w: 400);
  static String get serviceMechanics => _url('photo-1487754180451-c456f719a1fc', w: 400);
  static String get serviceParts => _url('photo-1504222490345-c075b6008014', w: 400);
  static String get serviceAi => _url('photo-1621905251189-08b45d6a269e', w: 400);
  static String get serviceChat => _url('photo-1511919884226-fd3cad34687c', w: 400);
  static String get serviceHelp => _url(_carousel5, w: 400);

  // ── Mechanic cover images (by specialty) ─────────────────────
  static String get mechanicEngine => _url('photo-1621905251189-08b45d6a269e', w: 600);
  static String get mechanicTyres => _url('photo-1558618666-fcd25c85cd64', w: 600);
  static String get mechanicGeneral => _url('photo-1487754180451-c456f719a1fc', w: 600);
  static String get mechanicElectrical => _url('photo-1504222490345-c075b6008014', w: 600);
  static String get mechanicDiesel => _url('photo-1625047509248-ec889cbff17f', w: 600);
  static String get mechanicBody => _url('photo-1511919884226-fd3cad34687c', w: 600);
  static String get mechanicBrakes => _url('photo-1621905251189-08b45d6a269e', w: 600);
  static String get mechanicMobile => _url(_carousel4, w: 600);

  static String mechanicCover(String specialty) {
    final key = specialty.toLowerCase();
    if (key.contains('engine') || key.contains('transmission')) return mechanicEngine;
    if (key.contains('tyre') || key.contains('battery')) return mechanicTyres;
    if (key.contains('electrical') || key.contains('auto electrical')) return mechanicElectrical;
    if (key.contains('diesel')) return mechanicDiesel;
    if (key.contains('body') || key.contains('paint')) return mechanicBody;
    if (key.contains('brake') || key.contains('suspension')) return mechanicBrakes;
    if (key.contains('mobile')) return mechanicMobile;
    return mechanicGeneral;
  }

  // ── Spare part category images ───────────────────────────────
  static String get partBatteries => _url('photo-1558618666-fcd25c85cd64', w: 400);
  static String get partBrakes => _url('photo-1621905251189-08b45d6a269e', w: 400);
  static String get partLubricants => _url('photo-1625047509248-ec889cbff17f', w: 400);
  static String get partIgnition => _url('photo-1504222490345-c075b6008014', w: 400);
  static String get partFilters => _url('photo-1511919884226-fd3cad34687c', w: 400);
  static String get partTransmission => _url('photo-1621905251189-08b45d6a269e', w: 400);
  static String get partTyres => _url('photo-1558618666-fcd25c85cd64', w: 400);
  static String get partElectrical => _url('photo-1504222490345-c075b6008014', w: 400);
  static String get partCooling => _url('photo-1625047509248-ec889cbff17f', w: 400);
  static String get partFuel => _url('photo-1621905251189-08b45d6a269e', w: 400);
  static String get partSuspension => _url('photo-1625047509248-ec889cbff17f', w: 400);
  static String get partLighting => _url('photo-1504222490345-c075b6008014', w: 400);
  static String get partDefault => _url('photo-1504222490345-c075b6008014', w: 400);

  static String partCategoryImage(String category) {
    final key = category.toLowerCase();
    if (key.contains('batter')) return partBatteries;
    if (key.contains('brake')) return partBrakes;
    if (key.contains('lubric') || key.contains('oil')) return partLubricants;
    if (key.contains('ignit') || key.contains('spark')) return partIgnition;
    if (key.contains('filter')) return partFilters;
    if (key.contains('trans') || key.contains('clutch')) return partTransmission;
    if (key.contains('tyre') || key.contains('tire')) return partTyres;
    if (key.contains('electr')) return partElectrical;
    if (key.contains('cool') || key.contains('radia')) return partCooling;
    if (key.contains('fuel')) return partFuel;
    if (key.contains('susp') || key.contains('shock')) return partSuspension;
    if (key.contains('light') || key.contains('led')) return partLighting;
    return partDefault;
  }

  // ── Profile header ───────────────────────────────────────────
  static String get profileHeader => _url(_carousel2, w: 1200);

  // ── Empty state illustrations ────────────────────────────────
  static String get emptyVehicles => _url(_carousel4, w: 400);
  static String get emptyChats => _url('photo-1511919884226-fd3cad34687c', w: 400);
}
