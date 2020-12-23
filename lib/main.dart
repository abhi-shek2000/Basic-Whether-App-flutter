import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: homepage());
  }
}

class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  TextEditingController searchLocation = TextEditingController();
  String abbreviation = "c";
  int temp;
  String location = "Pune";
  String searchUrl = "https://www.metaweather.com/api/location/search/?query=";
  String searchWoeid = "https://www.metaweather.com/api/location/";
  int woeid = 2295412;
  String whetherState = "clear";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchWhether();
  }
  void fetchSearch(String input) async {
    var searchRes = await http.get(searchUrl + input);
    var res = json.decode(searchRes.body)[0];
    print(res.toString());
    setState(() async {
      woeid = res["woeid"];
      location = res["title"].toString();
      print(location);
      await fetchWhether();
    });
  }

  void fetchWhether() async {
    var searchBywoeid = await http.get(searchWoeid + woeid.toString());
    var result = json.decode(searchBywoeid.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      whetherState = data["weather_state_name"].replaceAll(" ","").toLowerCase();
      print(whetherState);
      temp = data["the_temp"].round();
      abbreviation = data["weather_state_abbr"];
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/$whetherState.png"),
          fit: BoxFit.fill,
        )),
        child: temp == null ? Center(child: CircularProgressIndicator(backgroundColor: Colors.black,),) : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
            ),

            Center(
              child: Text(
                temp.toString() + "°C",
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 70),
            Center(
                child: Container(
              width: 300,
              child: TextField(
                controller: searchLocation,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white54,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red, //this has no effect
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: "Search Location ...",
                  suffixIcon: IconButton(icon: Icon(Icons.search_sharp),onPressed: () {
                    setState(()  {
                       fetchSearch(searchLocation.text);
                    });},
                  )
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
