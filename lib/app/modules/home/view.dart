import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:getx_todo/app/core/utils/extentions.dart';

import 'package:getx_todo/app/modules/home/controller.dart';
import 'package:getx_todo/app/widgets/add_dialog.dart';
import 'package:getx_todo/app/widgets/task_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/values/colors.dart';
import '../../data/models/task.dart';
import '../../widgets/add_card.dart';
import '../report/view.dart';

class HomePage extends GetView<HomeController> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            SafeArea(
                child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0.wp),
                      child: Text(
                        "My List",
                        style: TextStyle(
                          fontSize: 24.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0.wp),
                      child: TextButton(
                        onPressed: isLoading ? null : fetchOffers,
                        child: Text(
                          "See  Plans",
                          style: TextStyle(
                            fontSize: 24.0.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: AdWidget(
                    ad: BannerAd(
                      adUnitId: "ca-app-pub-9190785688707604/6252397285",
                      // adUnitId: "ca-app-pub-3940256099942544/6300978111",
                      size: AdSize.largeBanner,
                      request: AdRequest(),
                      listener: BannerAdListener(
                        onAdLoaded: (Ad ad) => print("Ad loaded"),
                        onAdFailedToLoad: (Ad ad, LoadAdError error) {
                          ad.dispose();
                          print("Ad failed to load: $error");
                        },
                        onAdOpened: (Ad ad) => print("Ad opened"),
                        onAdClosed: (Ad ad) => print("Ad closed"),
                      ),
                    )..load(),
                  ),
                ),
                Obx(
                  () => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      ...controller.tasks
                          .map((element) => LongPressDraggable(
                              data: element,
                              onDragStarted: () =>
                                  controller.changeDeleting(true),
                              onDraggableCanceled: (_, __) =>
                                  controller.changeDeleting(false),
                              onDragEnd: (_) =>
                                  controller.changeDeleting(false),
                              feedback: Opacity(
                                opacity: 0.8,
                                child: TaskCard(task: element),
                              ),
                              child: TaskCard(task: element)))
                          .toList(),
                      AddCard(),
                    ],
                  ),
                )
              ],
            )),
            ReportPage(),
          ],
        ),
      ),
      floatingActionButton: DragTarget<Task>(
        builder: (_, __, ___) {
          return Obx(
            () => FloatingActionButton(
              backgroundColor: controller.deleting.value ? Colors.red : blue,
              onPressed: () {
                if (controller.tasks.isNotEmpty) {
                  Get.to(() => AddDialog(), transition: Transition.downToUp);
                } else {
                  EasyLoading.showInfo("Please create your task type");
                }
              },
              child: Icon(controller.deleting.value ? Icons.delete : Icons.add),
            ),
          );
        },
        onAccept: (Task task) {
          controller.deleteTask(task);
          EasyLoading.showSuccess("Delete Success");
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Obx(
          () => BottomNavigationBar(
            onTap: (int index) => controller.changeTabIndex(index),
            currentIndex: controller.tabIndex.value,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                  label: "Home",
                  icon: Padding(
                    padding: EdgeInsets.only(right: 15.0.wp),
                    child: const Icon(Icons.apps),
                  )),
              BottomNavigationBarItem(
                  label: "Report",
                  icon: Padding(
                    padding: EdgeInsets.only(left: 15.0.wp),
                    child: const Icon(Icons.data_usage),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future fetchOffers() async {
    final offerings = await PurchaseApi.fetchOffers();
    if (offerings.isEmpty) {
    Get.snackbar('Info', 'No Plans Found');
    } else {
      final packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();

      Get.bottomSheet(
          Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(child: ListView.builder(
              itemCount: packages.length,
              itemBuilder: (context,index){
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.star),
                      title: Text('Upgrade your Plan'),
                      subtitle: Text('Upgrade to a new plan to enjoy more benefits'),
                    ),
                    ListTile(
                      title: Text('${packages[index][""]}'),
                      subtitle: Text('Upgrade to a new plan to enjoy more benefits'),

                    ),
                  ],
                );}
          )),
        ],
      ));
    }
  }
}

class PurchaseApi {
  static const _apiKey = 'goog_fitjpCNXxVxSUkgeCOKAxshkaNc';
  static Future init() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup(_apiKey);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      return [];
    }
  }
}
