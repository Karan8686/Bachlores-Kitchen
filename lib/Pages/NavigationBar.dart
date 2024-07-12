import 'package:batchloreskitchen/Pages/wallet.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/Home.dart';
import 'package:batchloreskitchen/Pages/wallet.dart';
import 'package:batchloreskitchen/Pages/order.dart';
import 'package:batchloreskitchen/Pages/profile.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentTabIndex=0;
  late List<Widget>pages;
  late  Widget currentPage;
  late Home homepage;
  late Order order;
  late Profile profile;
  late Wallet wallet;


  @override
  void  initState()
  {
    homepage=Home();
    order=Order();

    profile=Profile();
    wallet=Wallet();

    pages=[homepage,order,wallet,profile];
    super.initState();
  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:CurvedNavigationBar(
        height: 52,
        backgroundColor: Colors.transparent,


        color: Colors.black,
        animationDuration: Duration(milliseconds: 400),
        onTap: (int index)
        {
          setState(() {
            currentTabIndex=index;
          });
        },
        items: [Icon(Icons.home_outlined,color: Colors.white,),
          Icon(Icons.shopping_bag_outlined,color:Colors.white),
          Icon(Icons.wallet_outlined,color:Colors.white),
          Icon(Icons.person_outlined,color:Colors.white)
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
