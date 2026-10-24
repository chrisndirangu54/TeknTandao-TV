import 'package:flutter/material.dart';
import 'src/core/app_services.dart';
import 'src/features/viewer/tv_screen.dart';
import 'src/features/android_tv/android_tv_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TeknTandaoApp(services: AppServices.demo()));
}

/// Replace AppServices.demo() with verified production adapters after
/// configuring Firebase and deploying the service APIs.
class TeknTandaoApp extends StatelessWidget {
  final AppServices services;
  const TeknTandaoApp({super.key, required this.services});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TeknTandao TV',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF205A91),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    home: const bool.fromEnvironment('ANDROID_TV_MODE', defaultValue: false)
      ? AndroidTvHome(services: services)
      : TvScreen(services: services),
  );
}
