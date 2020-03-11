import 'dart:async';

import 'package:coronatracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoronaMaps extends StatefulWidget {
  final List<Results> resultData;

  CoronaMaps({this.resultData});

  @override
  _CoronaMapsState createState() => _CoronaMapsState();
}

class _CoronaMapsState extends State<CoronaMaps> {
  String mapStyle;
  Set<Marker> markers = Set();

  // new markers
  Map<MarkerId, Marker> newMarkers = <MarkerId, Marker>{};
  Results tappedText = Results(
    country: 'Nothing',
    newCases: '0',
    newDeaths: '0',
    totalCases: '0',
    totalDeaths: '0',
    totalRecovered: '0',
  );
  LatLng tappedPos;
  double tapZoom = 4.0;

  bool loading = false;
  bool displayData = false;
  Timer load;
  int counter = 0;
  GoogleMapController _mapController;

  getMarkers(Results data) async {
    List<Placemark> placemarks = await Geolocator().placemarkFromAddress(
        '${data.country == 'S. Korea' ? data.country.replaceAll('S. ', '') : data.country}');

    Placemark thePlacemark = placemarks[0];

    Marker theMarker = Marker(
      markerId: MarkerId(data.country),
      position: LatLng(
          thePlacemark.position.latitude, thePlacemark.position.longitude),
      consumeTapEvents: true,
      onTap: () {
        print('tap');
        setState(() {
          tappedPos = LatLng(
              thePlacemark.position.latitude, thePlacemark.position.longitude);
          tappedText = data;
        });
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: tapZoom,
            target: LatLng(
              thePlacemark.position.latitude,
              thePlacemark.position.longitude,
            ),
          ),
        ));
      },
    );
    setState(() {
      newMarkers[MarkerId(data.country)] = theMarker;
    });
  }

  Future loadData() async {
    print('hello');
    setState(() {
      loading = true;
    });
    load = Timer.periodic(Duration(seconds: 3), (d) {
      setState(() {
        loading = false;
      });
      d.cancel();
    });
    List x = widget.resultData.map((data) => getMarkers(data)).toList();
    print(newMarkers.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/maps/dark_maps.txt').then((string) {
      mapStyle = string;
    });
    setState(() {
      loading = true;
    });
    loadData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    load.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('pressed');
              loadData();
            },
          )
        ],
        backgroundColor: Color(0xff1d2c4d),
        title: Column(
          children: <Widget>[
            Text(
              'Current Cases: ${widget.resultData.length}',
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
            Text(
              'Markers: ${newMarkers.length}',
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
            Text(
              'Takes a while to load the map',
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
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
                          CameraPosition(target: LatLng(12, 121)),
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      markers: Set<Marker>.of(newMarkers.values),
                      onCameraMove: (CameraPosition pos) {
                        setState(() {
                          tapZoom = pos.zoom;
                        });
                      },
                      onCameraIdle: () {},
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
