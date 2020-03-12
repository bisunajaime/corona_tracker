import 'dart:async';

import 'package:coronatracker/widgets/active_cases.dart';
import 'package:coronatracker/widgets/new_deaths.dart';
import 'package:coronatracker/widgets/serious_critical.dart';
import 'package:coronatracker/widgets/total_cases.dart';
import 'package:coronatracker/widgets/total_deaths.dart';
import 'package:coronatracker/widgets/total_recovered.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/results.dart';

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
    country: 'Select a Marker',
    newCases: '0',
    newDeaths: '0',
    totalCases: '0',
    totalDeaths: '0',
    totalRecovered: '0',
    activeCases: '0',
    seriousCritical: 'NONE',
  );
  LatLng tappedPos;
  double tapZoom = 4.0;

  bool loading = false;
  bool displayData = false;
  Timer load;
  int counter = 0;
  GoogleMapController _mapController;

  Future getMarkers(Results data) async {
    try {
      List<Placemark> placemarks = await Geolocator().placemarkFromAddress(
          '${data.country == 'S. Korea' ? data.country.replaceAll('S. ', '') : data.country}');
      Placemark thePlacemark = placemarks.first;
      Marker theMarker = Marker(
        markerId: MarkerId(data.country),
        position: LatLng(
            thePlacemark.position.latitude, thePlacemark.position.longitude),
        consumeTapEvents: true,
        infoWindow: InfoWindow(
          anchor: Offset(10.0, 10.0),
          title: data.country,
          snippet: data.totalCases,
          onTap: () {
            print('tapped');
          },
        ),
        onTap: () {
          print('tap');
          setState(() {
            tappedPos = LatLng(thePlacemark.position.latitude,
                thePlacemark.position.longitude);
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
      print(markers.length);
    } catch (e) {
      print('<< $e >>;');
    }
  }

  Future loadData() async {
    print('hello');
    setState(() {
      loading = true;
    });

    widget.resultData.map((data) async => await getMarkers(data)).toList();

    setState(() {
      loading = false;
    });
    print(newMarkers.length);
  }

  @override
  void initState() {
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
    load.cancel();
    markers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color lightBlue = Color(0xff203053);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1d2c4d),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    flex: 3,
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                        _mapController.setMapStyle(mapStyle);
                      },
                      initialCameraPosition:
                          CameraPosition(target: LatLng(12, 121)),
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      markers: Set<Marker>.of(newMarkers.values),
                      onCameraMove: (CameraPosition pos) {
                        setState(() {
                          tapZoom = pos.zoom;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      color: lightBlue,
                      margin: EdgeInsets.symmetric(
                        vertical: 0.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 30.0,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        '${tappedText.country}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          TotalCases(
                                            data: tappedText.totalCases,
                                            type: 'Total Cases',
                                            dataSize: 20,
                                            textSize: 12,
                                            isMaps: true,
                                          ),
                                          TotalRecovered(
                                            data: tappedText.totalRecovered,
                                            type: 'Total Recovered',
                                            dataSize: 20,
                                            textSize: 12,
                                          ),
                                          ActiveCases(
                                            data: tappedText.activeCases,
                                            type: 'Active Cases',
                                            dataSize: 20,
                                            textSize: 12,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          TotalDeaths(
                                            data: tappedText.totalDeaths,
                                            type: 'Total Deaths',
                                            dataSize: 20,
                                            textSize: 12,
                                            isMaps: true,
                                          ),
                                          NewDeaths(
                                            data: tappedText.newDeaths,
                                            type: 'New Deaths',
                                            dataSize: 20,
                                            textSize: 12,
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          SeriousCritical(
                                            data: tappedText.seriousCritical,
                                            type: 'Serious, Critical: ',
                                            dataSize: 15,
                                            textSize: 15,
                                            isRow: true,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
