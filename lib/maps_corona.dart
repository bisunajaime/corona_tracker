import 'dart:async';
import 'dart:convert';
import 'package:coronatracker/models/results.dart';
import 'package:coronatracker/widgets/active_cases.dart';
import 'package:coronatracker/widgets/total_cases.dart';
import 'package:coronatracker/widgets/total_deaths.dart';
import 'package:coronatracker/widgets/total_recovered.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;

class MapsCorona extends StatefulWidget {
  final List<Placemark> placemarks;
  final List<Country> country;
  final List<Marker> markers;

  MapsCorona({this.placemarks, this.country, this.markers});

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
  List<LocationData> locData = [];

  int length = 0;

  Future getMapData() async {
    setState(() {
      loading = true;
    });
    print('getting data');
    http.Client client = http.Client();
    http.Response response = await client
        .get('https://coronavirus-tracker-api.herokuapp.com/confirmed');
    var body = jsonDecode(response.body);

    // loop through URL LOCATIONS ARRAY
    var urlLocArr = body['locations'];

    for (int i = 0; i < urlLocArr.length; i++) {
      Map<String, dynamic> data = {
        'country': urlLocArr[i]['country'],
        'lat': urlLocArr[i]['coordinates']['lat'],
        'long': urlLocArr[i]['coordinates']['long'],
      };

      locData.add(LocationData.fromJson(data));
    }
    client.close();
    setState(() {
      loading = false;
    });
  }

  loadData() {
    getMapData();
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    setState(() {
      locData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              print('reload');
              await getMapData();
            },
          )
        ],
        centerTitle: true,
        backgroundColor: Color(0xff102044),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '${widget.country.length} Current Cases',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
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
                                markers:
                                    List.generate(widget.country.length, (i) {
                                  for (int x = 0; x < locData.length; x++) {
                                    if (locData[x].country ==
                                        widget.country[i].countryName) {
                                      var data = locData[x];
                                      return Marker(
                                        point: LatLng(
                                          double.parse(data.lat),
                                          double.parse(data.long),
                                        ),
                                        builder: (context) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                didTap = true;
                                                initialCountry =
                                                    widget.country[i];
                                                initialPos = LatLng(
                                                  double.parse(data.lat),
                                                  double.parse(data.long),
                                                );
                                                controller.move(
                                                    LatLng(
                                                      double.parse(data.lat),
                                                      double.parse(data.long),
                                                    ),
                                                    4.0);
                                              });
                                              print(widget
                                                  .country[i].countryName);
                                            },
                                            child: Icon(
                                              Icons.location_on,
                                              color: int.parse(widget.country[i]
                                                          .info.totalCases
                                                          .replaceAll(
                                                              ',', '')) >=
                                                      10
                                                  ? Colors.redAccent[100]
                                                  : Colors.greenAccent[100],
                                              size: 40.0,
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                  return Marker();
                                }),
                              )
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10.0,
                                bottom: 10.0,
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
