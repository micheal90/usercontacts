import 'package:usercontacts/constants.dart';

class UserModel {
  int id;
  String name;
  String email;
  String phone;
  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
  });
  UserModel.fromJson(Map<String, dynamic> map) {
    if (map == null) return;
    id = map[columnId];
    name = map[columnName];
    email = map[columnEmail];
    phone = map[columnPhone];
  }
  toJson() {
    return {
      columnId: id,
      columnName: name,
      columnEmail: email,
      columnPhone: phone,
    };
  }
}
