import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../commponents/validator.dart';

class FormDialog {
  final TextEditingController titleText;
  final TextEditingController subTitleText;
  String? dropDownValue;
  final CollectionReference dataToDo;

  FormDialog({
    required this.titleText,
    required this.subTitleText,
    required this.dataToDo,
    required this.dropDownValue,
  });

  showform(
    BuildContext context,
    Function textClear,
    Function addToDo,
    Function handleSubmit,
    String? dropDownValue,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Isi Kegiatan Anda'),
          content: Form(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.maxFinite,
              child: Column(
                verticalDirection: VerticalDirection.down,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Icon(
                      Icons.list_alt,
                      size: 40,
                    ),
                    title: TextFormField(
                      autofocus: true,
                      controller: titleText,
                      decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: Validator().validateUsername,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Icon(
                      Icons.message,
                      size: 40,
                    ),
                    title: TextFormField(
                      controller: subTitleText,
                      decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                      validator: Validator().validateUsername,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: Icon(
                      Icons.label,
                      size: 40,
                    ),
                    title: Container(
                      child: DropdownButtonFormField(
                        hint: Text('Kategori'),
                        decoration: InputDecoration(
                            hintText: 'Kategori',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20))),
                        isExpanded: true,
                        elevation: 0,
                        icon: Icon(
                          Icons.arrow_downward_outlined,
                        ),
                        items: <String>[
                          'Sekolah',
                          'Kantor',
                          'Rumah',
                          'Lain - lain',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          dropDownValue = newValue;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  child: Text('Cancel'),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                handleSubmit();
                addToDo();
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
              ),
            ),
          ],
        );
      },
    ).then((value) => textClear());
  }
}
