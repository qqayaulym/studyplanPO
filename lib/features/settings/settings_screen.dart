import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/menu_tile.dart';
import 'app_settings.dart';

/// Параметрлер: қараңғы тақырып, еске салғыш, уақыт, тіл, көмек. Барлығы дерекқорда сақталады.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickTime(BuildContext context, AppSettings s) async {
    final t = await showTimePicker(context: context, initialTime: s.reminderTime);
    if (t != null) await s.setReminderTime(t);
  }

  void _help(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.help),
        content: const SingleChildScrollView(child: Text(AppStrings.helpText)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(AppStrings.close)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: secondaryTextColor(context))),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppSettings.instance;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: s,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _section(context, AppStrings.interfaceSection),
                  MenuTile(
                    icon: Icons.dark_mode_outlined,
                    title: AppStrings.darkTheme,
                    trailing: Switch(
                        value: s.darkMode, onChanged: (v) => s.setDarkMode(v)),
                  ),
                  const SizedBox(height: 8),
                  const MenuTile(
                    icon: Icons.language,
                    title: AppStrings.language,
                    trailing: Text(AppStrings.kazakh),
                  ),
                  _section(context, AppStrings.notificationsSection),
                  MenuTile(
                    icon: Icons.notifications_none,
                    title: AppStrings.reminders,
                    trailing: Switch(
                        value: s.remindersOn,
                        onChanged: (v) => s.setRemindersOn(v)),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.schedule,
                    title: AppStrings.defaultTime,
                    trailing: Text(s.reminderTime.format(context)),
                    onTap: s.remindersOn ? () => _pickTime(context, s) : null,
                  ),
                  _section(context, AppStrings.otherSection),
                  MenuTile(
                    icon: Icons.help_outline,
                    title: AppStrings.help,
                    onTap: () => _help(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
