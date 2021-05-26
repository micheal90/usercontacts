import 'package:flutter/material.dart';

import 'package:usercontacts/helper/database_helper.dart';
import 'package:usercontacts/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseHelper dbHelper;
  GlobalKey<FormState> _formKey = GlobalKey();
  List<UserModel> userList = [];
  String name, phone, email;
  bool flag = false;
  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.db;
    dbHelper.getAllUsers().then((value) {
      setState(() {
        userList = value;
        print(userList[0].id);
      });
    });
  }

  void addUser(context) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    dbHelper
        .insert(UserModel(name: name, email: email, phone: phone))
        .then((value) {
      print('inserted');
      Navigator.pop(context);
      dbHelper.getAllUsers().then((value) {
        setState(() {
          userList = value;
          name = '';
          phone = '';
          email = '';
        });
      });
    });
  }

  void editUser(context, int id) async {
    if (!_formKey.currentState.validate()) return;
    _formKey.currentState.save();
    await dbHelper
        .update(UserModel(id: id, name: name, email: email, phone: phone))
        .then((value) {
      print('Updated');
      Navigator.pop(context);
      dbHelper.getAllUsers().then((value) {
        setState(() {
          userList = value;
          name = '';
          phone = '';
          email = '';
          flag = false;
        });
      });
    });
  }

  void floatingButtonFun(context, {UserModel user}) {
    if (user != null) {
      name = user.name;
      email = user.email;
      phone = user.phone;
      flag = true;
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: flag
                  ? Text(
                      "Edit User",
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      "Add New User",
                      textAlign: TextAlign.center,
                    ),
              content: Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                            hintText: "Name",
                            border: InputBorder.none,
                            fillColor: Colors.grey.shade400),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter name please";
                          } else
                            return null;
                        },
                        onSaved: (value) {
                          name = value;
                        },
                      ),
                      TextFormField(
                        initialValue: email,
                        decoration: InputDecoration(
                            hintText: "Email",
                            border: InputBorder.none,
                            fillColor: Colors.grey.shade400),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter Email please";
                          } else
                            return null;
                        },
                        onSaved: (value) {
                          email = value;
                        },
                      ),
                      TextFormField(
                        initialValue: phone,
                        decoration: InputDecoration(
                            hintText: "Phone",
                            border: InputBorder.none,
                            fillColor: Colors.grey.shade400),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter Phone please";
                          } else
                            return null;
                        },
                        onSaved: (value) {
                          phone = value;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      OutlinedButton(
                        onPressed: () => flag
                            ? editUser(context, user.id)
                            : addUser(context),
                        child: flag ? Text('Edit User') : Text('Add User'),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.red,
        title: Text('Contacts'),
      ),
      body: userList.isEmpty
          ? Center(
              child: Text(
                'No Contacts added till now!',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) => Dismissible(
                    direction: DismissDirection.endToStart,
                    key: UniqueKey(),
                    confirmDismiss: (direction) {
                      return showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            title: Text('Are You Sure!'),
                            content: Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "No",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.red),
                                    )),
                                TextButton(
                                    onPressed: () async {
                                      await dbHelper
                                          .deleteUser(userList[index].id);
                                      dbHelper.getAllUsers().then((value) {
                                        setState(() {
                                          userList = value;
                                        });
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.red),
                                    )),
                              ],
                            )),
                      );
                    },
                    background: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        padding: EdgeInsets.only(right: 15),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: Card(
                        child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade400,
                        radius: 25,
                        child: FittedBox(
                            child: Text(
                          userList[index].name.substring(0, 1),
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        )),
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              userList[index].name,
                              softWrap: true,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text(userList[index].phone),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: FittedBox(
                              child: Text(
                                userList[index].email,
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          floatingButtonFun(context, user: userList[index]);
                        },
                      ),
                    )),
                  )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () => floatingButtonFun(
          context,
        ),
      ),
    );
  }
}
