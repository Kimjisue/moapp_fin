import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId;
  final String clientSecret;

  String? _accessToken;

  SpotifyService({required this.clientId, required this.clientSecret});

  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      _accessToken = body['access_token'];
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendationsByHappiness(int happiness) async {
    if (_accessToken == null) {
      await authenticate();
    }

    String genre;
    String targetValence;
    String targetEnergy;

    // 행복도에 따라 장르 및 분위기 설정
    if (happiness > 70) {
      genre = 'pop';
      targetValence = '0.8'; // 밝은 음악
      targetEnergy = '0.7'; // 에너지가 높은 음악
    } else if (happiness > 40) {
      genre = 'rock';
      targetValence = '0.5'; // 중간 밝기
      targetEnergy = '0.5'; // 중간 에너지
    } else {
      genre = 'classical';
      targetValence = '0.3'; // 어두운 음악
      targetEnergy = '0.2'; // 에너지가 낮은 음악
    }

    final queryParameters = {
      'limit': '10',
      'market': 'US',
      'seed_genres': genre,
      'target_valence': targetValence,
      'target_energy': targetEnergy,
    };

    final uri = Uri.https('api.spotify.com', '/v1/recommendations', queryParameters);

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $_accessToken',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['tracks']);
    } else {
      throw Exception('Failed to fetch recommendations from Spotify');
    }
  }
}
