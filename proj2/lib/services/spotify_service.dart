import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  // Spotify API credentials
  final String clientId = "929d70712661468d80b623586cb9363e";
  final String clientSecret = "661414e0a27e45a98e52d257aad6df46";

  String? _accessToken;

  // This method authenticates with the Spotify API using the Client Credentials flow and retrieves an access token,
  //which is stored for subsequent API requests.
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

  // This method searches for songs on Spotify based on a query string and returns a list of song titles and artists.
  Future<List<Map<String, String>>> searchSongs(String query) async {
    if (_accessToken == null) {
      await authenticate();
    }
    // The method makes a GET request to the Spotify Search API endpoint, passing the query and access token in the headers.
    final response = await http.get(
      Uri.parse(
        "https://api.spotify.com/v1/search?q=$query&type=track&limit=10",
      ),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    final data = jsonDecode(response.body);

    final tracks = data["tracks"]["items"];
    // The response is processed to extract the song titles and artists, which are returned as a list.
    return List<Map<String, String>>.from(
      tracks.map((track) {
        return {
          "title": track["name"].toString(),
          "artist": track["artists"][0]["name"].toString(),
        };
      }),
    );
  }
}
