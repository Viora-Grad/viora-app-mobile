import 'package:flutter/material.dart';
import 'package:viora_app/core/di/service_locator.dart';
import 'package:viora_app/core/routes/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Viora App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: appRouter,
      
    );
  }
}
