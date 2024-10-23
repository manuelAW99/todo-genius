/// Project model class.
/// Used to store project information.
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

  /// Convert a map to a project object.
  /// The map is used to store the project in the database.
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

  /// Convert a project object to a map.
  /// The map is used to store the project in the database.
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

/// An empty project object.
/// Used to check if the user has a project or not.
Project emptyProject = Project(
  id: -1,
  name: '',
  createdAt: '',
  description: '',
  ownerId: '',
  memberIds: [],
  isArchived: false,
);
