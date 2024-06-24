import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project/detail.dart';
import 'package:project/home.dart';
import 'package:project/music_recommendations_page.dart';
import 'package:project/profile.dart';
import 'bottom_navigation_bar.dart'; // CustomBottomNavigationBar를 가져옵니다

class LabelPage extends StatefulWidget {
  const LabelPage({super.key});

  @override
  _LabelPageState createState() => _LabelPageState();
}

class _LabelPageState extends State<LabelPage> {
  List<double> happinessData = [0, 0, 0, 0, 0, 0, 0]; // 초기 데이터
  List<Map<String, dynamic>> favoriteMusic = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Firestore에서 데이터를 가져옴
    _fetchFavoriteMusic(); // Firestore에서 즐겨찾기 음악 데이터를 가져옴
  }

  Future<void> _fetchData() async {
    List<double> data = [0, 0, 0, 0, 0, 0, 0];
    try {
      var snapshot = await FirebaseFirestore.instance.collection('memo').get();
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().containsKey('happiness') && doc.data().containsKey('date')) {
          DateTime date = DateFormat('yyyy.MM.dd').parse(doc['date']);
          int dayOfWeek = date.weekday - 1; // 0 = Monday, 6 = Sunday
          double happiness = doc['happiness']?.toDouble() ?? 0.0;
          data[dayOfWeek] = happiness;
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    setState(() {
      happinessData = data;
    });
  }

  Future<void> _fetchFavoriteMusic() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('memo').get();
      List<Map<String, dynamic>> music = [];
      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().containsKey('music')) {
          List<dynamic> musicList = doc['music'];
          for (var track in musicList) {
            music.add(track as Map<String, dynamic>);
          }
        }
      }
      setState(() {
        favoriteMusic = music;
      });
    } catch (e) {
      print("Error fetching favorite music: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage()),
      );
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicRecommendationsPage()),
      );
    }
    // 네비게이션 바에서 다른 페이지로 이동할 때 처리하는 로직을 추가할 수 있습니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        //title: const Text("Label Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //SizedBox(height: 30), // 차트 위에 여백 추가
            Text(
              'Weekly Happiness Graph',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // 차트와 텍스트 사이에 여백 추가
            SizedBox(
              height: 300, // 차트의 높이를 줄입니다
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toString(),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32, // x축 타이틀을 위한 공간 확보
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 0:
                                text = 'Mon';
                                break;
                              case 1:
                                text = 'Tue';
                                break;
                              case 2:
                                text = 'Wed';
                                break;
                              case 3:
                                text = 'Thu';
                                break;
                              case 4:
                                text = 'Fri';
                                break;
                              case 5:
                                text = 'Sat';
                                break;
                              case 6:
                                text = 'Sun';
                                break;
                              default:
                                text = '';
                                break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 16,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // y축 타이틀을 위한 공간 확보
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(value.toInt().toString(), style: style),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                        left: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    barGroups: happinessData
                        .asMap()
                        .entries
                        .map(
                          (entry) => BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                gradient: LinearGradient( // Gradient 색상 적용
                                  colors: [Colors.pink, Colors.black],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 22,
                                borderRadius: BorderRadius.circular(8), // 코너 반경 설정
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 100,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.black.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30), // 차트와 즐겨찾기 음악 목록 사이에 여백 추가
            if (favoriteMusic.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Music:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...favoriteMusic.map((track) {
                      final albumImages = track['album'] != null && track['album']['images'] != null ? track['album']['images'] : [];
                      return ListTile(
                        leading: albumImages.isNotEmpty
                            ? Image.network(albumImages[0]['url'])
                            : null,
                        title: Text(track['name'] ?? 'Unknown Track'),
                        subtitle: Text(track['artists'] != null && track['artists'].isNotEmpty ? track['artists'][0]['name'] ?? 'Unknown Artist' : 'Unknown Artist'),
                        //onTap: () => _launchURL(track['external_urls']['spotify']),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped, 
),
    );
  }
}