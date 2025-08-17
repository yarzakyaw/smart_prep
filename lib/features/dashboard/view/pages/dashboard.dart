import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/classes/view/pages/classes_page.dart';
import 'package:smart_prep/features/home/view/pages/home_page.dart';
import 'package:smart_prep/features/market/view/pages/market_page.dart';
import 'package:smart_prep/features/practice/view/pages/practice_page.dart';
import 'package:smart_prep/features/profile/view/pages/profile_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //page index var for changing page
  int pageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    PracticePage(),
    ClassesPage(),
    MarketPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),

      bottomNavigationBar: ConvexAppBar(
        backgroundColor: isDark ? AppPallete.gradient3 : AppPallete.greenColor,
        items: [
          TabItem(
            icon: LineAwesomeIcons.home_solid,
            title: translate(context, 'home'),
          ),
          TabItem(
            icon: LineAwesomeIcons.book_open_solid,
            title: translate(context, 'practice'),
          ),
          TabItem(
            icon: LineAwesomeIcons.school_solid,
            title: translate(context, 'class'),
          ),
          TabItem(
            icon: LineAwesomeIcons.store_solid,
            title: translate(context, 'marketplace'),
          ),
          TabItem(
            icon: LineAwesomeIcons.user_solid,
            title: translate(context, 'profile'),
          ),
        ],
        onTap: (int value) {
          setState(() {
            pageIndex = value;
          });
        },
      ),
      body: _pages[pageIndex],
    );
  }
}
