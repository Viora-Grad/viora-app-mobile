import 'package:flutter/material.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';
import 'package:viora_app/core/services/notification_service.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dependencyInjection();
  // Prepare local notifications (timezone + channels) for wellness reminders.
  await sl<NotificationService>().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stamp the time the app leaves the foreground so the Sleep Tracker can
    // later estimate how long the phone stayed idle (a possible sleep window).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      sl<WellnessLocal>().setLastBackgrounded(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Viora App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: appRouter,
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child!,
      ),
    );
  }
}
