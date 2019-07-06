import 'dart:convert';

import 'package:http/http.dart' as http;

class SiteUtil {

  static dynamic buscarEndereco(String cep) async {
    var response = await http.get(
        "http://cep.republicavirtual.com.br/web_cep.php?cep=" +
            removerCaracteresEspecial(cep) +
            "&formato=json");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erro ao tentar recuperar dados.");
    }
  }

  static String removerCaracteresEspecial(String cep) {
    return cep.replaceAll(new RegExp("[^0-9,]"), "");
  }
}
