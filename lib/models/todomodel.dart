class ToDoModel {
  String? title;
  String? deskripsi;
  String? kategori;
  bool isLove;

  ToDoModel({
    this.title,
    this.deskripsi,
    this.kategori,
    this.isLove = false,
  });

  factory ToDoModel.fromMap(Map<String, dynamic> data) {
    return ToDoModel(
      title: data['Title'],
      deskripsi: data['Deskripsi'],
      kategori: data['Kategori'],
      isLove: data['IsLove'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Title': title,
      'Deskripsi': deskripsi,
      'Kategori': kategori,
      'IsLove': isLove,
    };
  }
}
