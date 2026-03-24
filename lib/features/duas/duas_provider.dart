import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/dua.dart';

final duaCategoriesProvider = FutureProvider<List<DuaCategory>>((ref) async {
  final jsonStr = await rootBundle.loadString('assets/data/duas.json');
  final list = jsonDecode(jsonStr) as List;
  return list
      .map((json) => DuaCategory.fromJson(json as Map<String, dynamic>))
      .toList();
});
