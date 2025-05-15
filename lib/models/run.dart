import 'package:equatable/equatable.dart';

class Run extends Equatable {
  final String id;
  final String name;
  final double distance;
  final DateTime date;
  
  const Run({
    required this.id,
    required this.name,
    required this.distance,
    required this.date,
  });
  
  @override
  List<Object> get props => [id, name, distance, date];
  
  Run copyWith({
    String? id,
    String? name,
    double? distance,
    DateTime? date,
  }) {
    return Run(
      id: id ?? this.id,
      name: name ?? this.name,
      distance: distance ?? this.distance,
      date: date ?? this.date,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'date': date.toIso8601String(),
    };
  }
  
  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      name: json['name'] as String,
      distance: json['distance'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }
} 