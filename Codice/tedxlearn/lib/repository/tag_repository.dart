import 'package:http/http.dart' as http;
import 'package:tedxlearn/models/tag.dart';
import 'dart:convert';

Future<List<Tag>> getAllTags(int page) async {
  var url = Uri.parse('https://ly1h0n86h2.execute-api.us-east-1.amazonaws.com/default/Get_All_Tag');

  try {
    final http.Response response = await http.post(url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, Object>{
        'page': page,
      }),
    );

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      var tags = list.map((model) => Tag.fromJSON(model)).toList();
      return tags;
    } else {
      throw Exception('Failed to load tags');
    }
  } catch (e) {
    throw Exception('Failed to load tags');
  }
}
