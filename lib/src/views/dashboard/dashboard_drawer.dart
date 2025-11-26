import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/src/localization/locale_provider.dart';

import 'package:flutter_app/src/providers/service_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = serviceProvider.currentUser;
    final String fullName = (user?.nomComplet.isNotEmpty ?? false)
        ? user!.nomComplet
        : 'Utilisateur non connecté';
    final String phoneNumber = user?.numeroTelephone ?? 'Numéro inconnu';

    return Drawer(
      backgroundColor: const Color(0xFF3D3D3D),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white24,
              child: user == null
                  ? const Icon(Icons.person, size: 48, color: Colors.white)
                  : Text(
                      fullName.isNotEmpty ? fullName[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              fullName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              phoneNumber,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 18),
            const Divider(
                color: Colors.white24, thickness: 1, indent: 24, endIndent: 24),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: Text(AppLocalizations.of(context)!.darkMode,
                  style: const TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeColor: const Color(0xFFFF6B00),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.white),
              title: Text(AppLocalizations.of(context)!.scanner,
                  style: const TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (v) {},
                activeColor: const Color(0xFFFF6B00),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: Text(
                Localizations.localeOf(context).languageCode == 'fr'
                    ? 'Français'
                    : 'English',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
              onTap: () {
                final provider =
                    Provider.of<LocaleProvider>(context, listen: false);
                final isFrench =
                    Localizations.localeOf(context).languageCode == 'fr';
                provider.setLocale(Locale(isFrench ? 'en' : 'fr'));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.power_settings_new, color: Colors.white),
              title: Text(AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: Colors.white)),
              onTap: () async {
                await serviceProvider.clearAuthToken();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AppLocalizations.of(context)!.version,
                style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
