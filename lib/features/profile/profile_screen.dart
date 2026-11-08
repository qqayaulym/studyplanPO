import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/menu_tile.dart';
import '../auth/data/auth_service.dart';
import '../tasks/data/task_repository.dart';

/// Профиль: аты, email, қысқаша статистика, мәзір (пәндер, статистика, параметрлер, шығу).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final auth = AuthService.instance;
    final controller = TextEditingController(text: auth.currentUser?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.editProfile),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: AppStrings.yourName),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? AppStrings.enterName
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    final ok = await auth.updateName(name);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.profileUpdated)));
    }
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthService.instance.logout();
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final repo = TaskRepository.instance;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: Listenable.merge([AuthService.instance, repo]),
            builder: (context, _) {
              final user = context.watch<AuthService>().currentUser;
              final name = user?.name ?? '';
              final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: cs.primary,
                      child: Text(initial,
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimary)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(name,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  Center(
                    child: Text(user?.email ?? '',
                        style: TextStyle(color: secondaryTextColor(context))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Stat(value: '${repo.total}', label: AppStrings.total),
                      const SizedBox(width: 12),
                      _Stat(value: '${repo.doneCount}', label: AppStrings.done),
                      const SizedBox(width: 12),
                      _Stat(
                          value: '${repo.overdueCount}',
                          label: AppStrings.overdue,
                          danger: repo.overdueCount > 0),
                    ],
                  ),
                  const SizedBox(height: 20),
                  MenuTile(
                    icon: Icons.edit_outlined,
                    title: AppStrings.editProfile,
                    onTap: () => _editName(context),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.menu_book_outlined,
                    title: AppStrings.subjectsTitle,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.subjects),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.cloud_outlined,
                    title: AppStrings.serverTitle,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.remote),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Оқу орнының орналасуы',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.location),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.timer_outlined,
                    title: 'Pomodoro: назар қою уақыты',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.focus),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.forum_outlined,
                    title: 'Тапсырмалар чаты (real-time)',
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.realtimeChat),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.bar_chart,
                    title: AppStrings.statistics,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.statistics),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.settings),
                  ),
                  const SizedBox(height: 8),
                  MenuTile(
                    icon: Icons.logout,
                    title: AppStrings.logout,
                    danger: true,
                    onTap: () => _logout(context),
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

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool danger;
  const _Stat({required this.value, required this.label, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: danger ? cs.error : cs.primary)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 12, color: secondaryTextColor(context))),
          ],
        ),
      ),
    );
  }
}
