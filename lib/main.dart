import 'dart:async';

import 'package:coronatracker/latest_updates.dart';
import 'package:coronatracker/maps_corona.dart';
import 'package:coronatracker/more_info.dart';
import 'package:coronatracker/widgets/active_cases.dart';
import 'package:coronatracker/widgets/new_deaths.dart';
import 'package:coronatracker/widgets/serious_critical.dart';
import 'package:coronatracker/widgets/total_cases.dart';
import 'package:coronatracker/widgets/total_deaths.dart';
import 'package:coronatracker/widgets/total_recovered.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'models/results.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Corona Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> countriesList = [];
  List<String> totalCasesList = [];
  List<String> newCasesList = [];
  List<String> totalDeathsList = [];
  List<String> newDeathsList = [];
  List<String> totalRecovered = [];
  List<String> activeCasesList = [];
  List<String> seriousCriticalList = [];
  List<Map<String, dynamic>> jsonCountryData = [];

  Map<String, dynamic> results = {};
  Map<String, dynamic> moreRes = {};
  // Map<MarkerId, Marker> newMarkers = <MarkerId, Marker>{};
  List<Marker> markers = [];
  List<Map<String, dynamic>> data = [];

  List<Country> country = [];
  MoreResults moreResults;

  bool loading = true;
  bool showReloadMsg = false;
  bool showMapLoading = true;

  String filterTxt;

  Timer getMarkers;

  ScrollController controller;
  TextEditingController textController = TextEditingController();

  int loadListLength = 5;
  DateTime date = DateTime.now();

  List<MapsData> mapData;
  List<LocationData> locData = [];

  // TODO: JUST A MARK
  Future getCountries() async {
    _clearLists();

    Timer(Duration(seconds: 4), () {
      setState(() {
        showReloadMsg = true;
      });
    });
    // fetch data
    http.Client client = http.Client();
    http.Response response =
        await client.get('https://www.worldometers.info/coronavirus/');
    var document = parse(response.body);

    List<dom.Element> totalCases = document
        .querySelectorAll('#main_table_countries_today > tbody > tr > td');
    // print(totalCases);

    for (int x = 0; x < totalCases.length; x++) {
      // adds to countriesList
      if (x % 9 == 0) {
        if (totalCases[x].innerHtml.contains('<a')) {
          countriesList.add(totalCases[x].querySelector('a').innerHtml.trim());
        } else if (totalCases[x].innerHtml.contains('<span')) {
          countriesList
              .add(totalCases[x].querySelector('span').innerHtml.trim());
        } else {
          countriesList.add(totalCases[x].innerHtml.trim());
        }
      }
      // adds to totalCasesList
      else if (x % 9 == 1) {
        totalCasesList.add(totalCases[x].innerHtml.trim());
      }
      // adds to newCasesList
      else if (x % 9 == 2) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          newCasesList.add(totalCases[x].innerHtml.trim());
        } else {
          newCasesList.add('NO');
        }
      }
      // adds to totalDeathsList
      else if (x % 9 == 3) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          totalDeathsList.add(totalCases[x].innerHtml.trim());
        } else {
          totalDeathsList.add('NONE');
        }
      }
      // adds to newDeathsList
      else if (x % 9 == 4) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          newDeathsList.add(totalCases[x].innerHtml.trim());
        } else {
          newDeathsList.add('NO');
        }
      }
      // adds to totalRecovered
      else if (x % 9 == 5) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          totalRecovered.add(totalCases[x].innerHtml.trim());
        } else {
          totalRecovered.add('NONE');
        }
      }
      // adds to activeCasesList
      else if (x % 9 == 6) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          activeCasesList.add(totalCases[x].innerHtml.trim());
        } else {
          activeCasesList.add('NONE');
        }
      }
      // adds to seriousCriticalList
      else if (x % 9 == 7) {
        if (totalCases[x].innerHtml.trim().length != 0) {
          seriousCriticalList.add(totalCases[x].innerHtml.trim());
        } else {
          seriousCriticalList.add('NONE');
        }
      }
    }

    // more info load data
    List<dom.Element> totalsCDR = document
        .querySelectorAll('body div#maincounter-wrap .maincounter-number span');
    print('printing');
    List<dom.Element> totalsARC =
        document.querySelectorAll('body div.panel_front div.number-table-main');
    List<dom.Element> totalsSD =
        document.querySelectorAll('body div.panel_front span.number-table');

    setState(() {
      moreResults = MoreResults(
        totalCases: totalsCDR[0].innerHtml.trim() ?? 'NONE',
        totalDeaths: totalsCDR[1].innerHtml.trim() ?? 'NONE',
        totalRecovered: totalsCDR[2].innerHtml.trim() ?? 'NONE',
        totalActiveCases: totalsARC[0].innerHtml.trim() ?? 'NONE',
        totalClosedCases: totalsARC[1].innerHtml.trim() ?? 'NONE',
        totalMild: totalsSD[0].innerHtml.trim() ?? 'NONE',
        totalSeriousCritical: totalsSD[1].innerHtml.trim() ?? 'NONE',
        totalDischarged: totalsSD[2].innerHtml.trim() ?? 'NONE',
      );
    });

    // removes all the last records
    _removeLastRecord();

    // creates json format of data,
    // TODO: Create search feature with json data
    Map<String, dynamic> countryJsonData = {};
    for (int i = 0; i < countriesList.length; i++) {
      countryJsonData['id_$i'] = {
        'countryName': countriesList[i],
        'info': {
          'totalCases': totalCasesList[i],
          'newCases': newCasesList[i],
          'totalDeaths': totalDeathsList[i],
          'newDeaths': newDeathsList[i],
          'totalRecovered': totalRecovered[i],
          'activeCases': activeCasesList[i],
          'seriousCritical': seriousCriticalList[i],
        }
      };
      country.add(Country.fromJson(countryJsonData['id_$i']));
    }

    jsonCountryData.add(countryJsonData);
    setState(() {
      loading = false;
      showReloadMsg = false;
      date = DateTime.now();
      loadListLength = 5;
    });
  }

  _removeLastRecord() {
    setState(() {
      countriesList.removeLast();
      totalCasesList.removeLast();
      totalDeathsList.removeLast();
      newDeathsList.removeLast();
      totalRecovered.removeLast();
      newCasesList.removeLast();
      activeCasesList.removeLast();
      seriousCriticalList.removeLast();
    });
  }

  _clearLists() {
    setState(() {
      loading = true;
      showReloadMsg = false;
      country.clear();
      countriesList.clear();
      totalCasesList.clear();
      totalDeathsList.clear();
      newDeathsList.clear();
      totalRecovered.clear();
      newCasesList.clear();
      activeCasesList.clear();
      seriousCriticalList.clear();
    });
  }

//  loadMarkers() {
//    print('loading');
//    Timer.run(() {
//      setState(() {
//        pMarkData.clear();
//        showMapLoading = true;
//      });
//    });
//    try {
//      country.forEach((c) async {
//        List<Placemark> placemark = await retry(
//          () => Geolocator()
//              .placemarkFromAddress(
//                  "${c.countryName == "S. Korea" ? c.countryName.replaceAll('S. ', '') : c.countryName}")
//              .asStream()
//              .toList()
//              .then((x) {
//            //print(x[0]);
//            return x[0];
//          }),
//          delayFactor: Duration(seconds: 1),
//          maxAttempts: 3,
//          maxDelay: Duration(seconds: 2),
//          onRetry: (e) {
//            //print(e);
//          },
//          retryIf: (e) => e is PlatformException,
//        );
//        //print(placemark.length);
//        pMarkData.add(placemark[0]);
//      });
//    } catch (e) {
//      //print(e);
//    }
//
//    Timer(Duration(seconds: 5), () {
//      setState(() {
//        showMapLoading = false;
//      });
//    });
//  }

  @override
  void initState() {
    super.initState();
    getCountries();
    controller = new ScrollController()..addListener(_scrollListener);
    textController.addListener(() {
      setState(() {
        filterTxt = textController.text;
      });
    });
    //initiate();
  }

  void _scrollListener() {
    //print(controller.position.pixels);
    if (controller.position.extentAfter < 500) {
      Timer(Duration(milliseconds: 50), () {
        setState(() {
          loadListLength < country.length
              ? loadListLength += 1
              : loadListLength = country.length;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text(
              'Corona Tracker',
              style: TextStyle(
                fontFamily: 'Lato-Black',
              ),
            ),
            Text(
              '${country.length == 0 ? 'Loading' : country.length} Places',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato-Regular',
                fontSize: 15,
                color: Colors.cyanAccent,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xff1d2c4d),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xff1C2844),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff0B1836),
                      Color(0xff000F30),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Corona Tracker',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lato-Black',
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${country.length} \nAffected Areas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.yellow,
                          fontFamily: 'Lato-Bold',
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        '${DateFormat('yMMMMd').add_jm().format(date)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato-Regular',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                color: Color(0xff374972),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LatestUpdates(),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    'Latest Updates',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato-Regular',
                    ),
                  ),
                  leading: Icon(Icons.assessment, color: Colors.orangeAccent),
                ),
              ),
              MaterialButton(
                color: Color(0xff374972),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MoreInfo(
                      results: moreResults,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: loading
                      ? CircularProgressIndicator()
                      : Icon(
                          Icons.info_outline,
                          color: Colors.redAccent[100],
                        ),
                  title: Text(
                    '${loading ? 'Loading' : 'More'} Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato-Regular',
                    ),
                  ),
                ),
              ),
              MaterialButton(
                color: Color(0xff374972),
                onPressed: () => !showMapLoading
                    ? null
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapsCorona(
                            country: country,
                            markers: markers,
                          ),
                        ),
                      ),
                child: ListTile(
                  leading: !showMapLoading
                      ? CircularProgressIndicator()
                      : Icon(
                          Icons.location_on,
                          color: Colors.yellow,
                        ),
                  title: Text(
                    'Open Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Lato-Regular',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: loading
          ? null
          : FloatingActionButton(
              onPressed: getCountries,
              backgroundColor: Color(0xff375087),
              child: Icon(
                Icons.refresh,
              ),
            ),
      backgroundColor: Color(0xff375087),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Loading... \n ${showReloadMsg ? '\nLooks like its taking a while...\n try reloading again!' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: showReloadMsg ? 15.0 : 20.0,
                      color: Colors.white,
                      fontFamily: 'Lato-Regular',
                    ),
                  )
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: textController,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato-Regular',
                        ),
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.backspace,
                              color: Colors.grey[200],
                            ),
                            tooltip: 'Clear',
                            onPressed: () {
                              textController.clear();
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: Color(0xff1d2c4d),
                          hintText: 'Search a country',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Lato-Regular',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'As of ${DateFormat('yMMMMd').add_jm().format(date)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lato-Black',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Scrollbar(
                      controller: ScrollController(),
                      child: ListView.builder(
                        // TODO: Lazy Load
                        physics: BouncingScrollPhysics(),
                        controller: controller,
                        itemCount: country.length,
                        itemBuilder: (context, i) {
                          Country c = country[i];
                          return filterTxt == null ||
                                  filterTxt == "" ||
                                  filterTxt.trim().length == 0
                              ? DataWidget(
                                  country: c,
                                )
                              : _search(filterTxt, c)
                                  ? DataWidget(
                                      country: c,
                                    )
                                  : Container();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _search(String val, Country c) {
    if (c.countryName.toLowerCase().trim().contains(val.toLowerCase())) {
      return true;
    } else {
      return false;
    }
  }
}

class DataWidget extends StatelessWidget {
  final Country country;

  DataWidget({this.country});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xff1d2c4d),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10.0,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  Text(
                    '${country.countryName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Lato-Black',
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${country.info.newCases}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato-Black',
                      fontSize: 20,
                      color: country.info.newCases == 'NO'
                          ? Colors.greenAccent
                          : int.parse(country.info.newCases
                                      .replaceFirst('+', '')
                                      .replaceAll(',', '')) >=
                                  10
                              ? Colors.amber
                              : Colors.orange,
                    ),
                  ),
                  Text(
                    'New Cases',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      color: Colors.white,
                      fontFamily: 'Lato-Regular',
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TotalCases(
                    data: country.info.totalCases,
                    type: 'Total Cases',
                    dataSize: 20,
                    textSize: 12,
                    isMaps: false,
                  ),
                  TotalDeaths(
                    data: country.info.totalDeaths,
                    type: 'Total Deaths',
                    dataSize: 20,
                    textSize: 12,
                    isMaps: false,
                  ),
                  NewDeaths(
                    data: country.info.newDeaths,
                    type: 'New Deaths',
                    dataSize: 20,
                    textSize: 12,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  TotalRecovered(
                    data: country.info.totalRecovered,
                    type: 'Total Recovered',
                    dataSize: 20,
                    textSize: 15,
                  ),
                  ActiveCases(
                    data: country.info.activeCases,
                    type: 'Active Cases',
                    dataSize: 20,
                    textSize: 15,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: <Widget>[
                  SeriousCritical(
                    data: country.info.seriousCritical,
                    type: 'Serious, Critical',
                    dataSize: 25,
                    textSize: 15,
                    isRow: false,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
