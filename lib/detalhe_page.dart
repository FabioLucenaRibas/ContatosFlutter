import 'dart:async';

import 'package:fabio_lucena_ribas/site_util.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:fabio_lucena_ribas/person.dart';
import 'package:flutter/material.dart';
import 'cadastro_page.dart';

class DetalhePage extends StatefulWidget {
  Person person;

  DetalhePage({this.person});

  @override
  _DetalhePageState createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  bool expand_more = false;

  var _textControllerLogradouro = TextEditingController();
  var _textControllerBairro = TextEditingController();
  var _textControllerCidade = TextEditingController();
  var _textControllerEstado = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: detalharContatoBody(context, widget.person),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.edit),
        label: Text("Editar"),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CadastroPager(
              person: widget.person,
              cadastrar: false,
            );
          }));
        },
        tooltip: 'Cadastrar',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(child: buttonMore()),
    );
  }

  Widget buttonMore() {
    if (expand_more) {
      return IconButton(
        icon: Icon(Icons.expand_less),
        onPressed: () {
          setState(() {
            expand_more = false;
          });
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.expand_more),
        onPressed: () async {
          await obterEndereco();
          setState(() {
            expand_more = true;
          });
        },
      );
    }
  }

  Widget detalharContatoBody(BuildContext context, Person person) {
    if (expand_more) {
      return detalheContatoCompletoBody(context, person);
    } else {
      return detalharContatoResumido(context, person);
    }
  }

  Future<void> obterEndereco() async {
    if (widget.person.cep.isEmpty) {
      limparEndereco();
    } else {
      try {
        var retorno = await SiteUtil.buscarEndereco(widget.person.cep);
        _textControllerLogradouro.text =
            retorno["tipo_logradouro"] + " " + retorno["logradouro"];
        _textControllerBairro.text = retorno["bairro"];
        _textControllerCidade.text = retorno["cidade"];
        _textControllerEstado.text = retorno["uf"];
      } catch (Exception) {
        limparEndereco();
      }
    }
  }

  void limparEndereco() {
    _textControllerLogradouro.clear();
    _textControllerBairro.clear();
    _textControllerCidade.clear();
    _textControllerEstado.clear();
  }

  Widget detalheContatoCompletoBody(BuildContext context, Person person) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          detalharContatoResumido(context, person),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text("Endereço",
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 20,
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: ListTile(
              title: Text(person.cep,
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 20,
                  )),
              subtitle: Text("CEP"),
            ),
          ),
          Divider(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ListTile(
                    title: Text(_textControllerLogradouro.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 20,
                        )),
                    subtitle: Text("Logradouro"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ListTile(
                    title: Text(person.numero.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 20,
                        )),
                    subtitle: Text("Numero"),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ListTile(
                    title: Text(_textControllerCidade.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 20,
                        )),
                    subtitle: Text("Cidade"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: ListTile(
                    title: Text(_textControllerEstado.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 20,
                        )),
                    subtitle: Text("Estado"),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: ListTile(
              title: Text(_textControllerBairro.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w200,
                    fontSize: 20,
                  )),
              subtitle: Text("Bairro"),
            ),
          ),
        ],
      ),
    );
  }

  Widget detalharContatoResumido(BuildContext context, Person person) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    new CircleAvatar(
                        radius: 40.0,
                        child: new Text(
                          person.nomeCompleto[0].toUpperCase(),
                          style: TextStyle(fontSize: 30),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(person.nomeCompleto,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 20,
                )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Divider(),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () =>
                              UrlLauncher.launch("tel://" + person.telefone),
                        ),
                        Text('Ligar'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.sms),
                          onPressed: () =>
                              UrlLauncher.launch("sms://" + person.telefone),
                        ),
                        Text('Enviar SMS'),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.email),
                          onPressed: () =>
                              UrlLauncher.launch("mailto:" + person.email),
                        ),
                        Text('Enviar Email'),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: ListTile(
                  title: Text(person.email,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 20,
                      )),
                  subtitle: Text("E-mail"),
                  leading: Icon(Icons.email),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: ListTile(
                  title: Text(person.telefone,
                      style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 20,
                      )),
                  subtitle: Text("Telefone"),
                  leading: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
