import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../theme/app_theme.dart';
import 'auth_service.dart';

/// Ensures the current user has an account before a service is accessed.
///
/// Guests can browse the app, but requesting a service (roadside help,
/// mechanics, parts, chats, vehicles, profile) requires signing in. When the
/// user has no session a prompt is shown that routes into the auth flow.
Future<bool> requireAccount(
  BuildContext context, {
  String reason = 'Create a free account to continue with this service.',
}) async {
  if (AuthService.instance.isAuthenticated) return true;

  final String? choice = await _showAuthPrompt(context, reason);
  if (choice == null || !context.mounted) return false;

  final bool? result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => choice == 'register'
          ? const RegisterScreen(gateMode: true)
          : const LoginScreen(gateMode: true),
    ),
  );

  return (result ?? false) && AuthService.instance.isAuthenticated;
}

Future<String?> _showAuthPrompt(BuildContext context, String reason) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 28,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 32,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Account required',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop('register'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Create account'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.of(sheetContext).pop('login'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('I already have an account'),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(
                'Browse as guest',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      );
    },
  );
}
