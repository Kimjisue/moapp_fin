import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project/music_recommendations_page.dart';
import 'bottom_navigation_bar.dart'; // BottomNavigationBar 파일을 가져옴
import 'label.dart';
import 'home.dart';
import 'profile.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<Map<String, dynamic>>> _futureData;
  DateTime _selectedMonth = DateTime.now();
  int _selectedIndex = 2; // DetailPage의 인덱스를 기본값으로 설정

  @override
  void initState() {
    super.initState();
    _futureData = _fetchData();
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('memo').get();
    List<Map<String, dynamic>> data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    data.sort((a, b) {
      DateTime dateA = DateFormat('yyyy.MM.dd').parse(a['date']);
      DateTime dateB = DateFormat('yyyy.MM.dd').parse(b['date']);
      return dateA.compareTo(dateB);
    });
    return data;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LabelPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 2) {
      // 현재 페이지이므로 아무 작업도 하지 않음
    } else if (index == 3) {
      // Settings 페이지로 이동하는 코드
     Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicRecommendationsPage()),
      );
    }
  }

  String _getMonthYear(DateTime date) {
    return DateFormat('yyyy년 MM월').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //title: Text('Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _getMonthYear(_selectedMonth),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> entry = snapshot.data![index];
                      DateTime date = DateFormat('yyyy.MM.dd').parse(entry['date']);
                      String formattedDate = DateFormat('yyyy년 MM월 dd일 EEE').format(date);
                      String day = DateFormat('EEE').format(date);
                      String dayAndDate = DateFormat('dd').format(date);
                      int happiness = entry['happiness'] ?? 0;
                      String content = entry['content'] ?? '';

                      return Card(
                        margin: EdgeInsets.all(12), // 카드 여백 조정
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // 카드 내부 패딩 추가
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day,
                                    style: TextStyle(fontSize: 12,),
                                  ),
                                  Text(
                                    dayAndDate,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(width: 30), // 컬럼 사이의 간격 추가
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      content,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 8,),
                                  ],
                                ),
                              ),
                              SizedBox(width: 30),
                              CircularPercentIndicator(
                                radius: 40.0, // CircularPercentIndicator의 크기 조정
                                lineWidth: 5.0,
                                percent: happiness / 100,
                                center: Text('$happiness%'),
                                progressColor: Colors.pink,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
