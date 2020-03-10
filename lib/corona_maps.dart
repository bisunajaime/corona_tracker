import 'dart:async';

import 'package:coronatracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class CoronaMaps extends StatefulWidget {
  @override
  _CoronaMapsState createState() => _CoronaMapsState();
}

class _CoronaMapsState extends State<CoronaMaps> {
  String mapStyle;
  Set<Marker> markers = Set();
  Results tappedText = Results(
    country: 'Nothing',
    newCases: '0',
    newDeaths: '0',
    totalCases: '0',
    totalDeaths: '0',
    totalRecovered: '0',
  );
  LatLng tappedPos;

  List<String> countriesList = [];
  List<String> totalCasesList = [];
  List<String> newCasesList = [];
  List<String> totalDeathsList = [];
  List<String> newDeathsList = [];
  List<String> totalRecovered = [];

  List<Placemark> placemark = [];

  Map<String, dynamic> results = {};
  List<Map<String, dynamic>> data = [];
  List<Results> info = [];

  bool loading = true;
  bool showReloadMsg = false;
  bool displayData = false;

  Future getCountries() async {
    setState(() {
      // clear when reload
      loading = true;
      showReloadMsg = false;
      info.clear();
      data.clear();
      countriesList.clear();
      totalCasesList.clear();
      totalDeathsList.clear();
      newDeathsList.clear();
      totalRecovered.clear();
      newCasesList.clear();
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        showReloadMsg = true;
      });
    });
    // fetch data
    http.Client client = http.Client();
    http.Response response =
        await client.get('https://www.worldometers.info/coronavirus/');
    var document = parse(response.body);

    // print data
    List<dom.Element> totalCases = document.getElementsByTagName('td');

    for (int x = 0; x <= 72; x += 9) {
      if (x != 72) {
        countriesList.add(totalCases[x].querySelector('a').innerHtml.trim());
      } else {
        countriesList.add(totalCases[x].querySelector('span').innerHtml.trim());
      }
    }

    // Countries
    for (int x = 81; x < totalCases.length; x += 9) {
      countriesList.add(totalCases[x].innerHtml.trim());
    }

    // Total Cases
    for (int x = 1; x < totalCases.length; x += 9) {
      totalCasesList.add(totalCases[x].innerHtml.trim());
    }

    for (int x = 2; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        newCasesList.add(totalCases[x].innerHtml.trim());
      } else {
        newCasesList.add('NO');
      }
    }

    for (int x = 3; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        totalDeathsList.add(totalCases[x].innerHtml.trim());
      } else {
        totalDeathsList.add('NONE');
      }
    }

    for (int x = 4; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        newDeathsList.add(totalCases[x].innerHtml.trim());
      } else {
        newDeathsList.add('NO');
      }
    }

    for (int x = 5; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        totalRecovered.add(totalCases[x].innerHtml.trim());
      } else {
        totalRecovered.add('NONE');
      }
    }

    // remove total tr
    countriesList.removeLast();
    totalCasesList.removeLast();
    totalDeathsList.removeLast();
    newDeathsList.removeLast();
    totalRecovered.removeLast();
    newCasesList.removeLast();

    for (int i = 0; i < countriesList.length; i++) {
      data.add({
        'country': countriesList[i],
        'totalCases': totalCasesList[i],
        'newCases': newCasesList[i],
        'totalDeaths': totalDeathsList[i],
        'newDeaths': newDeathsList[i],
        'totalRecovered': totalRecovered[i],
      });
    }

    info = data.map((res) => Results.fromJson(res)).toList();
    //print(info);

    for (int i = 0; i < info.length; i++) {
      _generateMapData(i);
    }

    print(markers.length);
    setState(() {
      loading = false;
      showReloadMsg = false;
    });
    print(placemark[0].position.latitude);
  }

  _generateMapData(int i) async {
    List<Placemark> pm =
        await Geolocator().placemarkFromAddress("${info[i].country}");
    markers.add(
      Marker(
          markerId: MarkerId(info[i].country),
          position: LatLng(
            pm[0].position.latitude,
            pm[0].position.longitude,
          ),
          consumeTapEvents: true,
          onTap: () {
            print('${info[i].country}');
            setState(() {
              tappedText = info[i];
            });
            _mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target:
                      LatLng(pm[0].position.latitude, pm[0].position.longitude),
                  zoom: 4.0,
                ),
              ),
            );
          }),
    );
  }

  GoogleMapController _mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountries();
    rootBundle.loadString('assets/maps/dark_maps.txt').then((string) {
      mapStyle = string;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1d2c4d),
        title: Text('Corona Maps'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: getCountries,
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Color(0xff1d2c4d),
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  backgroundColor: Color(0xff29606e),
                ),
              )
            : Column(
                children: <Widget>[
                  Expanded(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _mapController.setMapStyle(mapStyle);
                      },
                      initialCameraPosition:
                          CameraPosition(target: LatLng(16, 180)),
                      markers: markers,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                    ),
                  ),
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(
                      vertical: 0.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: Color(0xff1d2c4d),
                                  child: Center(
                                    child: Text(
                                      'Country\n${tappedText.country}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: tappedText.totalCases == 'NONE' ||
                                            tappedText.totalCases == 'NO'
                                        ? Colors.blue
                                        : int.parse(tappedText.totalCases
                                                    .replaceAll(',', '')
                                                    .toString()) >=
                                                100
                                            ? Colors.red[700]
                                            : Colors.purple[700],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Total Cases\n${tappedText.totalCases}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: tappedText.newCases == 'NO'
                                        ? Colors.green[700]
                                        : int.parse(tappedText.newCases
                                                    .replaceFirst('+', '')) >=
                                                20
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'New Cases\n${tappedText.newCases}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  color: tappedText.totalDeaths == 'NONE' ||
                                          tappedText.totalDeaths == 'NO'
                                      ? Colors.blue
                                      : int.parse(tappedText.totalDeaths
                                                  .replaceAll(',', '')
                                                  .toString()) >=
                                              50
                                          ? Colors.red[700]
                                          : Colors.purple[700],
                                  child: Center(
                                    child: Text(
                                      'Total Deaths\n${tappedText.totalDeaths}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: tappedText.newDeaths == 'NONE' ||
                                          tappedText.newDeaths == 'NO'
                                      ? Colors.blue
                                      : int.parse(tappedText.newDeaths
                                                  .replaceAll(',', '')
                                                  .toString()) >=
                                              10
                                          ? Colors.red[700]
                                          : Colors.purple[700],
                                  child: Center(
                                    child: Text(
                                      'New Deaths\n${tappedText.newDeaths}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: tappedText.totalRecovered == 'NONE' ||
                                          tappedText.totalRecovered == 'NO'
                                      ? Colors.blue
                                      : int.parse(tappedText.totalRecovered
                                                  .replaceAll(',', '')
                                                  .toString()) >=
                                              10
                                          ? Colors.green[900]
                                          : Colors.red[700],
                                  child: Center(
                                    child: Text(
                                      'Total Recovered\n${tappedText.totalRecovered}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
