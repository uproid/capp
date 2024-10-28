class CappOption {
  String name;
  String shortName;
  String description;
  String value;
  bool existsInArgs = false;

  CappOption(
      {required this.name,
      this.description = '',
      this.value = '',
      this.shortName = ''});
}
