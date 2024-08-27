class SimpleHostFile {
  final String fileName;
  String remark;

  SimpleHostFile({
    required this.fileName,
    required this.remark,
  });

  factory SimpleHostFile.fromJson(Map<String, dynamic> json) {
    return SimpleHostFile(
      fileName: json['fileName'] as String,
      remark: json['remark'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'remark': remark,
    };
  }
}

class SimpleHostFileHistory {
  final String fileName;
  final String path;

  SimpleHostFileHistory({
    required this.fileName,
    required this.path,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SimpleHostFileHistory) return false;

    return fileName == other.fileName && path == other.path;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^ path.hashCode;
  }
}