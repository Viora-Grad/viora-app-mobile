import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String selectedCategory;
  final String userName;

  const HomeLoaded({required this.selectedCategory, this.userName = ''});

  HomeLoaded copyWith({String? selectedCategory, String? userName}) {
    return HomeLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, userName];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
