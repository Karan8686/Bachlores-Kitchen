import 'package:batchloreskitchen/Pages/cart.dart';
import 'package:batchloreskitchen/Pages/wallet.dart';
import 'package:batchloreskitchen/widgets/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:batchloreskitchen/Pages/details.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Constants for reusable values
const double kDefaultPadding = 8.0;
const double kDefaultMargin = 5.0;
const double kCardElevation = 8.0;
const double kImageSize = 50.0;
const double kBorderRadius = 20.0;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // State variables for food category selection
  bool ice = false;
  bool pizza = false;
  bool burger = false;
  bool salad = false;

  // Food item data structure
  final List<Map<String, dynamic>> _foodCategories = [
    {'name': 'Ice Cream', 'image': 'images/cream.png', 'isSelected': false},
    {'name': 'Pizza', 'image': 'images/PizzaNew.png', 'isSelected': false},
    {'name': 'Salad', 'image': 'images/SaladTop.png', 'isSelected': false},
    {'name': 'Burger', 'image': 'images/Burger1.png', 'isSelected': false},
  ];

  void _handleScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()), // Your payment page
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.only(top: 28.0, left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(() => _handleScreen(context)),
              const SizedBox(height: kDefaultPadding),
              _buildWelcomeText(),
              SizedBox(height: MediaQuery.of(context).size.height / 45),
              showItem(),
              showItem2(),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              _buildSectionHeader(),
              SizedBox(height: 4.h),

              Columm(),

              SizedBox(height: MediaQuery.of(context).size.height / 70),
              RoW(),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the app header with cart icon
  Widget _buildHeader(VoidCallback onTap) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hello Karan,",
            style: AppWidget.boldTextFeildSstyleTop1(),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 32.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds welcome text section
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delicious Food",
          style: AppWidget.boldTextFeildSstyle(),
        ),
        Text(
          "Discover and Get Great Food",
          style: AppWidget.boldTextFeildSstylelight(),
        ),
      ],
    );
  }

  // Builds section header with "See All" button
  Widget _buildSectionHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Swipe The Hunger",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        Row(
          children: const [
            Text(
              "See All",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_circle_right_sharp, color: Colors.black54),
          ],
        ),
      ],
    );
  }

  // Builds food category icons
  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _foodCategories.map((category) {
        return _buildCategoryItem(
          image: category['image'],
          onTap: () => _handleCategorySelection(category['name']),
        );
      }).toList(),
    );
  }

  // Builds individual category item
  Widget _buildCategoryItem({required String image, required VoidCallback onTap}) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(kBorderRadius),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Image.asset(
            image,
            height: kImageSize,
            width: kImageSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Handles category selection logic
  void _handleCategorySelection(String categoryName) {
    setState(() {
      ice = categoryName == 'Ice Cream';
      pizza = categoryName == 'Pizza';
      burger = categoryName == 'Burger';
      salad = categoryName == 'Salad';
    });
  }

  // Builds food category labels
  Widget showItem2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryLabel("Ice Cream", ice, left: 4),
        _buildCategoryLabel("Pizza", pizza, right: 14),
        _buildCategoryLabel("Salad", salad, right: 12.5),
        _buildCategoryLabel("Burger", burger, right: 13),
      ],
    );
  }

  // Builds individual category label
  Widget _buildCategoryLabel(String text, bool isSelected, {double left = 0, double right = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: left, right: right, top: 5),
      child: Text(
        text,
        style: isSelected
            ? AppWidget.boldTextFeildSstyleSmallDark()
            : AppWidget.boldTextFeildSstyleSmall(),
      ),
    );
  }

  // Builds horizontal scrolling food items
  Widget Columm() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFoodCard(
            image: "images/SaladQ.png",
            title: "Veggie Taco Hash",
            subtitle: "Fresh and Healthy",
            price: "\$25",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>   Details()),
            ),

          ),
          _buildFoodCard(
            image: "images/SaladQ.png",
            title: "Veggie Taco Hash",
            subtitle: "Fresh and Healthy",
            price: "\$25",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  Details()),
            ),

          ),

          // Add more food cards here...
        ],
      ),
    );
  }

  // Builds individual food card
  Widget _buildFoodCard({
    required String image,
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(kDefaultMargin),
        child: Material(
          borderRadius: BorderRadius.circular(25),
          elevation: kCardElevation,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  image,
                  height: 180,
                  width: 190,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Text(
                    title,
                    style: AppWidget.boldTextFeildSstyleTop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: Text(
                    subtitle,
                    style: AppWidget.boldTextFeildSstyleSmall(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    price,
                    style: AppWidget.boldTextFeildSstyleTop1(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds vertical scrolling food items
  Widget RoW() {
    return Column(
      children: List.generate(
        4,
            (index) => _buildVerticalFoodCard(
          image: "images/Salad1.png",
          title: "Mediterranean chickenpea Salad",
          subtitle: "Honey goat cheese",
          price: "\$25",
        ),
      ),
    );
  }

  // Builds individual vertical food card
  Widget _buildVerticalFoodCard({
    required String image,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Container(
      margin: const EdgeInsets.all(kDefaultMargin),
      child: Material(
        elevation: kCardElevation,
        borderRadius: BorderRadius.circular(kBorderRadius),
        child: Container(
          child: Row(
            children: [
              Image.asset(
                image,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 20.0),
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      title,
                      style: AppWidget.boldTextFeildSstyleTop(),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      subtitle,
                      style: AppWidget.boldTextFeildSstyleSmall(),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text(
                      price,
                      style: AppWidget.boldTextFeildSstyleTop1(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}