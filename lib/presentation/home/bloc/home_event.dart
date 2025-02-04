part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class LoadTasks extends HomeEvent {
  final String userId;

  LoadTasks(this.userId);

  List<Object> get props => [userId];
}

class AddTask extends HomeEvent {
  final TaskModel task;
  final String userId;

  AddTask(this.task, this.userId);

  List<Object> get props => [task, userId];
}

class UpdateTask extends HomeEvent {
  final String taskId;
  final TaskModel task;

  UpdateTask(this.taskId, this.task);

  List<Object> get props => [taskId, task];
}

class DeleteTask extends HomeEvent {
  final String taskId;

  DeleteTask(this.taskId);

  List<Object> get props => [taskId];
}

class FilterTasks extends HomeEvent {
  final String userId;
  final String? priority;
  final String? status;

  FilterTasks(this.userId, {this.priority, this.status});


  List<Object?> get props => [userId, priority, status];
}

class UpdateTaskStatus extends HomeEvent {
  final String taskId;
  final String status;

  UpdateTaskStatus(this.taskId, this.status);

  List<Object> get props => [taskId, status];
}
