// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:project/detail.dart';
// import 'package:project/home.dart';
// import 'package:project/label.dart';
// import 'spotify_service.dart';
// import 'package:intl/intl.dart';
// import 'bottom_navigation_bar.dart'; // CustomBottomNavigationBar import

// class MusicRecommendationsPage extends StatefulWidget {
//   @override
//   _MusicRecommendationsPageState createState() => _MusicRecommendationsPageState();
// }

// class _MusicRecommendationsPageState extends State<MusicRecommendationsPage> {
//   final SpotifyService _spotifyService = SpotifyService(
//     clientId: '184671c9527840ee951e8adb7bda3195',
//     clientSecret: 'bf3ca7abde1c4361a17882ff6a31c606',
//   );

//   List<Map<String, dynamic>> _recommendations = [];
//   bool _isLoading = true;
//   int _happiness = 0;
//   int _selectedIndex = 3; // Set the selected index for the music recommendations page
//   Set<String> _favoriteTracks = Set<String>(); // Set to keep track of favorite tracks

//   @override
//   void initState() {
//     super.initState();
//     _fetchHappinessAndRecommendations();
//     _loadFavoriteTracks();
//   }

//   Future<void> _fetchHappinessAndRecommendations() async {
//     try {
//       String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
//       var snapshot = await FirebaseFirestore.instance.collection('memo').where('date', isEqualTo: formattedDate).limit(1).get();
//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           _happiness = snapshot.docs.first.get('happiness');
//         });
//       }
//       final recommendations = await _spotifyService.getRecommendationsByHappiness(_happiness);
//       setState(() {
//         _recommendations = recommendations;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print(e); // Handle the error appropriately in your app
//     }
//   }

//   Future<void> _loadFavoriteTracks() async {
//     String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
//     var snapshot = await FirebaseFirestore.instance.collection('memo').where('date', isEqualTo: formattedDate).limit(1).get();

//     if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('music')) {
//       setState(() {
//         _favoriteTracks = Set<String>.from(snapshot.docs.first.get('music').map((track) => track['id']));
//       });
//     }
//   }

//   Future<void> _saveFavoriteTrack(Map<String, dynamic> track) async {
//     String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
//     var collection = FirebaseFirestore.instance.collection('memo');
//     var snapshot = await collection.where('date', isEqualTo: formattedDate).limit(1).get();

//     if (snapshot.docs.isNotEmpty) {
//       await collection.doc(snapshot.docs.first.id).update({
//         'music': FieldValue.arrayUnion([track])
//       });
//     } else {
//       await collection.add({
//         'date': formattedDate,
//         'music': [track],
//       });
//     }

//     setState(() {
//       if (_favoriteTracks.contains(track['id'])) {
//         _favoriteTracks.remove(track['id']);
//       } else {
//         _favoriteTracks.add(track['id']);
//       }
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Saved to favorites')),
//     );
//   }

//   void _onItemTapped(int index) {
//     if (index == _selectedIndex) return;
//     setState(() {
//       _selectedIndex = index;
//     });
//     if (index == 0) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const LabelPage()),
//       );
//     } else if (index == 1) {
//       // Navigate to Home page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } else if (index == 2) {
//       // Navigate to Detail page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => DetailPage()),
//       );
//     } else if (index == 3) {
//       // Current page, do nothing
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Spotify Recommendations'),
//         automaticallyImplyLeading: false, // Remove the back arrow
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _recommendations.length,
//               itemBuilder: (context, index) {
//                 final track = _recommendations[index];
//                 return ListTile(
//                   leading: track['album']['images'].isNotEmpty
//                       ? Image.network(track['album']['images'][0]['url'])
//                       : null,
//                   title: Text(track['name']),
//                   subtitle: Text(track['artists'][0]['name']),
//                   trailing: IconButton(
//                     icon: Icon(
//                       _favoriteTracks.contains(track['id']) ? Icons.star : Icons.star_border,
//                       color: _favoriteTracks.contains(track['id']) ? Colors.pink : null,
//                     ),
//                     onPressed: () => _saveFavoriteTrack(track),
//                   ),
//                 );
//               },
//             ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/detail.dart';
import 'package:project/home.dart';
import 'package:project/label.dart';
import 'spotify_service.dart';
import 'package:intl/intl.dart';
import 'bottom_navigation_bar.dart'; // CustomBottomNavigationBar import

class MusicRecommendationsPage extends StatefulWidget {
  @override
  _MusicRecommendationsPageState createState() => _MusicRecommendationsPageState();
}

class _MusicRecommendationsPageState extends State<MusicRecommendationsPage> {
  final SpotifyService _spotifyService = SpotifyService(
    clientId: '184671c9527840ee951e8adb7bda3195',
    clientSecret: 'bf3ca7abde1c4361a17882ff6a31c606',
  );

  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;
  int _happiness = 0;
  int _selectedIndex = 3; // Set the selected index for the music recommendations page
  Set<String> _favoriteTracks = Set<String>(); // Set to keep track of favorite tracks

  @override
  void initState() {
    super.initState();
    _fetchHappinessAndRecommendations();
    _loadFavoriteTracks();
  }

  Future<void> _fetchHappinessAndRecommendations() async {
    try {
      String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
      var snapshot = await FirebaseFirestore.instance.collection('memo').where('date', isEqualTo: formattedDate).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _happiness = snapshot.docs.first.get('happiness');
        });
      }
      final recommendations = await _spotifyService.getRecommendationsByHappiness(_happiness);
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  Future<void> _loadFavoriteTracks() async {
    String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
    var snapshot = await FirebaseFirestore.instance.collection('favmusic').where('date', isEqualTo: formattedDate).limit(1).get();

    if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('music')) {
      setState(() {
        _favoriteTracks = Set<String>.from(snapshot.docs.first.get('music').map((track) => track['id']));
      });
    }
  }

  Future<void> _saveFavoriteTrack(Map<String, dynamic> track) async {
    String formattedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
    var memoCollection = FirebaseFirestore.instance.collection('memo');
    var favMusicCollection = FirebaseFirestore.instance.collection('favmusic');
    var memoSnapshot = await memoCollection.where('date', isEqualTo: formattedDate).limit(1).get();
    var favMusicSnapshot = await favMusicCollection.where('date', isEqualTo: formattedDate).limit(1).get();

    if (memoSnapshot.docs.isNotEmpty) {
      await memoCollection.doc(memoSnapshot.docs.first.id).update({
        'music': FieldValue.arrayUnion([track])
      });
    } else {
      await memoCollection.add({
        'date': formattedDate,
        'music': [track],
      });
    }

    if (favMusicSnapshot.docs.isNotEmpty) {
      await favMusicCollection.doc(favMusicSnapshot.docs.first.id).update({
        'music': FieldValue.arrayUnion([track])
      });
    } else {
      await favMusicCollection.add({
        'date': formattedDate,
        'music': [track],
      });
    }

    setState(() {
      if (_favoriteTracks.contains(track['id'])) {
        _favoriteTracks.remove(track['id']);
      } else {
        _favoriteTracks.add(track['id']);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved to favorites')),
    );
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage()),
      );
    } else if (index == 3) {
      // Current page, do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Recommendations'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final track = _recommendations[index];
                return ListTile(
                  leading: track['album']['images'].isNotEmpty
                      ? Image.network(track['album']['images'][0]['url'])
                      : null,
                  title: Text(track['name']),
                  subtitle: Text(track['artists'][0]['name']),
                  trailing: IconButton(
                    icon: Icon(
                      _favoriteTracks.contains(track['id']) ? Icons.favorite : Icons.favorite_border,
                      color: _favoriteTracks.contains(track['id']) ? Colors.pink : null,
                    ),
                    onPressed: () => _saveFavoriteTrack(track),
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
