import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:getx_todo/app/core/utils/extentions.dart';
import 'package:getx_todo/app/data/services/admob_service.dart';
import 'package:getx_todo/app/modules/home/controller.dart';
import 'package:getx_todo/app/widgets/add_dialog.dart';
import 'package:getx_todo/app/widgets/task_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/values/colors.dart';
import '../../data/models/task.dart';
import '../../widgets/add_card.dart';
import '../report/view.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() =>
         IndexedStack(
          index: controller.tabIndex.value,
          children: [SafeArea(
              child: ListView(

            children: [

              Padding(
                padding:  EdgeInsets.all(4.0.wp),
                child: Text(
                  "My List",
                  style: TextStyle(
                    fontSize: 24.0.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                width: double.infinity,
                child: AdWidget(
                  ad: BannerAd(
                    adUnitId: AdmobService.getBannerAdUnitId()!,
                   // adUnitId: "ca-app-pub-3940256099942544/6300978111",
                    size: AdSize.largeBanner,
                    request: AdRequest(),
                    listener: BannerAdListener(
                      onAdLoaded: (Ad ad) =>print("Ad loaded"),
                      onAdFailedToLoad: (Ad ad, LoadAdError error){
                        ad.dispose();
                        print("Ad failed to load: $error");
                      },
                      onAdOpened: (Ad ad)=>print("Ad opened"),
                      onAdClosed: (Ad ad)=>print("Ad closed"),
                    ),
                  )..load(),
                ),
              ),
              Obx(() => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  ...controller.tasks.map((element) => LongPressDraggable(
                    data: element,
                     onDragStarted: ()=>controller.changeDeleting(true),
                      onDraggableCanceled: (_,__)=>controller.changeDeleting(false),
                      onDragEnd: (_)=>controller.changeDeleting(false),
                      feedback: Opacity(
                          opacity: 0.8,
                        child: TaskCard(task: element),
                      ),
                      child: TaskCard(task: element))).toList(),
                  AddCard(),
                ],
              ),)
            ],
          )),
          ReportPage(),
          ],
        ),
      ),
      floatingActionButton: DragTarget<Task>(
        builder: (_,__,___) {
          return Obx(() =>
              FloatingActionButton(
                backgroundColor: controller.deleting.value ? Colors.red : blue,
                onPressed: () {
                 if(controller.tasks.isNotEmpty){
                    Get.to(()=>AddDialog(),transition: Transition.downToUp);
                 }else{
                   EasyLoading.showInfo("Please create your task type");
                 }
                },
                child: Icon(
                    controller.deleting.value ? Icons.delete : Icons.add),
              ),
          );
        },
        onAccept: (Task task){
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
        child: Obx(()=>
           BottomNavigationBar(
            onTap: (int index)=>controller.changeTabIndex(index),
            currentIndex: controller.tabIndex.value,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                label: "Home",
                icon: Padding(
                  padding:  EdgeInsets.only(right: 15.0.wp),
                  child: const Icon(Icons.apps),
                )
              ) ,
              BottomNavigationBarItem(
                  label: "Report",
                  icon: Padding(
                    padding:  EdgeInsets.only(left: 15.0.wp),
                    child: const Icon(Icons.data_usage),
                  ))
            ],),
        ),
      ),
    );
  }
}
