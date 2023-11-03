import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list2/commponents/validator.dart';
import 'package:todo_list2/models/todomodel.dart';
import 'package:todo_list2/widgets/editform.dart';
import 'package:todo_list2/widgets/formwidget.dart';
import 'package:todo_list2/widgets/searchwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference dataToDo =
      FirebaseFirestore.instance.collection('Activity');

  GlobalKey<FormState> formKeySignin = GlobalKey<FormState>();
  TextEditingController titleText = TextEditingController();
  TextEditingController subTitleText = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isFavorite = false;
  final formKey = GlobalKey<FormState>();
  String? dropDownValue = '';
  List<DocumentSnapshot> todoActivity = [];

  textClear() {
    titleText.clear();
    subTitleText.clear();
  }

  late FormDialog formDialog;
  void showForm() {
    formDialog.showform(
        context, textClear, addToDo, handleSubmit, dropDownValue);
  }

  void addToDo() {
    dataToDo
        .add({
          'Title': titleText.text,
          'Deskripsi': subTitleText.text,
          'Kategori': dropDownValue.toString()
        })
        .then((value) => print("Activity Added"))
        .catchError((error) => print("Failed to add Activity: $error"));
  }

  Future<void> deleteActivity(String id) {
    return dataToDo.firestore
        .collection('Activity')
        .doc(id)
        .delete()
        .then((value) => print("Activity Deleted"))
        .catchError((error) => print("Failed to delete Activity: $error"));
  }

  Future<void> updateActivity(String id) async {
    return dataToDo.firestore
        .collection('Activity')
        .doc(id)
        .update({
          'Title': titleText.text,
          'Deskripsi': subTitleText.text,
          'Kategori': dropDownValue.toString(),
        })
        .then((value) => print("Activity Updated"))
        .catchError((error) => print("Failed to Update Activity: $error"));
  }

  handleSubmit() {
    print(titleText.text);
    print(subTitleText.text);
    print(dropDownValue);
  }

  final Stream<QuerySnapshot> streamactivity =
      FirebaseFirestore.instance.collection('Activity').snapshots();

  Future<void> searchActivity(String searchGet) async {
    searchGet = searchGet.toLowerCase();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Activity')
        .where(('Title', arrayContains: searchGet)).get();

    print("Search Get: $searchGet");
    print("Query Snapshot: ${querySnapshot.docs.length} documents found");

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        todoActivity = querySnapshot.docs;
      });
    } else {
      setState(() {
        todoActivity.clear();
      });
    }
  }

  @override
  void initState() {
    formDialog = FormDialog(
      dropDownValue: dropDownValue.toString(),
      titleText: titleText,
      subTitleText: subTitleText,
      dataToDo: dataToDo,
    );
    textClear();
    searchController.addListener;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Color> colorsTag = [
    Colors.redAccent,
    Colors.teal,
    Colors.green,
    Colors.grey
  ];

  @override
  Widget build(BuildContext context) {
    DateTime selectDate = DateTime.now();
    return Scaffold(
        appBar: AppBar(
          title: Text('TO DO APP'),
          centerTitle: true,
          actions: [
            IconButton(
                padding: EdgeInsets.symmetric(horizontal: 30),
                onPressed: () {
                  showDatePicker(
                      context: context,
                      initialDate: selectDate,
                      firstDate: selectDate,
                      lastDate: DateTime(2500));
                },
                icon: Icon(
                  Icons.date_range_outlined,
                  size: 40,
                ))
          ],
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              showForm();
            });
          },
          child: Icon(
            Icons.add_circle_outline,
            size: 50,
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.antiAlias,
          shape: CircularNotchedRectangle(),
          color: Theme.of(context).primaryColor.withAlpha(255),
          elevation: 0,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(0),
            selectedItemColor: Theme.of(context).colorScheme.onSurface,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded,
                      size: 40,
                      color: Theme.of(context).colorScheme.onBackground),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.label,
                      size: 40,
                      color: Theme.of(context).colorScheme.onBackground),
                  label: 'Edit')
            ],
          ),
        ),
        body: Column(
          children: [
            SearchWidget(
                searchController: searchController, onSearch: searchActivity),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: streamactivity,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }

                  return ListView(
                    padding: const EdgeInsets.all(5),
                    children: (todoActivity.isNotEmpty
                            ? todoActivity
                            : snapshot.data!.docs)
                        .map((DocumentSnapshot document) {
                      ToDoModel toDoModel = ToDoModel.fromMap(
                          document.data() as Map<String, dynamic>);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ListTile(
                            style: ListTileStyle.list,
                            title: Text(toDoModel.title ?? ''),
                            subtitle: Text(toDoModel.deskripsi ?? ''),
                            leading: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color:
                                    toDoModel.isLove ? Colors.red : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    toDoModel.isLove
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: toDoModel.isLove ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      toDoModel.isLove = !toDoModel.isLove;
                                    });
                                    dataToDo
                                        .doc(document.id)
                                        .update({'IsLove': toDoModel.isLove});
                                  },
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text("Edit"),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text("Delete"),
                                      ),
                                    ];
                                  },
                                  onSelected: (value) async {
                                    if (value == 1) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            alignment: Alignment.center,
                                            title: const Text(
                                              'Delete Task?',
                                              textAlign: TextAlign.center,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Are You Sure Want To Delete This Item?',
                                                ),
                                                const SizedBox(
                                                  height: 25,
                                                ),
                                                Text(
                                                  toDoModel.title ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    deleteActivity(document.id);
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        duration: Duration(
                                                            seconds: 1),
                                                        content: Text(
                                                          'You Have Successfully Deleted an Activity',
                                                        ),
                                                      ),
                                                    );
                                                  });
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (value == 0) {
                                      if (toDoModel != null) {
                                        titleText.text = toDoModel.title ?? '';
                                        subTitleText.text =
                                            toDoModel.deskripsi ?? '';
                                        dropDownValue =
                                            toDoModel.kategori ?? '';

                                        showEditDialog(
                                          context,
                                          titleText,
                                          subTitleText,
                                          dropDownValue!,
                                          document.id,
                                          updateActivity,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
