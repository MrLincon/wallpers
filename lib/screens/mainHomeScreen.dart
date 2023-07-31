import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallpers/screens/categoriesScreen.dart';
import 'package:wallpers/screens/settingScreen.dart';
import 'package:wallpers/screens/trendingScreen.dart';
import 'package:wallpers/widgets/appColors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'homeScreen.dart';

class MainHomeScreen extends StatefulWidget {
  final int value;
  const MainHomeScreen({Key? key, required this.value}) : super(key: key);
  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.value;
  }

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CategoriesScreen(),
    TrendingScreen(),
    SettingScreen(
      screenName: '',
    ),
  ];
  String screenName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _widgetOptions.elementAt(_selectedIndex),
          // Your app content goes here
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  )
                ],
                borderRadius: const BorderRadius.all(Radius.circular(60)),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: GNav(
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  duration: const Duration(milliseconds: 100),
                  tabBackgroundColor: AppColors.colorPrimary,
                  color: AppColors.colorPrimary,
                  tabs: [
                    const GButton(
                      icon: Icons.home,
                    ),
                    const GButton(
                      icon: Icons.category_outlined,
                    ),
                    const GButton(
                      icon: Icons.local_fire_department_outlined,
                    ),
                    GButton(
                      onPressed: () {
                        String text = screenName.toString();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingScreen(
                                  screenName: 'fromSettings',
                                )));
                      },
                      icon: Icons.settings_outlined,
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                      print(index);
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
