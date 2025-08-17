import 'package:flutter/material.dart';
import 'package:smart_prep/features/auth/view/pages/sign_in_page.dart';
import 'package:smart_prep/features/auth/view/pages/sign_up_page.dart';
import 'package:smart_prep/features/dashboard/view/pages/dashboard.dart';
import 'package:smart_prep/features/splash/view/pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case '/':
      //   return MaterialPageRoute(
      //     builder: (context) => const SplashScreen(),
      //   );
      case '/':
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case 'dashboard':
        return MaterialPageRoute(builder: (context) => const Dashboard());
      case 'signin':
        return MaterialPageRoute(builder: (context) => const SignInPage());
      case 'signup':
        return MaterialPageRoute(builder: (context) => const SignUpPage());
    }
    return null;
  }
}
