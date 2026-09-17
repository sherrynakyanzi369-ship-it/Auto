import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animated_entry.dart';

class CollapsibleSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int unreadChats;
  final bool isGuest;
  final VoidCallback? onGetService;
  final VoidCallback? onSignIn;
  final VoidCallback? onLogout;

  const CollapsibleSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.unreadChats = 0,
    this.isGuest = false,
    this.onGetService,
    this.onSignIn,
    this.onLogout,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _extended = true;

  static const double _expandedWidth = 252;
  static const double _collapsedWidth = 84;

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.car_repair_outlined, Icons.car_repair, 'Mechanics'),
    (Icons.extension_outlined, Icons.extension, 'Parts'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, 'Chats'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _toggle() => setState(() => _extended = !_extended);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      width: _extended ? _expandedWidth : _collapsedWidth,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _extended
                    ? const Row(
                        key: ValueKey('extended'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BrandAvatar(),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AA AutoAssist',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Roadside service',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const _BrandAvatar(
                        key: ValueKey('collapsed'),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                      ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 14),
          if (_extended)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: FilledButton.icon(
                onPressed: widget.onGetService,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.build_circle_outlined, size: 20),
                label: const Text(
                  'Get a service',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                itemCount: _destinations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final (icon, selectedIcon, label) = _destinations[index];
                  final isSelected = index == widget.selectedIndex;
                  final showBadge =
                      index == 3 && widget.unreadChats > 0 && _extended;
                  return _SideNavTile(
                    icon: icon,
                    selectedIcon: selectedIcon,
                    label: label,
                    selected: isSelected,
                    extended: _extended,
                    badge: showBadge ? widget.unreadChats : 0,
                    onTap: () => widget.onDestinationSelected(index),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.isGuest)
                  _IconAction(
                    tooltip: 'Sign in',
                    icon: Icons.login_rounded,
                    color: AppTheme.primary,
                    onTap: widget.onSignIn ?? () {},
                  )
                else
                  _IconAction(
                    tooltip: 'Sign out',
                    icon: Icons.logout_rounded,
                    color: Colors.grey.shade600,
                    onTap: widget.onLogout ?? () {},
                  ),
                _IconAction(
                  tooltip: _extended ? 'Collapse menu' : 'Expand menu',
                  icon: _extended
                      ? Icons.menu_open_rounded
                      : Icons.menu_rounded,
                  color: AppTheme.primary,
                  onTap: _toggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const _BrandAvatar({super.key, this.margin = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3B66), width: 1.6),
        boxShadow: AppTheme.softShadow,
      ),
      child: Image.asset(
        'assets/images/Logo.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.directions_car_filled,
          size: 22,
          color: Color(0xFF0D3B66),
        ),
      ),
    );
  }
}

class _SideNavTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool extended;
  final int badge;
  final VoidCallback onTap;

  const _SideNavTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFEF3E2).withValues(alpha: 0.9)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 4,
              height: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 21,
                  color: selected
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade500,
                ),
                if (badge > 0)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.4),
                      ),
                      child: Text(
                        '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: extended ? 1 : 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: AnimatedPress(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}