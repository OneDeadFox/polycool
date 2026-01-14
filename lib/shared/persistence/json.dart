import 'dart:convert';

String encodeJson(Map<String, dynamic> map) => jsonEncode(map);

Map<String, dynamic> decodeJson(String raw) =>
    (jsonDecode(raw) as Map).cast<String, dynamic>();

String encodeJsonList(List<Map<String, dynamic>> items) => jsonEncode(items);

List<Map<String, dynamic>> decodeJsonList(String raw) =>
    (jsonDecode(raw) as List).map((e) => (e as Map).cast<String, dynamic>()).toList();
