import 'package:batchloreskitchen/Onboard/pages.dart';
import 'package:batchloreskitchen/Onboard/spalsh.dart';
import 'package:batchloreskitchen/Pages/NavigationBar.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class View1 extends StatefulWidget {
  const View1({super.key});

  @override
  State<View1> createState() => _View1State();
}

class _View1State extends State<View1> {
  final controller=PageController();
  bool isLastPage = false;
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String s= "images/VerityFood.json";
    String s2="images/QualityFood.json";
    String s3="images/Animation3.json";
    
    return Scaffold(
      body: Container(
        height: 735.h,
        child: PageView(
          onPageChanged: (index) {
            setState(() {
              isLastPage = index ==2;
            });
          },
          controller: controller,
          children: [
          page(s,"Delivery in 30 min" ,"Get all your loved foods in once place to eat","just by placing an order.",Colors.red.withOpacity(0.1)),
            page(s2,"Delivery in 30 min" ,"Get all your loved foods in once place to eat","just by placing an order.",Colors.green.withOpacity(0.1)),
            page(s3,"All Your Favorites","Variety of food avilable here only for You","Give your toungh new test.",Colors.blue.withOpacity(0.1)),
          ],
        ),
      ),


      //Bootom Part
      bottomSheet: isLastPage?
      TextButton(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            backgroundColor: Colors.white,
            minimumSize: const Size.fromHeight(85)
          ),
          onPressed:() {
            Container(
              child: Lottie.asset("images/Loading.json"),
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context) => SplashScreen(),));

          },
          child: Text("Get Started",style: AppWidget.boldTextFeildSstyleTop1(),)
      ):
      
      Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        height: 80.h,

        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:  EdgeInsets.only(left: 20.w),
              child: TextButton(
                onPressed: () {
                  controller.animateToPage(2, duration:Duration(milliseconds: 200), curve:Easing.legacyAccelerate);
              },
                  style: ButtonStyle(


                  ),
                  child: Text("Skip",style: AppWidget.boldTextFeildSstyleTop1(),),

              ),
            ),
            Center(
              child:SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect:JumpingDotEffect(
                  activeDotColor:Colors.deepOrangeAccent,
                  dotHeight: 15.h,
                  radius:80,
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(right: 20.w),
              child: TextButton(
                onPressed: () {
                  controller.nextPage(duration: Duration(milliseconds:400), curve: Curves.easeInOutQuad);

                },
                style: ButtonStyle(


                ),
                child: Text("Next",style: AppWidget.boldTextFeildSstyleTop1(),),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
