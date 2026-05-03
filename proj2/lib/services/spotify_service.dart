import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = "929d70712661468d80b623586cb9363e";
  final String clientSecret = "661414e0a27e45a98e52d257aad6df46";

  String? _accessToken;

  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization":
            "Basic ${base64Encode(utf8.encode("$clientId:$clientSecret"))}",
      },
      body: {"grant_type": "client_credentials"},
    );

    final data = jsonDecode(response.body);
    _accessToken = data["access_token"];
  }

  Future<List<Map<String, String>>> searchSongs(String query) async {
    if (_accessToken == null) {
      await authenticate();
    }

    final response = await http.get(
      Uri.parse(
        "https://api.spotify.com/v1/search?q=$query&type=track&limit=10",
      ),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    final data = jsonDecode(response.body);

    final tracks = data["tracks"]["items"];

    return tracks.map<Map<String, String>>((track) {
      return {"title": track["name"], "artist": track["artists"][0]["name"]};
    }).toList();
  }
}
