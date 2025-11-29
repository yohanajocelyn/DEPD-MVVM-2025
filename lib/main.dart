import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'package:depd_mvvm_2025/shared/style.dart';
import 'package:depd_mvvm_2025/view/pages/pages.dart';// Import your Main Layout
import 'package:depd_mvvm_2025/viewmodel/home_viewmodel.dart';
import 'package:depd_mvvm_2025/viewmodel/international_home_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

// 1. DEFINE THE ROUTER HERE
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainPage(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Domestic
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'HomePage',
              builder: (context, state) {
                // Scoped Provider: ViewModel only lives here
                return ChangeNotifierProvider(
                  create: (_) => HomeViewModel(),
                  child: const HomePage(),
                );
              },
            ),
          ],
        ),
        // Branch 2: International
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/international',
              name: 'InternationalHomePage',
              builder: (context, state) {
                // Scoped Provider: ViewModel only lives here
                return ChangeNotifierProvider(
                  create: (_) => InternationalHomeViewModel(),
                  child: const InternationalHomePage(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. USE MATERIALAPP.ROUTER
    return MaterialApp.router(
      routerConfig: _router, // Pass the router configuration
      debugShowCheckedModeBanner: false,
      title: 'Flutter x RajaOngkir API',
      
      // Keep your existing theme exactly as it was
      theme: ThemeData(
        primaryColor: Style.blue800,
        scaffoldBackgroundColor: Style.grey50,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Style.black,
              displayColor: Style.black,
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Style.blue800),
            foregroundColor: WidgetStateProperty.all<Color>(Style.white),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.all(16),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Style.blue800),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Style.grey500),
          floatingLabelStyle: TextStyle(color: Style.blue800),
          hintStyle: TextStyle(color: Style.grey500),
          iconColor: Style.grey500,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Style.grey500),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Style.blue800, width: 2),
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}