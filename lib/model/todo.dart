class Todo {
  final String id;
  final String title;
  final String description;

  const Todo({
    required this.title,
    required this.description,
    required this.id,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map["_id"],
      title: map["title"],
      description: map["description"],
    );
  }
}
