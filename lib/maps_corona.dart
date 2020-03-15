import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:coronatracker/models/results.dart';
import 'package:coronatracker/widgets/active_cases.dart';
import 'package:coronatracker/widgets/new_deaths.dart';
import 'package:coronatracker/widgets/serious_critical.dart';
import 'package:coronatracker/widgets/total_cases.dart';
import 'package:coronatracker/widgets/total_deaths.dart';
import 'package:coronatracker/widgets/total_recovered.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class MapsCorona extends StatefulWidget {
  final List<Placemark> placemarks;
  final List<Country> country;

  MapsCorona({this.placemarks, this.country});

  @override
  _MapsCoronaState createState() => _MapsCoronaState();
}

class _MapsCoronaState extends State<MapsCorona> {
  LatLng initialPos = LatLng(12, 121);
  bool didTap = false;
  bool loading = false;
  Placemark initialPm = Placemark();
  MapController controller = MapController();
  Country initialCountry;
  List<Marker> markerList = [];
  List<MapsData> mapData;

  Future getMapData() async {
    print('getting data');
    http.Client client = http.Client();
    http.Response response = await client
        .get('https://coronavirus-tracker-api.herokuapp.com/confirmed');
    var body = jsonDecode(response.body);
    List<String> jsonCountry = [];
    print('data received; LENGTH: ${body['locations'].length}');
    for (int i = 0; i < body['locations'].length; i++) {
      for (int x = 0; x < widget.country.length; x++) {
        if (body['locations'][i]['country'] == widget.country[x].countryName) {
          var dt = body['locations'][i]['country'];
          jsonCountry.add(dt);
        }
      }
      //print(body['locations'][i]['coordinates']['lat']);
    }
    List<String> strJson = jsonCountry.toSet().toList();

    print(body['locations'].indexOf(body['locations'][0]['country']));
    print(strJson.length);
  }

  getMarkers(Country country) {
    widget.placemarks.forEach((placemark) {
      if (placemark.country.contains(country.countryName)) {
        markerList.add(
          Marker(
            point: LatLng(
              placemark.position.latitude,
              placemark.position.longitude,
            ),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    didTap = true;
                    initialPm = placemark;
                    initialCountry = country;
                    initialPos = LatLng(
                      placemark.position.latitude,
                      placemark.position.longitude,
                    );
                    controller.move(
                        LatLng(
                          placemark.position.latitude,
                          placemark.position.longitude,
                        ),
                        4.0);
                  });
                },
                child: Icon(
                  Icons.location_on,
                  color:
                      int.parse(country.info.totalCases.replaceAll(',', '')) >=
                              10
                          ? Colors.redAccent[100]
                          : Colors.greenAccent[100],
                  size: 40.0,
                ),
              );
            },
          ),
        );
      }
    });
  }

  loadData() {
    // Timer.run(() {
    //   setState(() {
    //     loading = true;
    //   });
    // });
    widget.country.forEach((ctry) {
      getMarkers(ctry);
    });
    Future<MapController> mc = controller.onReady;
    mc.whenComplete(() {
      print('complete');
      setState(() {
        loading = false;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    print(controller.ready);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('reload');
              getMapData();
            },
          )
        ],
        centerTitle: true,
        backgroundColor: Color(0xff102044),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Cases: ${widget.country.length}',
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
            Text(
              'Markers: ${widget.placemarks.length}',
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
            Text(
              'Takes a while to load the markers',
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Color(0xff343332),
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          FlutterMap(
                            mapController: controller,
                            key: Key('maps'),
                            options: new MapOptions(
                                center: initialPos,
                                zoom: 1.5,
                                minZoom: 1.5,
                                interactive: true,
                                debug: true,
                                onPositionChanged: (pos, b) {
                                  setState(() {
                                    initialPos = pos.center;
                                  });
                                }),
                            layers: [
                              TileLayerOptions(
                                backgroundColor: Color(0xff191a1a),
                                urlTemplate:
                                    'https://tile.jawg.io/dark/{z}/{x}/{y}.png?api-key=community',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayerOptions(
                                markers: markerList,
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 5.0,
                                bottom: 5.0,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.my_location,
                                  size: 30.0,
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  setState(() {
                                    controller.move(initialPos, 2);
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      color: Color(0xff000D29),
                      child: !didTap
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                                Text(
                                  'Tap on a marker',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.0,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                      ),
                                      Text(
                                        '${initialCountry.countryName}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    TotalCases(
                                      data: initialCountry.info.totalCases,
                                      dataSize: 20,
                                      type: 'Total Cases',
                                      isMaps: true,
                                      textSize: 12,
                                    ),
                                    TotalRecovered(
                                      data: initialCountry.info.totalRecovered,
                                      dataSize: 20,
                                      type: 'Total Recovered',
                                      textSize: 12,
                                    ),
                                    ActiveCases(
                                      data: initialCountry.info.activeCases,
                                      dataSize: 20,
                                      type: 'Active',
                                      textSize: 12,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    ActiveCases(
                                      data: initialCountry.info.newDeaths,
                                      type: 'New Deaths',
                                      dataSize: 20,
                                      textSize: 12,
                                    ),
                                    TotalDeaths(
                                      data: initialCountry.info.totalDeaths,
                                      type: 'Total Deaths',
                                      dataSize: 20,
                                      textSize: 12,
                                      isMaps: true,
                                    ),
                                    ActiveCases(
                                      data: initialCountry.info.seriousCritical,
                                      type: 'Serious',
                                      dataSize: 20,
                                      textSize: 12,
                                    )
                                  ],
                                ),
                              ],
                            ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class TextContainer extends StatelessWidget {
  final String data;
  final String title;
  final double dataSize;
  final double titleSize;

  TextContainer({
    this.data,
    this.title,
    this.dataSize,
    this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
          vertical: 5.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xff131C2F),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              color: Colors.black54,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: dataSize,
              ),
            ),
            Text(
              '$title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: titleSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapsData {
  final Country country;
  final String lat;
  final String long;

  MapsData({
    this.country,
    this.lat,
    this.long,
  });

  factory MapsData.fromJson(Map<String, dynamic> json) {
    return MapsData(
      country: json['country'],
      lat: json['lat'],
      long: json['long'],
    );
  }
}
