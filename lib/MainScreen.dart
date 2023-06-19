import 'package:flutter/material.dart';
import 'package:samal/add_project_page.dart';
import 'package:samal/profile.dart';

import 'common_layout.dart';
import 'MyInvests.dart';
import 'home_page.dart';
import 'main.dart';



class MainScreen extends StatefulWidget {
  String userId;
  MainScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;



  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.lightBlue,
              size: 30,
            ),
            label: "Home",
            activeIcon: Icon(
              Icons.home,
              color: Colors.indigo,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.trending_up,
              color: Colors.lightBlue,
              size: 30,
            ),
            label: "Invest",
            activeIcon: Icon(
              Icons.trending_up,
              color: Colors.indigo,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              color: Colors.lightBlue,
              size: 30,
            ),
            label: "Add",
            activeIcon: Icon(
              Icons.add,
              color: Colors.indigo,
              size: 30,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.lightBlue,
              size: 30,
            ),
            label: "Profile",
            activeIcon: Icon(
              Icons.person,
              color: Colors.indigo,
              size: 30,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      body: CommonBottomNavigationBar(
        selectedIndex: _selectedIndex,
        navigatorKeys: _navigatorKeys,
        childrens: [
          HomePage(userId: widget.userId),
          MyInvestmentPage(userId: widget.userId),
          AddPage(),
          ProfilePage(
            exit_button: _exit,
          ),
        ],
      ),

    );
  }

 void _exit() {
   Navigator.push(context, MaterialPageRoute(builder: (context) => AuthenticationPage()));
  }

}