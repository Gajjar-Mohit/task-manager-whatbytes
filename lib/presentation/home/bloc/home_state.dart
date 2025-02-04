part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

class TaskInitial extends HomeState {}

class TaskLoading extends HomeState {}

class TasksLoaded extends HomeState {
  final List<TaskModel> tasks;
  final String? priority;
  final String? status;

  TasksLoaded(this.tasks, {this.priority, this.status});

  List<Object?> get props => [tasks, priority, status];
}

class TaskError extends HomeState {
  final String message;

  TaskError(this.message);

  List<Object> get props => [message];
}
