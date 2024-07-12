

import 'package:batchloreskitchen/Pages/wallet.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/details.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  bool Ice=false,pizza=false,burger=false,salad=false;



  @override
  Widget build(BuildContext context) {
    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(top:28.0,left: 10.0,right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hello Karan,",
                    style:AppWidget.boldTextFeildSstyleTop1(),
                  ),


                  Container(

                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.shopping_cart_outlined,color: Colors.white,size: 32.0,),
                  ),
                ],

              ),


              SizedBox(height: 8,),
              Text(
                "Delicious Food",
                style: AppWidget.boldTextFeildSstyle(),

              ),
              Text(
                "Discove and Get Great Food",
                style:AppWidget.boldTextFeildSstylelight(),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/45,),
              showItem(),//Rows of items
              showItem2(),//Text below it
              SizedBox(height: MediaQuery.of(context).size.height/25,),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text("Swipe The Hunger",style:TextStyle(
                    fontFamily:"Poppins",
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    fontSize: 16
                  )),

                  Row(
                    children: [
                      Text("See All",style:TextStyle(
                          fontFamily:"Poppins",
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          fontSize: 16
                      )
                      ),
                      SizedBox(width:4),
                      Icon(Icons.arrow_circle_right_sharp,color: Colors.black54,),
                    ],

                  ),

                ],
              ),
              SizedBox(height:h/200,),
              Container(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(

                    children: [

                      GestureDetector(
                        onTap:() {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Details(),)
                          );
                        },
                        child: Container(

                          margin: EdgeInsets.all(5),
                          child: Material(


                            borderRadius: BorderRadius.circular(25),

                            elevation: 8.0,
                            child: Container(

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    "images/SaladQ.png",
                                    height: 180,
                                    width:190,
                                    fit:BoxFit.cover
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:7),
                                    child: Text("Veggie Taco Hash",style: AppWidget.boldTextFeildSstyleTop(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:7),
                                    child: Text("Fresh and Healthy",style: AppWidget.boldTextFeildSstyleSmall(),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left:10),
                                    child: Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/60,),

                      Container(
                        margin: EdgeInsets.all(5
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),

                          elevation: 8.0,
                          child: Container(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                    "images/Salad1.png",
                                    height: 180,
                                    width:190,
                                    fit:BoxFit.cover
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Hamburger Salad",style: AppWidget.boldTextFeildSstyleTop(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Explore The Test of Sea",style: AppWidget.boldTextFeildSstyleSmall(),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Text("\$40",style: AppWidget.boldTextFeildSstyleTop1(),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/60,),
                      Container(
                        margin: EdgeInsets.all(5
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),

                          elevation: 8.0,
                          child: Container(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                    "images/Salad2.png",
                                    height: 180,
                                    width:190,
                                    fit:BoxFit.cover
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Salad with Pronz",style: AppWidget.boldTextFeildSstyleTop(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Fun of Sea with Green",style: AppWidget.boldTextFeildSstyleSmall(),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Text("\$37",style: AppWidget.boldTextFeildSstyleTop1(),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/60,),
                      Container(
                        margin: EdgeInsets.all(5
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),

                          elevation: 5.0,
                          child: Container(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                    "images/SaladQ2.png"
                                        ,
                                    height: 180,
                                    width:190,
                                    fit:BoxFit.cover
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Green Garden",style: AppWidget.boldTextFeildSstyleTop(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Fun of Sea with Green",style: AppWidget.boldTextFeildSstyleSmall(),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Text("\$20",style: AppWidget.boldTextFeildSstyleTop1(),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width/60,),
                      Container(
                        margin: EdgeInsets.all(5
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),

                          elevation: 5.0,
                          child: Container(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                    "images/SaladQ3.png"
                                        ,
                                    height: 180,
                                    width:190,
                                    fit:BoxFit.cover
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Salad with Chiken",style: AppWidget.boldTextFeildSstyleTop(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:7),
                                  child: Text("Fun of Sea with Green",style: AppWidget.boldTextFeildSstyleSmall(),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left:10),
                                  child: Text("\$55",style: AppWidget.boldTextFeildSstyleTop1(),),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/70),
              Container(
                margin: EdgeInsets.all(5),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(

                    child: Row(
                      children: [
                        Image.asset("images/Salad1.png",height: 120,width: 120,fit: BoxFit.cover,),
                        SizedBox(width: 10.0,),
                        Column(

                          children: [
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Mediterranean chickanpea Salad",style: AppWidget.boldTextFeildSstyleTop(),)),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Honey goot chese",style: AppWidget.boldTextFeildSstyleSmall(),)
                            ),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child:
                                Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),)
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/90),
              Container(
                margin: EdgeInsets.all(5),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(

                    child: Row(
                      children: [
                        Image.asset("images/Salad1.png",height: 120,width: 120,fit: BoxFit.cover,),
                        SizedBox(width: 20.0,),
                        Column(

                          children: [
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Mediterranean chickanpea Salad",style: AppWidget.boldTextFeildSstyleTop(),)),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Honey goot chese",style: AppWidget.boldTextFeildSstyleSmall(),)
                            ),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child:
                                Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),)
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/90),
              Container(
                margin: EdgeInsets.all(5),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(

                    child: Row(
                      children: [
                        Image.asset("images/Salad1.png",height: 120,width: 120,fit: BoxFit.cover,),
                        SizedBox(width: 20.0,),
                        Column(

                          children: [
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Mediterranean chickanpea Salad",style: AppWidget.boldTextFeildSstyleTop(),)),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Honey goot chese",style: AppWidget.boldTextFeildSstyleSmall(),)
                            ),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child:
                                Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),)
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/90),
              Container(
                margin: EdgeInsets.all(5),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(

                    child: Row(
                      children: [
                        Image.asset("images/Salad1.png",height: 120,width: 120,fit: BoxFit.cover,),
                        SizedBox(width: 20.0,),
                        Column(

                          children: [
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Mediterranean chickanpea Salad",style: AppWidget.boldTextFeildSstyleTop(),)),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child: Text("Honey goot chese",style: AppWidget.boldTextFeildSstyleSmall(),)
                            ),
                            Container(
                                width:MediaQuery.of(context).size.width/2,
                                child:
                                Text("\$25",style: AppWidget.boldTextFeildSstyleTop1(),)
                            ),
                          ],
                        ),
                      ],

                    ),
                  ),
                ),
              ),



            ],
          ),

        ),
      ),
    );

  }
  Widget showItem()//images
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              Ice=true;
              pizza=false;
              burger=false;
              salad=false;
              setState(() {

              });


            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Image.asset("images/cream.png",height: 50,width:50,fit: BoxFit.cover,

              ),

            ),
          ),



        ),

        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              Ice=false;
              pizza=true;
              burger=false;
              salad=false;
              setState(() {

              });


            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Image.asset("images/PizzaNew.png",height: 50,width:50,fit: BoxFit.cover,

              ),

            ),
          ),



        ),
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              Ice=false;
              pizza=false;
              burger=false;
              salad=true;
              setState(() {

              });


            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Image.asset("images/SaladTop.png",height: 50,width:50,fit: BoxFit.cover,

              ),


            ),
          ),



        ),
        Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () {
              Ice=false;
              pizza=false;
              burger=true;
              salad=false;
              setState(() {

              });


            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Image.asset("images/Burger1.png",height: 50,width:50,fit: BoxFit.cover,

              ),

            ),
          ),



        ),


      ],
    );

}
Widget showItem2()//Text below images
{
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      Padding(
        padding: const EdgeInsets.only(left: 4,top:5),

        child: Text("Ice Cream",style:Ice?AppWidget.boldTextFeildSstyleSmallDark():AppWidget.boldTextFeildSstyleSmall()),
      ),
      Padding(
        padding: const EdgeInsets.only(right:14,top:5),

        child: Text("Pizza",style:pizza?AppWidget.boldTextFeildSstyleSmallDark():AppWidget.boldTextFeildSstyleSmall()),
      ),
      Padding(
        padding: const EdgeInsets.only(right:12.5,top:5),

        child: Text("Salad",style:salad?AppWidget.boldTextFeildSstyleSmallDark():AppWidget.boldTextFeildSstyleSmall()),
      ),
      Padding(
        padding: const EdgeInsets.only(right:13,top:4),

        child: Text("Burger",style:burger?AppWidget.boldTextFeildSstyleSmallDark():AppWidget.boldTextFeildSstyleSmall()),
      ),
    ],
  );
}
}


