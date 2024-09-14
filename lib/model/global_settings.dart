class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();

  factory GlobalSettings() {
    return _instance;
  }

  GlobalSettings._internal();

  bool isSimple = false;
}
