import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todo/app/core/utils/extentions.dart';
import 'package:getx_todo/app/core/values/colors.dart';
import 'package:getx_todo/app/modules/home/controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../data/services/admob_service.dart';

class ReportPage extends StatelessWidget {
  ReportPage({Key? key}) : super(key: key);
final homeCtrl = Get.find<HomeController>();
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx((){
        var createdTasks = homeCtrl.getTotalTask();
        var completedTasks=homeCtrl.getTotalDoneTask();
        var liveTasks = createdTasks-completedTasks;
        var percent = (completedTasks/createdTasks*100).toStringAsFixed(0);
        return ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(4.0.wp),
              child: Text("My Report",
              style: TextStyle(
                fontSize: 24.0.sp,
              fontWeight: FontWeight.bold
              ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0.wp),
              child: Text(DateFormat.yMMMMd().format(DateTime.now()),
              style: TextStyle(
                fontSize: 14.0.sp,
                color: Colors.grey,
              ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 3.0.wp,
                horizontal: 4.0.wp,
              ),
              child: Divider(thickness: 2,),
            ),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: AdWidget(
                ad: BannerAd(
                  adUnitId: AdmobService.getBannerAdUnitId()!,
                 //adUnitId: "ca-app-pub-3940256099942544/6300978111",
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

            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 3.0.wp,
                horizontal: 5.0.wp,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatus(Colors.green,liveTasks,"Live Tasks"),
                  _buildStatus(Colors.orange, completedTasks, "Completed"),
                  _buildStatus(Colors.blue, createdTasks, "Created"),

                ],
              ),
            ),
            SizedBox(height: 8.0.wp,),
            UnconstrainedBox(
              child:SizedBox(
                width: 70.0.wp,
                height: 70.0.wp,
                child: CircularStepProgressIndicator(
                  totalSteps: createdTasks==0?1:createdTasks,
                  currentStep: completedTasks,
                  stepSize: 20,
                  selectedColor: green,
                  unselectedColor: Colors.grey[200],
                  padding: 0,
                  width: 150,
                  height: 150,
                  selectedStepSize: 22,
                  roundedCap: (_,__)=>true,
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text("${createdTasks==0?0:percent}%",
                     style: TextStyle(
                       fontSize: 20.0.sp,
                       fontWeight: FontWeight.bold
                     ),
                     ),
                     SizedBox(height: 1.0.wp,),
                     Text("Efficiency",
                       style: TextStyle(
                           color: Colors.grey,
                           fontWeight: FontWeight.bold

                       ),
                     ),
                   ],
                 ), 
                ),
              ) ,
            ),
          ],
        );
      }),
    );
  }

  Row _buildStatus(Color color, int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3.0.wp,
          height: 3.0.wp,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 0.5.wp,
              color: color,
            )
          ),
        ),
        SizedBox(width: 3.0.wp,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$number",
            style: TextStyle(
             fontWeight: FontWeight.bold,
              fontSize: 16.0.sp,
            ),
            ),
            SizedBox(height: 2.0.wp,),
            Text(text,
            style: TextStyle(
              fontSize: 12.0.sp,
              color: Colors.grey,
            ),
            )
          ],
        ),
      ],
    );
  }
}
