import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment_outlined),
          label: 'Label',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_sharp),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feed_rounded),
          label: 'Detail',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'music',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.pink,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
