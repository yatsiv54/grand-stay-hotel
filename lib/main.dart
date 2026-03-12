import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_router.dart';
import 'di.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerDependencies();
  runApp(const GrandStayApp());
}

class GrandStayApp extends StatelessWidget {
  const GrandStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'GrandStay',
        theme: AppTheme.buildTheme(GoogleFonts.nunito()),
        routerConfig: _appRouter.router,
      ),
    );
  }
}



final AppRouter _appRouter = AppRouter();
