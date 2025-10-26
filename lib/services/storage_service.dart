import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadLevelData(int level) async {
  String data = await rootBundle.loadString('lib/data/levels/level_$level.json');
  return json.decode(data);
}