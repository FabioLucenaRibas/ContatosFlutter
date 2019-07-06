import 'package:fabio_lucena_ribas/person.dart';
import 'package:fabio_lucena_ribas/personDAO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'site_util.dart';

class CadastroPager extends StatefulWidget {
  Person person;
  bool cadastrar;
  bool confirmarExclusao;

  CadastroPager({this.person, this.cadastrar});

  @override
  CadastroPagerState createState() {
    return new CadastroPagerState();
  }
}

class CadastroPagerState extends State<CadastroPager> {
  var _textControllerNomeCompleto = TextEditingController();
  var _textControllerEmail = TextEditingController();
  var _textControllerTelefone = MaskedTextController(mask: '(00) 00000-0000');
  var _textControllerCEP = MaskedTextController(mask: '00000-000');
  var _textControllerNumero = TextEditingController();

  var _textControllerLogradouro = TextEditingController();
  var _textControllerBairro = TextEditingController();
  var _textControllerCidade = TextEditingController();
  var _textControllerEstado = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  void initState() {
    _textControllerNomeCompleto =
        TextEditingController(text: widget.person?.nomeCompleto);
    _textControllerEmail = TextEditingController(text: widget.person?.email);
    _textControllerTelefone = MaskedTextController(
        mask: '(00) 00000-0000', text: widget.person?.telefone);
    _textControllerCEP =
        MaskedTextController(mask: '00000-000', text: widget.person?.cep);
    _textControllerNumero =
        TextEditingController(text: widget.person?.numero?.toString());
    super.initState();
  }

  Future<bool> confirmarSalvarAtualizar() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                widget.cadastrar
                    ? Text('Deseja confirmar a inclusão?')
                    : Text('Deseja atualizar o cadastro?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Não'),
              onPressed: () {
                widget.confirmarExclusao = false;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Sim'),
              onPressed: () {
                if (widget.person.id == null || widget.person.id == 0) {
                  PersonDAO().insert(person: widget.person);
                } else {
                  PersonDAO().update(widget.person);
                }
                widget.confirmarExclusao = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Favor informar um e-mail valido';
    else
      return null;
  }

  void obterEndereco() async {
    if (_textControllerCEP.text.isEmpty) {
      limparEndereco();
    } else {
      try {
        var retorno = await SiteUtil.buscarEndereco(_textControllerCEP.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              widget.cadastrar ? Text("Cadastrar") : Text("Atualizar cadastro"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: widget.cadastrar ? Icon(Icons.check) : Icon(Icons.autorenew),
          label: widget.cadastrar ? Text("Salvar") : Text("Atualizar"),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              widget.person = new Person(
                  id: widget.person?.id,
                  nomeCompleto: _textControllerNomeCompleto.text,
                  email: _textControllerEmail.text,
                  telefone: _textControllerTelefone.text,
                  cep: _textControllerCEP.text,
                  numero: int.parse(_textControllerNumero.text));
              await confirmarSalvarAtualizar();
              if (widget.confirmarExclusao) {
                Navigator.pop(context);
              }
            } else {
              _autoValidate = true;
            }
          },
          tooltip: widget.cadastrar == true ? 'Salvar' : 'Atualizar',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: Container(
          height: 50,
        ),
        body: cadastroContatoBody(context));
  }

  Widget cadastroContatoBody(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Column(
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  maxLength: 100,
                  controller: _textControllerNomeCompleto,
                  decoration: InputDecoration(labelText: 'Nome Completo'),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Informar seu nome';
                    }
                    return null;
                  },
                ),
                leading: Icon(Icons.account_circle),
              ),
              ListTile(
                title: TextFormField(
                  controller: _textControllerEmail,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: validateEmail,
                ),
                leading: Icon(Icons.email),
              ),
              ListTile(
                title: TextFormField(
                  controller: _textControllerTelefone,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  validator: (value) {
                    if (value.isEmpty || value.length < 14) {
                      return 'Informar seu Telefone';
                    }
                    return null;
                  },
                ),
                leading: Icon(Icons.phone),
              ),
              Divider(),
              ListTile(
                title: Text("Endereço",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 20,
                    )),
                leading: Icon(Icons.location_on),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        autovalidate: true,
                        controller: _textControllerCEP,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'CEP'),
                        validator: (value) {
                          if (_autoValidate &&
                              (value.isEmpty || value.length < 9)) {
                            return 'Informar um CEP valido';
                          }

                          if (value.isEmpty || value.length == 9) {
                            obterEndereco();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _textControllerNumero,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Numero'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Informar um numro';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          controller: _textControllerLogradouro,
                          decoration: InputDecoration(labelText: 'Logradouro'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          enabled: false,
                          controller: _textControllerBairro,
                          decoration: InputDecoration(labelText: 'Bairro'),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                enabled: false,
                                controller: _textControllerCidade,
                                decoration:
                                    InputDecoration(labelText: 'Cidade'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                enabled: false,
                                controller: _textControllerEstado,
                                decoration:
                                    InputDecoration(labelText: 'Estado'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
