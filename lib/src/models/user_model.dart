class User {
  int id;
  String name;
  String passwordHash;

  User({
    this.name,
    this.passwordHash,
  });

  User.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    name = map["name"];
    passwordHash = map["passwordHash"];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "name": name,
      "passwordHash": passwordHash,
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}
