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
  DateTime date = DateTime.now();

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
    print(document.querySelectorAll("[id*='newsdate']").length);
    document.querySelectorAll("[id*='newsdate']").forEach((newsDate) {
      //print(newsDate.id);
      //print(newsDate.children);
      newsDate.children.forEach((news) {
        //print(parse(news.innerHtml).documentElement.text);
        if (news.querySelectorAll('.news_post').length != 1) {
          if (!news.id.contains('newsdate')) {
            storedStrong
                .add(_filterText(parse(news.innerHtml).documentElement.text));
            //print(storedStrong.length);
          }
        } else {
          print('nope');
        }
      });
      List<String> removeDups = storedStrong.toSet().toList();
      listUpdateData['${newsDate.id}'] = {
        'date': '${newsDate.id}',
        'news_post': removeDups,
      };
      latestUpdatesList
          .add(LatestUpdatesData.fromJson(listUpdateData['${newsDate.id}']));
      listUpdateData.clear();
      storedStrong.clear();
      print(true);
    });

    latestUpdatesList.removeLast();
    latestUpdatesList.removeLast();
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
        .replaceAll('[source]', '')
        .trim();
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
        title: Column(
          children: <Widget>[
            Text(
              'Latest Updates',
              style: TextStyle(
                fontFamily: 'Lato-Black',
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              'As of ${DateFormat.yMMMd().add_jm().format(date)}',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Lato-Bold',
                fontSize: 12.0,
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff0B1836),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getUpdates,
        backgroundColor: const Color(0xff0B1836),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xff374972),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      filled: true,
                      fillColor: const Color(0xff1d2c4d),
                      hintText: 'Search a country',
                      hintStyle: const TextStyle(
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              margin: const EdgeInsets.only(
                                top: 5.0,
                                left: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '$date',
                                style: const TextStyle(
                                  fontFamily: 'Lato-Black',
                                  color: Colors.black,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
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
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 5.0,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: Color(0xff0B1836),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 5.0,
                                                  color: Colors.black38,
                                                )
                                              ]),
                                          child: Text(
                                            '${latestUpdatesList[i].newsPost[x]}',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontFamily: 'Lato-Regular',
                                              fontSize: 12.5,
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
