import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/detail.dart';
import 'package:project/logo.dart';
import 'bottom_navigation_bar.dart';
import 'label.dart';
import 'home.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Profile 페이지의 인덱스를 기본값으로 설정

  // void _onItemTapped(int index) {
  //   if (index == _selectedIndex) return;
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   if (index == 0) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const LabelPage()),
  //     );
  //   } else if (index == 1) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomeScreen()),
  //     );
  //   } else if (index == 2) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => DetailPage()),
  //     );
  //   } else if (index == 3) {
  //     // 현재 페이지이므로 아무 작업도 하지 않음
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center 정렬 추가
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null 
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null 
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
              SizedBox(height: 16),
              Text(
                user?.displayName ?? 'No display name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                user?.email ?? 'No email',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogoPage()),
                  );
                },
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
    );
  }
}
