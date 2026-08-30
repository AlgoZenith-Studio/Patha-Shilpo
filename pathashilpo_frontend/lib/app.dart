import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/routing/route_names.dart';

class PathaShilpoApp extends StatelessWidget {
  const PathaShilpoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patha-Shilpa • Rural Artisan Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.buyerHome,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
