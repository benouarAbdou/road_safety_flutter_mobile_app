import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int?> getSpeedLimit(double lat, double lon) async {
  final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];way(around:10,$lat,$lon)["maxspeed"];out;');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['elements'].isNotEmpty) {
      // Extract speed limit from first matched road
      String maxSpeed = data['elements'][0]['tags']['maxspeed'];
      return int.tryParse(maxSpeed.replaceAll(RegExp(r'[^0-9]'), ''));
    }
  }
  return null; // No speed limit found
}
