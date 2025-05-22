class Note {
  int? id;
  String title;
  String content;
  String category;
  DateTime createdAt;
  DateTime? dueDate;
  bool isImportant;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.dueDate,
    this.isImportant = false,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isImportant': isImportant ? 1 : 0,
    };

    // Only add id if it's not null
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      isImportant: map['isImportant'] == 1,
    );
  }
}
