import 'package:flutter/material.dart';
import 'package:play_store_scraper/play_store_scraper.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Example App',
      theme: ThemeData(
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PlayStoreScraper scraper = PlayStoreScraper();
  ScraperResult? _result;
  bool _isError = true, _isLoading = true;
  String _errorMsg = "", _error = "";

  final TextStyle _headingStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      _valueStyle = TextStyle(
        fontSize: 18,
      );

  Widget _viewWidget({
    required String title,
    required String value,
  }) =>
      Row(
        children: [
          Text(
            title,
            style: _headingStyle,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: _valueStyle,
            ),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  getInfo() async {
    _isLoading = true;
    var data = await scraper.app(appID: "com.snapchat.android");
    _isError = data['isError'];
    if (_isError) {
      _errorMsg = data['message'];
      _error = data['error'];
    } else {
      _result = data['data'];
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('App Info'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _isError
              ? Center(
                  child: Column(
                    children: [
                      Text(_error),
                      Text(_errorMsg),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(10),
                  children: [
                    if (_result != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ClipOval(
                            child: Image.network(
                              _result!.icon,
                              height: 100,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              Text(
                                _result!.title,
                                textAlign: TextAlign.center,
                                style: _headingStyle,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "(${_result!.appID})",
                                textAlign: TextAlign.center,
                                style: _valueStyle.copyWith(fontSize: 16),
                              ),
                            ],
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "installs".toUpperCase(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(_result!.installs),
                                ],
                              )),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "version".toUpperCase(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(_result!.version),
                                ],
                              )),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                              height: 40,
                              width: 68,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "rating".toUpperCase(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text(_result!.ratingsScoreText),
                                ],
                              )),
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                              ),
                              height: 40,
                              width: 68,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_result!.free) ...[
                                    Text(
                                      "FREE",
                                      style:
                                          _headingStyle.copyWith(fontSize: 14),
                                    )
                                  ] else ...[
                                    Text(
                                      "price".toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                        "${_result!.priceCurrency} ${_result!.price}"),
                                  ]
                                ],
                              )),
                        ],
                      ),
                      Divider(),
                      Text(
                        _result!.description,
                        textAlign: TextAlign.justify,
                        style: _valueStyle,
                      ),
                      Divider(),
                      _viewWidget(title: "Genre", value: _result!.genreID),
                      Divider(),
                      _viewWidget(title: "Update On", value: _result!.updated),
                      Divider(),
                      _viewWidget(
                          title: "Content for", value: _result!.contentRating),
                      Divider(),
                      _viewWidget(
                          title: "Developer", value: _result!.developer),
                      SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await launch(_result!.appUrl);
                            },
                            child: Text("Open App Page"),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.indigo)),
                            onPressed: () async {
                              await launch(_result!.developerWebsite);
                            },
                            child: Text("Open Developer Website"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await launch("mailto:${_result!.developerEmail}");
                            },
                            child: Text("Mail Developer"),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepOrange)),
                            onPressed: () async {
                              await launch(_result!.developerUrl);
                            },
                            child: Text("Open Developer Page"),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
    );
  }
}
