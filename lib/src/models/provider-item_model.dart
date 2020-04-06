class ProviderItem {
  String name;
  String password;

  ProviderItem({this.name, this.password});

  ProviderItem.fromString(String savedValue) {
    List<String> parts = savedValue.split('#VP#');
    name = parts[0];
    password = parts[1];
  }

  @override
  String toString() {
    return name + '#VP#' + password;
  }
}
