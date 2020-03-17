import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

class LatestUpdates extends StatefulWidget {
  @override
  _LatestUpdatesState createState() => _LatestUpdatesState();
}

class _LatestUpdatesState extends State<LatestUpdates> {
  // vars
  Map<String, dynamic> updatesData = {};
  List<LatestUpdatesData> latestUpdatesList = [];
  bool loading = true;
  TextEditingController textController = new TextEditingController();
  String filterTxt = '';

  Future getUpdates() async {
    setState(() {
      latestUpdatesList.clear();
      loading = true;
    });
    print('loading');
    http.Client client = http.Client();
    http.Response response =
        await client.get('https://www.worldometers.info/coronavirus/');
    var document = parse(response.body);
    dom.Element news_block = document.getElementById('news_block');
    List<dom.Element> children = news_block.children;
    Map<String, dynamic> listUpdateData = {};
    List<String> storedStrong = [];
    children.forEach((child) {
      // check if child has id of newsdateDATE
      if (child.id.trim().length != 0 && child.children.length > 1) {
        // add id to theData
        child.getElementsByTagName('li').forEach((li) {
          String strString = '';
          li.getElementsByTagName('strong').forEach((str) {
            strString += "${_filterText(str.innerHtml)} ";
          });
          //print(strString);
          storedStrong.add(strString);
          //print('break');
        });
        print(storedStrong);
        print('#############################');
        listUpdateData['${child.id}'] = {
          'date': "${child.id}",
          'news_post': storedStrong,
        };
        latestUpdatesList
            .add(LatestUpdatesData.fromJson(listUpdateData['${child.id}']));
        listUpdateData.clear();
        storedStrong.clear();
        //print(storedStrong.length);
      }
    });
    latestUpdatesList.forEach((data) {
      print(data.newsPost.length);
    });
    setState(() {
      loading = false;
    });
  }

  String _filterText(String text) {
    String newText = text
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('&nbsp;', '')
        .replaceAll('<sup>', '')
        .replaceAll('</sup>', '');
    return newText;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUpdates();
    textController.addListener(() {
      setState(() {
        filterTxt = textController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Latest Updates',
          style: TextStyle(
            fontFamily: 'Lato-Black',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff0B1836),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getUpdates,
        backgroundColor: Color(0xff0B1836),
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xff374972),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
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
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: latestUpdatesList.length,
                      itemBuilder: (context, i) {
                        var date = DateFormat('yMMMMd').add_jm().format(
                            DateTime.parse(latestUpdatesList[i]
                                .date
                                .replaceAll('newsdate', '')));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '$date',
                                style: TextStyle(
                                  fontFamily: 'Lato-Bold',
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                latestUpdatesList[i].newsPost.length,
                                (x) {
                                  return latestUpdatesList[i]
                                          .newsPost[x]
                                          .toLowerCase()
                                          .contains(filterTxt.toLowerCase())
                                      ? Container(
                                          margin: EdgeInsets.all(5),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Color(0xff0B1836),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            '${latestUpdatesList[i].newsPost[x]}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontFamily: 'Lato-Regular',
                                              fontSize: 17.0,
                                            ),
                                          ),
                                        )
                                      : Container();
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class LatestUpdatesData {
  final String date;
  final List<String> newsPost;

  LatestUpdatesData({this.date, this.newsPost});

  factory LatestUpdatesData.fromJson(Map<String, dynamic> json) {
    var postsfromjson = json['news_post'];
    List<String> posts = new List<String>.from(postsfromjson);

    return LatestUpdatesData(
      date: json['date'],
      newsPost: posts,
    );
  }
}
