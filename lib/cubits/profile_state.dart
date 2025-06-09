part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final bool isEditing;
  final String name;
  final String email;

  const ProfileLoaded({
    required this.isEditing,
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [isEditing, name, email];

  ProfileLoaded copyWith({
    bool? isEditing,
    String? name,
    String? email,
  }) {
    return ProfileLoaded(
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
} 