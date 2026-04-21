import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/services/heartbeat_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

class AmalApp extends ConsumerStatefulWidget {
  const AmalApp({super.key});

  @override
  ConsumerState<AmalApp> createState() => _AmalAppState();
}

class _AmalAppState extends ConsumerState<AmalApp> {
  final HeartbeatService _heartbeat = HeartbeatService();

  @override
  void initState() {
    super.initState();
    _heartbeat.start();

    // Wire notification deep-links to go_router.
    NotificationService.onDeepLink = (route) {
      appRouter.go(route);
    };
  }

  @override
  void dispose() {
    _heartbeat.stop();
    NotificationService.onDeepLink = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Amal',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
