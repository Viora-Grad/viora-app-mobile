import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class ChangeCategoryEvent extends HomeEvent {
  final String categoryName;
  const ChangeCategoryEvent(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}