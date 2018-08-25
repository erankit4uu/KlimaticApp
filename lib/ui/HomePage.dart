import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../utils/utils.dart' as utils;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final String cityname;

  Home({this.cityname, Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map map;
  String tempr = '20.9';
  String _city = "New Delhi";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCity();


  }
  _getCity() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _city = preferences.getString("city");
      debugPrint(_city);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Klimatic'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        // images from unsplash.com
        // compress from tinypng.com
      ),
      body: new Stack(
        children: <Widget>[
          Center(
            child: Image(
              image: AssetImage('images/umbrella.jpg'),
              fit: BoxFit.fill,
              height: 1200.0,
              width: 500.0,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 10.0, right: 20.0),
            child: Text(
              _city,
              style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image(
              image: AssetImage('images/light_rain.png'),
            ),
          ),
//          Container(
//              alignment: Alignment.center,
//              margin: EdgeInsets.only(bottom: 20.0, left: 10.0),
//              child: Text(tempr == '20.9' ? tempr : tempr)),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 20.0, left: 30.0, top: 220.0),
              child: updateTempData(_city)),
          Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.all(40.0),
              child: FloatingActionButton(
                onPressed: () {
                  var route =
                      MaterialPageRoute(builder: (BuildContext context) {
                    return CityPage();
                  });
                  Navigator.of(context).push(route);
                },
                backgroundColor: Colors.blue.shade500,
                child: Icon(Icons.add),
              ))
        ],
      ),
    );
  }

  TextStyle temperatureStyle() {
    return TextStyle(
        color: Colors.blue.shade400,
        fontSize: 30.0,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic);
  }

  Future<Map> getWeatherReport(String appID, String cityName) async {
    String url =
        'http://api.openweathermap.org/data/2.5/find?q=$cityName&appid=$appID&units=metric';

    http.Response response = await http.get(url);

    debugPrint(response.body);
//    updateTempData(utils.defaultCity);
    return json.decode(response.body);
  }

  Widget updateTempData(String city) {
    return new FutureBuilder(
        future: getWeatherReport(
            utils.appId, city == null ? '${widget.cityname}' : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            map = snapshot.data;
            tempr = map['list'][0]['main']['temp'].toString() + '`C';

            return new Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      map['list'][0]['main']['temp'].toString() + '`C',
                      style: temperatureStyle(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      map['list'][0]['main']['humidity'].toString() + '% humid',
                      style: temperatureStyle(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      map['list'][0]['main']['temp_min'].toString() +
                          '`C min temp',
                      style: temperatureStyle(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      map['list'][0]['main']['temp_max'].toString() +
                          '`C max temp',
                      style: temperatureStyle(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

  TextStyle cityStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 18.0,
    );
  }

  class CityPage extends StatefulWidget {
    @override
    _CityPageState createState() => _CityPageState();
  }

  class _CityPageState extends State<CityPage> {
    var _cityFieldController = new TextEditingController();

    _saveCity(String cityName) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("city", cityName);
      debugPrint(cityName);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kimatic'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image(
                image: AssetImage('images/clouds.jpg'),
                fit: BoxFit.fill,
                height: 1200.0,
                width: 800.0),
          ),
          Container(
              alignment: Alignment.topCenter,
              child: ListView(children: <Widget>[
                ListTile(
                  title: TextField(
                    controller: _cityFieldController,
                    decoration: InputDecoration(
                        labelText: 'Enter city',
                        labelStyle: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
                ListTile(
                  title: MaterialButton(
                    onPressed: () {
                      var route = MaterialPageRoute<Map>(
                          builder: (BuildContext context) {
                        return Home(
                          cityname: _cityFieldController.text,
                        );
                      });
                      Navigator.of(context).push(route);
                      _saveCity(_cityFieldController.text);
                    },
                    textColor: Colors.white,
                    color: Colors.blue.shade500,
                    child: Text('Change city'),
                  ),
                )
              ])),
        ],
      ),
    );
  }
}
