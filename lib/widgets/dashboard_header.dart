import 'package:flutter/material.dart';

import 'animated_entry.dart';

class DashboardHeader extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final bool isGuest;
  final ValueChanged<int>? onSelectSection;
  final VoidCallback? onSignIn;
  final VoidCallback? onGetService;

  const DashboardHeader({
    super.key,
    this.userName = 'Driver',
    this.userEmail,
    this.isGuest = false,
    this.onSelectSection,
    this.onSignIn,
    this.onGetService,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _search = TextEditingController();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final focused = _focusNode.hasFocus;
      if (focused != _focused) setState(() => _focused = focused);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _search.dispose();
    super.dispose();
  }

  String get _initials {
    if (widget.isGuest) return 'G';
    final name = widget.userName.trim();
    if (name.isEmpty) return 'D';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Searching for "${query.trim()}"…')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const _HeaderBrand(),
          const SizedBox(width: 28),
          Expanded(child: _buildSearch()),
          const SizedBox(width: 18),
          _buildGetServiceButton(),
          const SizedBox(width: 20),
          _NotificationBell(),
          const SizedBox(width: 18),
          Container(width: 1, height: 34, color: Colors.grey.shade200),
          const SizedBox(width: 18),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? const Color(0xFFF59E0B)
              : const Color(0xFF0D3B66).withValues(alpha: 0.45),
          width: 1.6,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _search,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: _submitSearch,
        style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
        cursorColor: const Color(0xFFF59E0B),
        decoration: InputDecoration(
          hintText: 'Search services, mechanics, parts…',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_search.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
                  visualDensity: VisualDensity.compact,
                ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '⌘K',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGetServiceButton() {
    return FilledButton.icon(
      onPressed: widget.onGetService,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      icon: const Icon(Icons.build_circle_outlined, size: 18),
      label: const Text(
        'Get a service',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      onSelected: (value) {
        switch (value) {
          case 'signin':
            widget.onSignIn?.call();
          case 'profile':
            widget.onSelectSection?.call(4);
          case 'help':
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Help & support coming soon.')),
              );
        }
      },
      itemBuilder: (context) => [
        if (widget.isGuest) ...[
          PopupMenuItem(
            value: 'signin',
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.login_rounded,
                    size: 18,
                    color: Color(0xFFB45309),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Sign in'),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ],
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: Color(0xFF0D3B66),
                ),
              ),
              const SizedBox(width: 12),
              const Text('View profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 18,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Help & support'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isGuest ? 'Browsing as' : 'Signed in as',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                widget.userEmail?.isNotEmpty == true
                    ? widget.userEmail!
                    : widget.userName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
      child: AnimatedPress(
        onTap: widget.isGuest ? widget.onSignIn : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D3B66), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D3B66),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    widget.userName.split(' ').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Text(
                  widget.isGuest ? 'Guest' : 'Driver',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBrand extends StatelessWidget {
  const _HeaderBrand();

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/images/Logo.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFE8EDF5),
                  child: Icon(
                    Icons.directions_car_filled,
                    size: 20,
                    color: Color(0xFF0D3B66),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AutoAssist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Roadside service',
                style: TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No new notifications.')),
          );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(child: Icon(Icons.notifications_outlined, size: 21)),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}