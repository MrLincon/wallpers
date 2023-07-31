import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

import '../screens/artWorkScreen2.dart';
import '../widgets/appColors.dart';
import 'artworkWallpaperModel.dart';

class TabbarModel extends StatefulWidget {
  const TabbarModel({super.key});

  @override
  _TabbarModelState createState() => _TabbarModelState();
}

class _TabbarModelState extends State<TabbarModel> {
  final Map<int, Widget> _children = {
    0: SizedBox(
      height: 30.h,
      width: 350.w,
      child: const Center(child: Text('Recently added')),
    ),
    1: SizedBox(
      height: 30.h,
      width: 350.w,
      child: const Center(child: Text('Trending')),
    ),
  };
  int _currentSelection = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: MaterialSegmentedControl(
            children: _children,
            borderRadius: 30,
            selectionIndex: _currentSelection,
            borderColor: AppColors.colorWhite,
            unselectedColor: AppColors.colorTabUnselected,
            selectedColor: AppColors.colorPrimary,
            horizontalPadding: const EdgeInsets.symmetric(vertical: 5),
            onSegmentChosen: (index) {
              setState(() {
                _currentSelection = index;
                _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 500), curve: Curves.ease);
              });
            },
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSelection = index;
              });
            },
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ArtworkScreen2(
                                      data : "Marie Laurencin",
                                      id: '',
                                    )));
                          },
                          child: const ArtworkWallpaperModel()),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ArtworkScreen2(
                                      data : "Marie Laurencin",
                                      id: '',
                                    )));
                          },
                          child: const ArtworkWallpaperModel()),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
