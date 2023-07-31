import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/appColors.dart';

class ArtworkWallpaperScreen extends StatefulWidget {
  final String imageData;
  const ArtworkWallpaperScreen({Key? key, required this.imageData})
      : super(key: key);

  @override
  State<ArtworkWallpaperScreen> createState() => _ArtworkWallpaperScreenState();
}

class _ArtworkWallpaperScreenState extends State<ArtworkWallpaperScreen> {
  static final _db = FirebaseFirestore.instance;
  QuerySnapshot? querySnapshot;
  bool isLoading = false;

  final double _imageHeight = 500.h;
  final double _imageWidth = 250.w;


  final int _current = 0 ;
  String imageForWallpaper = '';


  Future<void> getWallpaper() async {
    if (isLoading) {
      return;
    }
    querySnapshot = await _db
        .collection('data')
        .where('imageId', isEqualTo: widget.imageData)
        .get();
    setState(() {
      isLoading = false;
    });
    if (querySnapshot != null && querySnapshot!.docs.isNotEmpty) {
      // do something with querySnapshot
    }

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
          duration: Duration(seconds: 1),
        ),
      );
    }

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

  String imageValue = '';

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
    // TODO: implement initState
    super.initState();
    imageValue = widget.imageData;
    if (!isLoading) {
      getWallpaper();
    }
    _loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: querySnapshot != null && querySnapshot!.docs.isNotEmpty ?
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(querySnapshot!.docs[0].get('imageUrl')), fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.colorWhite,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "${querySnapshot!.docs[0].get('tag')} Wallpaper",
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.colorWhite),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.visibility_outlined,
                            size: 18, color: AppColors.colorWhite),
                        SizedBox(width: 4.w),
                        Text(
                          "${querySnapshot!.docs[0].get('viewCount')} views",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.colorWhite),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Container(
                    height: 64.h,
                    width: 268.w,
                    decoration: BoxDecoration(
                        color: AppColors.colorPrimary,
                        borderRadius: BorderRadius.circular(33)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      children: <Widget>[
                                        SizedBox(height: 16.h),
                                        Image.asset("assets/images/box.png", height: 6.h, width: 40.w),
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
                                                onTap: (){
                                                  _setWallpaperForHome(querySnapshot!.docs[0].get('imageUrl'));
                                                  Navigator.pop(context);
                                                  _showRewardedAd();
                                                },
                                                child: Text(
                                                  'Set on home screen',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.colorTextMainBlack),
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
                                                onTap: (){
                                                  _setWallpaperForLock(querySnapshot!.docs[0].get('imageUrl'));
                                                  Navigator.pop(context);
                                                  _showRewardedAd();
                                                },
                                                child: Text(
                                                  "Set on lock screen",
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.colorTextMainBlack),
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
                                                onTap: (){
                                                  _setWallpaperForBoth(querySnapshot!.docs[0].get('imageUrl'));
                                                  Navigator.pop(context);
                                                  _showRewardedAd();
                                                },
                                                child: Text(
                                                  'Set on both screen',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.colorTextMainBlack),
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
                                                onTap: (){
                                                  _save(querySnapshot!.docs[0].get('imageUrl'));
                                                  Navigator.pop(context);
                                                  _showRewardedAd();
                                                },
                                                child: Text(
                                                  'Save to device',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.colorTextMainBlack),
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
                          child: const Icon(
                            Icons.format_paint,
                            color: AppColors.colorWhite,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _save(querySnapshot!.docs[0].get('imageUrl'));
                            _showRewardedAd();
                          },
                          child: SizedBox(
                              height: 40.h,
                              width: 40.w,
                              child:
                              SvgPicture.asset("assets/images/download.svg")),
                        ),
                        InkWell(
                          onTap: (){
                            Fluttertoast.showToast(
                              msg: 'Coming soon....',
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.white,
                            );
                          },
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: AppColors.colorWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ): const Center(child: CircularProgressIndicator())
    );
  }
}
