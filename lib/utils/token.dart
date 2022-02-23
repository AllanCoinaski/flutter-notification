import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

///Função para que recebe o token e obtém detalhes do dispositivo para a API
setToken(token) async {
  //instanciando a classe para trabalhar com sharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? prefsToken = prefs.getString('pushToken');
  bool? prefsSent = prefs.getBool('tokenSent');

  if (prefsToken != token || (prefsToken == token && prefsSent == false)) {
    //Obtendo detalhes do dispositivo em uso
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? brand;
    String? model;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Rodando no  ${androidInfo.model}');
      model = androidInfo.model;
      brand = androidInfo.brand;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Rodando no  ${iosInfo.model}');
      model = iosInfo.utsname.machine;
      brand = 'Apple';
    }
    //Chamar sua API
    //await sentTokenApi();
  }
}

///Função para enviar para a API o token e os detalhes dos dispositivo, implementar conforme sua API
sentTokenApi() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final response = await http.post(Uri.parse('SUA API'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, String>{'token': 'SEU TOKEN DE API' ?? ''}));
  if (response.statusCode != 200) {
    throw Exception('Falha ao enviar dados');
  } else {
    prefs.setBool('tokenSent', true);
  }
}
