class User {
  int id;
  String name;
  String passwordHash;

  User({this.name, this.passwordHash});

  // convenience constructor to create a Word object
  User.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    passwordHash = map["passwordHash"];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{"name": name, "passwordHash": passwordHash};
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }
}
