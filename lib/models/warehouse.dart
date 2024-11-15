class Warehouse {
  final String id;
  final String name;
  final String location;
  final String description;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
    };
  }

  static Warehouse fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      description: map['description'],
    );
  }

  Warehouse copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
