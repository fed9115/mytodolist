import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      accentColor: Colors.orange,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // List todos = [];
  String todoTitle = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(todoTitle);
    // Map
    Map<String, String> todos = {"todoTitle": todoTitle};
    documentReference.set(todos).whenComplete(() => print("$todoTitle created"));
  }

  deleteTodos(item) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("MyTodos").doc(item);
    documentReference.delete().whenComplete(() => print("$item deleted"));
  }
/*
  @override
  void initState() {
    super.initState();
    todos.add("Item1");
    todos.add("Item2");
    todos.add("Item3");
    todos.add("Item4");
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("mytodos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  title: Text("Add Todolist"),
                  content: TextField(
                    onChanged: (String value) {
                      todoTitle = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          createTodos();
                          /*setState(() {
                            todos.add(input);
                          });*/
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
          builder: (context, snapshots) {
            if(snapshots.data == null) return CircularProgressIndicator();
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data.docs[index];
                  return Dismissible(
                    onDismissed: (direction){
                      deleteTodos(documentSnapshot["todoTitle"]);
                    },
                      key: Key(documentSnapshot["todoTitle"]),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          title: Text(documentSnapshot["todoTitle"]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              /*setState(() {
                                todos.removeAt(index);
                              });*/
                              deleteTodos(documentSnapshot["todoTitle"]);
                            },
                          ),
                        ),
                      ));
                });
          }),
    );
  }
}
