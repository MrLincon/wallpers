import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/appColors.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  showExitPopup() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Text(
              "Do you want to exit?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.colorTextMainBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp),
            ),
            contentPadding:
                const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 30.h,
                    width: 72.w,
                    decoration: BoxDecoration(
                        color: AppColors.colorPrimary,
                        borderRadius: BorderRadius.circular(100)),
                    child: InkWell(
                      onTap: () {
                        SystemNavigator.pop();
                      },
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              color: AppColors.colorWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 30.h,
                    width: 72.w,
                    decoration: BoxDecoration(
                        color: AppColors.colorWhite,
                        border: Border.all(
                            width: 1.w, color: AppColors.colorWhiteLowEmp),
                        borderRadius: BorderRadius.circular(100)),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                        child: Text(
                          "No",
                          style: TextStyle(
                              color: AppColors.colorTextMainBlack,
                              fontWeight: FontWeight.w300,
                              fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            actionsPadding: const EdgeInsets.only(bottom: 32),
          );
        });
  }

  static final _db = FirebaseFirestore.instance;

  List<DocumentSnapshot> wallpaperOfTheDay = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 5;
  DocumentSnapshot? lastDocument;
  final PageController _scrollControllerFirst = PageController();

  getWallpaperOfTheDay() async {
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await _db
          .collection('data')
          .orderBy('viewCount', descending: true)
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await _db
          .collection('data')
          .orderBy('viewCount', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
      print(1);
    }

    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    wallpaperOfTheDay.addAll(querySnapshot.docs);
    print(wallpaperOfTheDay.length);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _setWallpaperForHome(String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting wallpaper...')));
    final result = await WallpaperManager.setWallpaperFromFile(file.path, WallpaperManager.HOME_SCREEN);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallpaper set successfully.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to set wallpaper.')));
    }
  }


  Future<void> _setWallpaperForLock(String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting wallpaper...')));
    final result = await WallpaperManager.setWallpaperFromFile(file.path, WallpaperManager.LOCK_SCREEN);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallpaper set successfully.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to set wallpaper.')));
    }
  }

  Future<void> _setWallpaperForBoth(String imageUrl) async {
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting wallpaper...')));
    final result = await WallpaperManager.setWallpaperFromFile(file.path, WallpaperManager.BOTH_SCREEN);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wallpaper set successfully.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to set wallpaper.')));
    }
  }

  Future<void> _save(String image) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saving image...'),
        ),
      );
    }

    TextStyle selectedStyle = const TextStyle(
      color: Colors.white,
      // Set any other style properties as per your design requirements
    );

    var status = await Permission.storage.request();
    if(status.isGranted){
      var response = await Dio().get(
          image,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "hello");
      print(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved successfully.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  late final RewardedAd rewardedAd;
  final String rewardedAdUnitId = "ca-app-pub-3940256099942544/5224354917";


  //method to load an ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request:const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        //when failed to load
        onAdFailedToLoad: (LoadAdError error){
          print("Failed to load rewarded ad, Error: $error");
        },
        //when loaded
        onAdLoaded: (RewardedAd ad){
          print("$ad loaded");
          // Keep a reference to the ad so you can show it later.
          rewardedAd = ad;

          //set on full screen content call back
          _setFullScreenContentCallback();
        },
      ),
    );
  }

  //method to set show content call back
  void _setFullScreenContentCallback(){
    if(rewardedAd == null) return;
    rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      //when ad  shows fullscreen
      onAdShowedFullScreenContent: (RewardedAd ad) => print("$ad onAdShowedFullScreenContent"),
      //when ad dismissed by user
      onAdDismissedFullScreenContent: (RewardedAd ad){
        print("$ad onAdDismissedFullScreenContent");

        //dispose the dismissed ad
        ad.dispose();
      },
      //when ad fails to show
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error){
        print("$ad  onAdFailedToShowFullScreenContent: $error ");
        //dispose the failed ad
        ad.dispose();
      },

      //when impression is detected
      onAdImpression: (RewardedAd ad) =>print("$ad Impression occured"),
    );

  }

  //show ad method
  void _showRewardedAd(){
    //this method take a on user earned reward call back
    rewardedAd.show(
      //user earned a reward
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem){
          //reward user for watching your ad
          num amount = rewardItem.amount;
          print("You earned: $amount");
        }
    );
  }


  @override
  void initState() {
    getWallpaperOfTheDay();
    _loadRewardedAd();
    // TODO: implement initState
    super.initState();
  }

  final spinkit = const SpinKitRing(
    color: AppColors.colorPrimary,
    size: 50,
    lineWidth: 4,
  );

  @override
  Widget build(BuildContext context) {
    _scrollControllerFirst.addListener(() {
      double maxScroll = _scrollControllerFirst.position.maxScrollExtent;
      double currentScroll = _scrollControllerFirst.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getWallpaperOfTheDay();
      }
    });

    return WillPopScope(
      onWillPop: () async {
        showExitPopup();
        return false;
      },
      child: Scaffold(
          body: PageView.builder(
        controller: _scrollControllerFirst,
        scrollDirection: Axis.vertical,
        itemCount: wallpaperOfTheDay.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic>? data =
              wallpaperOfTheDay[index].data() as Map<String, dynamic>?;
          return Stack(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.colorGradientStartTrending,
                        AppColors.colorGradientEndTrending,
                        AppColors.colorGradientEndTrending
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Center(child: spinkit),
                    imageUrl: data?['imageUrl'],
                    fit: BoxFit.cover,
                  )),
              Positioned(
                  top: 57.h,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Trending",
                      style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.colorWhite),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 58, right: 16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: 300.h,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 16.h),
                                  Image.asset("assets/images/box.png",
                                      height: 6.h, width: 40.w),
                                  SizedBox(height: 24.h),
                                  Text(
                                    "What would like to do?",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.colorTextMainBlack),
                                  ),
                                  SizedBox(height: 24.h),
                                  Container(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/phone.png",
                                          height: 20.h,
                                          width: 20.w,
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            _setWallpaperForHome(data?['imageUrl']);
                                            Navigator.pop(context);
                                            _showRewardedAd();
                                          },
                                          child: Text(
                                            'Set on home screen',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .colorTextMainBlack),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  const Divider(height: 1),
                                  SizedBox(height: 16.h),
                                  Container(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/lockPhone.png",
                                          height: 20.h,
                                          width: 20.w,
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            _setWallpaperForLock(data?['imageUrl']);
                                            Navigator.pop(context);
                                            _showRewardedAd();
                                          },
                                          child: Text(
                                            "Set on lock screen",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .colorTextMainBlack),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  const Divider(height: 1),
                                  SizedBox(height: 16.h),
                                  Container(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/lockPhone2.png",
                                          height: 20.h,
                                          width: 20.w,
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            _setWallpaperForBoth(data?['imageUrl']);
                                            Navigator.pop(context);
                                            _showRewardedAd();
                                          },
                                          child: Text(
                                            'Set on both screen',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .colorTextMainBlack),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  const Divider(height: 1),
                                  SizedBox(height: 16.h),
                                  Container(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/images/save.png",
                                          height: 24.h,
                                          width: 24.w,
                                        ),
                                        SizedBox(width: 12.w),
                                        InkWell(
                                          onTap: () {
                                            _save(data?['imageUrl']);
                                            Navigator.pop(context);
                                            _showRewardedAd();
                                          },
                                          child: Text(
                                            'Save to device',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors
                                                    .colorTextMainBlack),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/images/trending_page_dawnload_icon.svg",
                      height: 48.h,
                      width: 48.w,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      )),
    );
  }
}
