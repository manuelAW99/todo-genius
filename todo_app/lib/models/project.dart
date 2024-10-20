class Project {
  int? id;
  Object? createdAt;
  final String name;
  final String description;
  final bool isArchived;
  final String ownerId;
  final List<String> memberIds;

  Project({
    this.id,
    this.createdAt,
    required this.name,
    required this.description,
    this.isArchived = false,
    required this.ownerId,
    required this.memberIds,
  });

  factory Project.fromMap(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      createdAt: data['createdAt'],
      name: data['name'],
      description: data['description'],
      isArchived: data['isArchived'] ?? false,
      ownerId: data['ownerId'],
      memberIds: List<String>.from(data['memberIds']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isArchived': isArchived,
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }
}
