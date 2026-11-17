import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/level_model.dart';

abstract class LevelLocalDataSource {
  Future<LevelModel> getLevel({
    required int level,
    required String language,
  });
}

class AssetLevelLocalDataSource implements LevelLocalDataSource {
  final AssetBundle assetBundle;

  const AssetLevelLocalDataSource({required this.assetBundle});

  @override
  Future<LevelModel> getLevel({
    required int level,
    required String language,
  }) async {
    final jsonString = await assetBundle.loadString(
      'lib/data/levels/$language/level_$level.json',
    );
    return LevelModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }
}
