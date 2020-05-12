import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:feedmeinclass/services/business.dart';

class Detail {
  final String address;
  final String name;
  final List<String> photos;

  Detail({this.address, this.name, this.photos});

  factory Detail.fromJson(dynamic json) {
    return Detail(
      address: json["location"]['display_address'][0] +
          "\n" +
          json["location"]['display_address'][1],
      name: json['name'],
      photos: new List<String>.from(json['photos']),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String id;
  DetailScreen({this.id});

  Future<Detail> fetchBusiness() async {
    await DotEnv().load('.env');
    var response = await http.get(
      'https://api.yelp.com/v3/businesses/' + id,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${DotEnv().env['API_KEY']}"
      },
    );
    var business = Detail.fromJson(jsonDecode(response.body));
    //print(business);
    return business;
  }

  @override
  Widget build(BuildContext context) {
    Future<Detail> _futureData = fetchBusiness();
    // var name = business["name"];
    return FutureBuilder<Detail>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("${snapshot.data.name}"),
              ),
              body: Column(
                children: <Widget>[
                  Text(snapshot.data.address),
                  Container(
                    height: 1000,
                    child: ListView.builder(
                        itemCount: snapshot.data.photos.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                              '${snapshot.data.photos[index]}');
                        }),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
