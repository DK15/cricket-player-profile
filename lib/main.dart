import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:search_player/players.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: AutoComplete(),
      ),
    );
  }
}

class AutoComplete extends StatefulWidget {
  @override
  _AutoCompleteState createState() => new _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoComplete> {
  GlobalKey<AutoCompleteTextFieldState<Players>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();

  _AutoCompleteState();

  String name, playingRole, battingStyle, country, imageURL;
  int pid, playerId;
  String halfTest, centuryTest, matchesTest, runsTest, highestTest;
  String halfOdi, centuryOdi, matchesOdi, runsOdi, highestOdi;
  String halfT, centuryT, matchesT, runsT, highestT;

  bool isData = false;

  Map data = Map();

  bool textInput = false;
  bool isLoading = false;

  Players players = Players();

  bool found = false;

  void _loadData() async {
    await PlayerViewModel.loadPlayers();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Player Profile'),
        ),
        body: new Center(
          child: new Column(children: <Widget>[
            new Column(children: <Widget>[
              searchTextField = AutoCompleteTextField<Players>(
                style: new TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: new InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => searchTextField.clear());
                          textInput = false;
                        }),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                    filled: true,
                    hintText: 'Search Player Name',
                    hintStyle: TextStyle(color: Colors.black)),
                itemSubmitted: (item) {
                  setState(() {
                    searchTextField.textField.controller.text = item.name;
                    textInput = true;
                    showData();
                    isLoading = true;
                  });
                },
                onFocusChanged: (hasFocus) {},
                clearOnSubmit: false,
                key: key,
                suggestions: PlayerViewModel.players,
                itemBuilder: (context, item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                      ),
                    ],
                  );
                },
                itemSorter: (a, b) {
                  return a.name.compareTo(b.name);
                },
                itemFilter: (item, query) {
                  return item.name
                      .toLowerCase()
                      .startsWith(query.toLowerCase());
                },
              ),
              isLoading
                  ? Container(
                      alignment: Alignment.center,
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator())
                  : Container(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.only(top: 40),
                      height: 400,
                      width: 400,
                      child: textInput ? playerProfile() : Container())
            ])
          ]),
        ));
  }

  showData() {
    String input = searchTextField.textField.controller.text.toLowerCase();
    found = false;

    for (var i = 0; i < PlayerViewModel.players.length; i++) {
      if (PlayerViewModel.players[i].name.toLowerCase() == input) {
        players = PlayerViewModel.players[i];
        found = true;
        break;
      }
    }
    if (found) {
      fetchJson(players.pid).then((data) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  fetchJson(int pid) async {
    var response = await http.get(
        'http://cricapi.com/api/playerStats?apikey=w7qMBWsDWwfWgVZl7WCJWcDZOqe2&pid=$pid');
    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJson = jsonDecode(responseBody);
      name = responseJson['name'];
      playingRole = responseJson['playingRole'] ?? "NA";
      battingStyle = responseJson['battingStyle'];
      country = responseJson['country'];
      imageURL = responseJson['imageURL'];
      data = responseJson;

      var stats = data['data']['batting'];
      var testStats = stats['tests'];
      if (testStats == null) {
        matchesTest = "NA";
        runsTest = "NA";
        centuryTest = "NA";
        halfTest = "NA";
        highestTest = "NA";
      } else {
        // Test Stats

        matchesTest = testStats['Mat'];
        runsTest = testStats['Runs'];
        halfTest = testStats['50'];
        centuryTest = testStats['100'];
        highestTest = testStats['HS'];
      }
      var odiStats = stats['ODIs'];
      if (odiStats == null) {
        matchesOdi = "NA";
        runsOdi = "NA";
        halfOdi = "NA";
        centuryOdi = "NA";
        highestOdi = "NA";
      } else {
        // ODI Stats

        matchesOdi = odiStats['Mat'];
        runsOdi = odiStats['Runs'];
        halfOdi = odiStats['50'];
        centuryOdi = odiStats['100'];
        highestOdi = odiStats['HS'];
      }
      var tStats = stats['T20Is'];
      if (tStats == null) {
        matchesT = "NA";
        runsT = "NA";
        halfT = "NA";
        centuryT = "NA";
        highestT = "NA";
      } else {
        // T20 Stats

        matchesT = tStats['Mat'];
        runsT = tStats['Runs'];
        halfT = tStats['50'];
        centuryT = tStats['100'];
        highestT = tStats['HS'];
      }
      isData = true;
    }
    return data;
  }

  Widget playerProfile() {
    return FutureBuilder(
      future: fetchJson(players.pid),
      builder: (context, snapShot) {
        if (snapShot.connectionState == ConnectionState.none &&
            snapShot.hasData == null) {
          return Container();
        }
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100 / 2.0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ],
                    color: Colors.lightBlueAccent,
                  ),
                  height: 400.0,
                  child: FlipCard(
                    direction: FlipDirection.VERTICAL,
                    back: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'TEST',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(children: [
                              Column(
                                children: <Widget>[
                                  Text(
                                    'Matches',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$matchesTest')),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Runs',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$runsTest')),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('50s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$halfTest'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('100s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$centuryTest'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Highest',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$highestTest'))
                                ],
                              ),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'ODI',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(children: [
                              Column(
                                children: <Widget>[
                                  Text('Matches',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$matchesOdi'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Runs',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$runsOdi'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('50s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$halfOdi'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('100s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$centuryOdi'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Highest',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$highestOdi'))
                                ],
                              ),
                            ]),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'T20',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Table(
                          border: TableBorder.all(),
                          children: [
                            TableRow(children: [
                              Column(
                                children: <Widget>[
                                  Text('Matches',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$matchesT'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Runs',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$runsT'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('50s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$halfT'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('100s',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$centuryT'))
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('Highest',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text('$highestT'))
                                ],
                              ),
                            ]),
                          ],
                        )
                      ],
                    )),
                    front: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              '$name',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              '$battingStyle',
                              style: TextStyle(fontSize: 22),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              '$country',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              '$playingRole' ?? "NA",
                              style: TextStyle(fontSize: 22),
                            )),
                      ],
                    )),
                  )),
            ),
            Container(
              width: 100,
              height: 100,
              decoration:
                  ShapeDecoration(shape: CircleBorder(), color: Colors.orange),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: CircleBorder(),
                    ),
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: '$imageURL',
                        fit: BoxFit.cover,
                      ),
                    )),
              ),
            )
          ],
        );
      },
    );
  }
}
