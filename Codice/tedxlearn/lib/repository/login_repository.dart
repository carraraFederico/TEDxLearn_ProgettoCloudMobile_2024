import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> checkLogin(String email, String password) async {
  var url = Uri.parse('https://ok6e0ffbt4.execute-api.us-east-1.amazonaws.com/default/Get_Login');

  try {
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return 'Login effettuato correttamente';
    } else {
      return 'Errore nei dati del login, controlla i campi!';
    }
  } catch (e) {
    return 'Errore durante la richiesta HTTP: $e';
  }
}
