import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallpers/widgets/appColors.dart';
import 'package:wallpers/widgets/custom_loading.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'artWorkScreen2.dart';

class ArtWorkScreen extends StatefulWidget {
  final String data;
  const ArtWorkScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ArtWorkScreen> createState() => _ArtWorkScreenState();
}

class _ArtWorkScreenState extends State<ArtWorkScreen> {

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

  String value = '';



  static final _db = FirebaseFirestore.instance;
  List<DocumentSnapshot> wallpapersCategoryBased = [];
  List<DocumentSnapshot> wallpapersCategoryBasedTrending = [];
  bool isLoading = false;
  bool isLoading2 = false;
  bool hasMore = true;
  bool hasMore2 = true;
  int documentLimit = 10;
  int documentLimit2 = 10;
  DocumentSnapshot? lastDocument;
  DocumentSnapshot? lastDocument2;
  final ScrollController _scrollControllerFirst = ScrollController();
  final ScrollController _scrollControllerSecond = ScrollController();

  getWallpapers(String categoryName) async {
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
          .where('tag', isEqualTo: categoryName)
      //.orderBy('name')
          .limit(documentLimit)
          .get();
    } else {
      querySnapshot = await _db
          .collection('data')
          .where('tag', isEqualTo: categoryName)
      //.orderBy('name')
          .startAfterDocument(lastDocument!)
          .limit(documentLimit)
          .get();
      print(1);
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    wallpapersCategoryBased.addAll(querySnapshot.docs);
    print(wallpapersCategoryBased.length);
    setState(() {
      isLoading = false;
    });
  }

  getWallpapersByViewCount(String categoryName) async {
    if (!hasMore2) {
      print('No More Products');
      return;
    }
    if (isLoading2) {
      return;
    }
    setState(() {
      isLoading2 = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument2 == null) {
      querySnapshot = await _db
          .collection('data')
          .orderBy('viewCount',descending: true)
          .where('tag', isEqualTo: categoryName)
          .limit(documentLimit2)
          .get();
    } else {
      querySnapshot = await _db
          .collection('data')
          .orderBy('viewCount',descending: true)
          .where('tag', isEqualTo: categoryName)
          .startAfterDocument(lastDocument2!)
          .limit(documentLimit2)
          .get();
      print(1);
    }
    if (querySnapshot.docs.length < documentLimit2) {
      hasMore2 = false;
    }
    lastDocument2 = querySnapshot.docs[querySnapshot.docs.length - 1];
    wallpapersCategoryBasedTrending.addAll(querySnapshot.docs);
    print(wallpapersCategoryBasedTrending.length);
    setState(() {
      isLoading2 = false;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(value);
    value = widget.data;
    _pageController = PageController(initialPage: _currentSelection);
    getWallpapers(value);
    getWallpapersByViewCount(value);
    showCustomDialog(context);
  }

  void incrementViews(int views, String id) async{
    var collection = FirebaseFirestore.instance.collection('data');
    collection
        .doc(id)
        .update({'viewCount' : views}) // <-- Updated data
        .then((_) => print('Success'))
        .whenComplete(() => null)
        .catchError((error) => print('Failed: $error'));
  }

  @override
  Widget build(BuildContext context) {


    _scrollControllerFirst.addListener(() {
      double maxScroll = _scrollControllerFirst.position.maxScrollExtent;
      double currentScroll = _scrollControllerFirst.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getWallpapers(value);
      }
    });
    print(value);

    _scrollControllerSecond.addListener(() {
      double maxScroll = _scrollControllerSecond.position.maxScrollExtent;
      double currentScroll = _scrollControllerSecond.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getWallpapersByViewCount(value);
      }
    });
    print(value);


    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      appBar: AppBar(
          backgroundColor: AppColors.colorWhite,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.colorBlack,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          elevation: 0),
      body: Container(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.colorTextMainBlack),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Column(
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
                            SizedBox(
                              child: GridView.builder(
                                controller: _scrollControllerFirst,
                                physics: const ScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2 / 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 10),
                                itemCount: wallpapersCategoryBased.length,
                                //padding: EdgeInsets.only(right: 12),
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic>? data = wallpapersCategoryBased[index].data() as Map<String, dynamic>?;
                                  return InkWell(
                                    onTap: () {
                                      incrementViews(data?['viewCount']+1, data?['imageId']);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ArtworkScreen2(
                                                data : data?['artistName'],
                                                id: data?['imageId'],
                                              )));
                                    },
                                    child:
                                    Container(
                                      decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.colorGradientStart, AppColors.colorGradientEnd],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image(
                                          image: NetworkImage(data?['thumbUrl']),
                                          fit: BoxFit.cover,
                                          height: 73.h,
                                          width: 119.w,
                                        ),
                                        //Text('${data?['viewCount']}')
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              child: GridView.builder(
                                physics: const ScrollPhysics(),
                                controller: _scrollControllerSecond,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2 / 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 10),
                                itemCount: wallpapersCategoryBasedTrending.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic>? data = wallpapersCategoryBasedTrending[index].data() as Map<String, dynamic>?;
                                  return InkWell(
                                    onTap: () {
                                      incrementViews(data?['viewCount']+1, data?['imageId']);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ArtworkScreen2(
                                                data : data?['artistName'],
                                                id: data?['imageId'],
                                              )));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.colorGradientStart, AppColors.colorGradientEnd],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image(
                                          image: NetworkImage(data?['thumbUrl']),
                                          fit: BoxFit.cover,
                                          height: 73.h,
                                          width: 119.w,
                                        ),
                                        //Text('${data?['viewCount']}')
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
