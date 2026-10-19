import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/medications/medications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profiles/profiles_screen.dart';
import '../features/records/observation_screens.dart';
import '../features/records/records_screen.dart';
import '../features/records/simple_record_screens.dart';
import '../features/records/vaccine_screens.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_screen.dart';
import '../features/transfer/share_screen.dart';
import 'theme.dart';

GoRouter buildRouter({required bool onboarded}) => GoRouter(
  initialLocation: onboarded ? '/today' : '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    GoRoute(path: '/profiles', builder: (_, _) => const ProfilesScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/medications',
              builder: (_, _) => const MedicationsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              builder: (_, _) => const RecordsScreen(),
              routes: [
                GoRoute(
                  path: 'vaccines',
                  builder: (_, _) => const VaccinesScreen(),
                ),
                GoRoute(
                  path: 'allergies',
                  builder: (_, _) => const AllergiesScreen(),
                ),
                GoRoute(
                  path: 'conditions',
                  builder: (_, _) => const ConditionsScreen(),
                ),
                GoRoute(
                  path: 'measurements',
                  builder: (_, _) => const ObservationsScreen(),
                ),
                GoRoute(
                  path: 'appointments',
                  builder: (_, _) => const AppointmentsScreen(),
                ),
                GoRoute(
                  path: 'visits',
                  builder: (_, _) => const EncountersScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/share', builder: (_, _) => const ShareScreen()),
          ],
        ),
      ],
    ),
  ],
);

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.today_outlined),
          selectedIcon: Icon(Icons.today),
          label: 'Bugün',
        ),
        NavigationDestination(
          icon: Icon(Icons.medication_outlined),
          selectedIcon: Icon(Icons.medication),
          label: 'İlaçlar',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_shared_outlined),
          selectedIcon: Icon(Icons.folder_shared),
          label: 'Kayıtlar',
        ),
        NavigationDestination(
          icon: Icon(Icons.swap_vert_circle_outlined),
          selectedIcon: Icon(Icons.swap_vert_circle),
          label: 'Paylaş',
        ),
      ],
    ),
  );
}

class LokmanApp extends StatefulWidget {
  const LokmanApp({super.key, required this.onboarded});

  final bool onboarded;

  @override
  State<LokmanApp> createState() => _LokmanAppState();
}

class _LokmanAppState extends State<LokmanApp> {
  late final _router = buildRouter(onboarded: widget.onboarded);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Lokman',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    locale: const Locale('tr'),
    supportedLocales: const [Locale('tr')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    routerConfig: _router,
  );
}
