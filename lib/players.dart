import 'dart:convert';
import 'package:flutter/services.dart';

class Players {
  int pid;
  String name;
  String fullname;

  Players({
    this.pid,
    this.name,
    this.fullname
  });

  factory Players.fromJson(Map<String, dynamic> parsedJson) {
    return Players(
        pid: parsedJson['pid'],
        name: parsedJson['name'] as String,
        fullname: parsedJson['fullName'] as String
    );
  }
}

class PlayerViewModel {
  static List<Players> players;

  static Future loadPlayers() async {
    try {
      players = new List<Players>();
      String jsonString = await rootBundle.loadString('assets/players.json');
      Map parsedJson = json.decode(jsonString);
      var categoryJson = parsedJson['data'] as List;
      for (int i = 0; i < categoryJson.length; i++) {
        players.add(new Players.fromJson(categoryJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}
