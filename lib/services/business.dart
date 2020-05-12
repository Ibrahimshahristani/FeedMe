import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:feedmeinclass/services/location.dart';

class Business {
  final String id;
  final String name;
  final String image_url;

  Business({this.id, this.name, this.image_url});

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      image_url: json['image_url'],
    );
  }
}

Future<List<Business>> fetchBusinessList() async {
  await DotEnv().load('.env');
  Location location = Location();
  await location.getLocation();
  print("Location: ${location.latitude} :  ${location.longitude}");
  var response = await http.get(
    'https://api.yelp.com/v3/businesses/search' +
        "?&latitude=${location.latitude}&longitude=${location.longitude}",
    headers: {
      HttpHeaders.authorizationHeader: "Bearer ${DotEnv().env['API_KEY']}"
    },
  );
  // print(json.decode(response.body));
  Iterable decodeData = jsonDecode(response.body)["businesses"];
  List<Business> businesses = decodeData
      .map((businessJson) => Business.fromJson(businessJson))
      .toList();
  //print("${businesses}");
  return businesses;
}
