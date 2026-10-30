import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/content_width.dart';

class _Page {
  final IconData icon;
  final String title;
  final String text;
  const _Page(this.icon, this.title, this.text);
}

/// Onboarding: 3 бет, «Келесі» / «Өткізіп жіберу» / «Бастау».
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pages = [
    _Page(Icons.format_list_bulleted, AppStrings.onb1Title, AppStrings.onb1Text),
    _Page(Icons.notifications_none, AppStrings.onb2Title, AppStrings.onb2Text),
    _Page(Icons.bar_chart, AppStrings.onb3Title, AppStrings.onb3Text),
  ];

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goLogin() =>
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);

  void _next() {
    if (_index == _pages.length - 1) {
      _goLogin();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: last
                        ? null
                        : TextButton(
                            onPressed: _goLogin,
                            child: const Text(AppStrings.skip),
                          ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final p = _pages[i];
                      return LayoutBuilder(
                        builder: (context, box) {
                          final circle = box.maxHeight < 420 ? 140.0 : 220.0;
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minHeight: box.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: circle,
                                    height: circle,
                                    decoration: BoxDecoration(
                                      color: cs.primary.withAlpha(30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(p.icon,
                                        size: circle * 0.4, color: cs.primary),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    p.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    p.text,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            color: secondaryTextColor(context)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? AppColors.accent
                              : cs.onSurface.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: last ? AppStrings.start : AppStrings.next,
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
