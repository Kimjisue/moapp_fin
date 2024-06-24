import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project/detail.dart';
import 'package:project/label.dart';
import 'package:project/logo.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AddPage.dart'; // Ensure this import points to your AddPage location
import 'bottom_navigation_bar.dart';
import 'profile.dart';
import 'music_recommendations_page.dart'; // MusicRecommendationsPage import 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default index for the calendar view
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _formattedDate;
  String? _selectedContent;
  int _happiness = 0; // 행복도 초기값
  Map<DateTime, List<String>> _events = {};
  List<Map<String, dynamic>> _favoriteMusic = []; // 추가된 변수

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    var snapshot = await FirebaseFirestore.instance.collection('memo').get();
    Map<DateTime, List<String>> events = {};
    for (var doc in snapshot.docs) {
      DateTime date = DateFormat('yyyy.MM.dd').parse(doc['date']);
      String content = doc['content'];
      if (events.containsKey(date)) {
        events[date]!.add(content);
      } else {
        events[date] = [content];
      }
    }
    setState(() {
      _events = events;
    });
  }

  Future<void> _loadFavoriteMusic() async {
    String formattedDate = DateFormat('yyyy.MM.dd').format(_selectedDay);
    var snapshot = await FirebaseFirestore.instance.collection('memo').where('date', isEqualTo: formattedDate).limit(1).get();

    if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('music')) {
      setState(() {
        _favoriteMusic = List<Map<String, dynamic>>.from(snapshot.docs.first.get('music'));
      });
    } else {
      setState(() {
        _favoriteMusic = [];
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LabelPage()),
      );
    } else if (index == 1) {
      // Current page, do nothing
    } else if (index == 2) {
      // Navigate to Detail page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage()),
      );
    } else if (index == 3) {
      // Navigate to Music Recommendations page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicRecommendationsPage()),
      );
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _formattedDate = DateFormat('yyyy.MM.dd').format(selectedDay);
    });

    var collection = FirebaseFirestore.instance.collection('memo');
    var snapshot = await collection.where('date', isEqualTo: _formattedDate).limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _selectedContent = snapshot.docs.first.get('content');
        _happiness = snapshot.docs.first.get('happiness'); // 행복도 불러오기
      });
      _loadFavoriteMusic(); // 음악 정보 불러오기
    } else {
      setState(() {
        _selectedContent = 'No events found for $_formattedDate';
        _happiness = 0; // 행복도 초기화
        _favoriteMusic = []; // 음악 정보 초기화
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPage(date: selectedDay),
        ),
      ).then((_) => _loadEvents());
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Text('Home'),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: _onDaySelected,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (_events.containsKey(date)) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 15.0, color: Colors.pink),
                headerPadding: EdgeInsets.symmetric(vertical: 4.0),
                leftChevronIcon: Icon(Icons.arrow_left, size: 40.0, color: Colors.pink),
                rightChevronIcon: Icon(Icons.arrow_right, size: 40.0, color: Colors.pink),
              ),
            ),
            const SizedBox(height: 8.0),
            if (_formattedDate != null && _selectedContent != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$_formattedDate'),
                        SizedBox(height: 8),
                        Text(
                          'Happiness Level',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _happiness / 100,
                          backgroundColor: Colors.grey[300],
                          color: Colors.pink,
                        ),
                        SizedBox(height: 4),
                        Text('$_happiness%'),
                        SizedBox(height: 16),
                        Text(_selectedContent!),
                        SizedBox(height: 16),
                        if (_favoriteMusic.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Favorite Music:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ..._favoriteMusic.map((track) {
                                return ListTile(
                                  leading: track['album']['images'].isNotEmpty
                                      ? Image.network(track['album']['images'][0]['url'])
                                      : null,
                                  title: Text(track['name']),
                                  subtitle: Text(track['artists'][0]['name']),
                                  //onTap: () => _launchURL(track['external_urls']['spotify']),
                                );
                              }).toList(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPage(date: _selectedDay)),
          ).then((_) => _loadEvents());
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
