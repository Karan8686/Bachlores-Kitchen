import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return FoodScreen();
  }
}
class FoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.send),
        title: Text('Malad East'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for "Pizza"',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            height: 200,
            child: PageView(
              children: [
                Container(
                  color: Colors.orange[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FOODIE\nWeekend',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Flat ₹300 OFF\non delights!',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('ORDER NOW'),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.purple[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Flat ₹500 OFF\non your first order!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Use code: FIRST500',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('GET STARTED'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.fastfood),
                  title: Text('Pizza'),
                  subtitle: Text('Delicious cheese pizza'),
                  trailing: Text('₹499'),
                ),
                ListTile(
                  leading: Icon(Icons.fastfood),
                  title: Text('Burger'),
                  subtitle: Text('Juicy beef burger'),
                  trailing: Text('₹299'),
                ),
                ListTile(
                  leading: Icon(Icons.fastfood),
                  title: Text('Pasta'),
                  subtitle: Text('Creamy Alfredo pasta'),
                  trailing: Text('₹399'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
