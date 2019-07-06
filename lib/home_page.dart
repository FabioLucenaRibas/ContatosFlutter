import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:fabio_lucena_ribas/personDAO.dart';
import 'package:flutter/material.dart';
import 'person.dart';
import 'cadastro_page.dart';
import 'detalhe_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> confirmarExclusao(BuildContext context1, AsyncSnapshot snapshot,
      Person person, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text('Deseja confirmar a exclusão?')],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCELAR'),
              onPressed: () {
                setState(() {
                  snapshot.data.removeAt(index);
                  PersonDAO().insert(person: person);
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                PersonDAO().delete(person.id).whenComplete(() {
                  setState(() {
                    snapshot.data.removeAt(index);
                  });
                });
                Scaffold.of(context1).showSnackBar(new SnackBar(
                  content: new Text(person.nomeCompleto + " foi removido!"),
                  duration: new Duration(seconds: 3),
                  action: new SnackBarAction(
                      label: "Desfazer",
                      onPressed: () {
                        setState(() {
                          PersonDAO().insert(person: person);
                        });
                      }),
                ));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CadastroPager(
                cadastrar: true,
              );
            }));
          });
        },
        tooltip: 'Cadastrar',
        child: Icon(Icons.add),
      ),
      body: Container(
        //decoration: new BoxDecoration(color: Colors.black87),
        child: FutureBuilder(
            future: PersonDAO().get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data != null && snapshot.data.length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(snapshot.data[index].id.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        confirmarExclusao(
                            context, snapshot, snapshot.data[index], index);
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )),
                            )),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )),
                            )),
                          ],
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return DetalhePage(
                              person: snapshot.data[index],
                            );
                          }));

                          /*   showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return DetalhePage(
                                  person: snapshot.data[index],
                                );
                              });*/
                        },
                        child: new ListTile(
                          leading: new CircleAvatar(
                              child: new Text(
                            snapshot.data[index].nomeCompleto[0].toUpperCase(),
                          )),
                          title: new Text(snapshot.data[index].nomeCompleto),
                          subtitle: new Text(snapshot.data[index].email),
                          trailing: IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () => UrlLauncher.launch(
                                "tel://" + snapshot.data[index].telefone),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.autorenew,
                      ),
                    ),
                    Text(
                      "Não existe resultados!",
                    ),
                  ],
                ));
              }
            }),
      ),
    );
  }
}
