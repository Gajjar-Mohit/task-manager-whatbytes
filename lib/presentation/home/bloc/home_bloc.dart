import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:taskmanager/services/database/database_service.dart';
import 'package:taskmanager/services/database/models/task_model.dart';

part 'home_event.dart';
part 'home_state.dart';
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DatabaseService _databaseService = DatabaseService();

  HomeBloc() : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<HomeState> emit) async {
    emit(TaskLoading());
    final result = await _databaseService.getTasks(event.userId);

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onAddTask(AddTask event, Emitter<HomeState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      final result =
          await _databaseService.createTask(event.task, event.userId);

      await result.fold(
        (failure) async {
          emit(TaskError(failure.message));
          
          emit(currentState);
        },
        (_) async {
          
          final reloadResult = await _databaseService.getTasks(event.userId);

          reloadResult.fold(
            (failure) => emit(TaskError(failure.message)),
            (tasks) => emit(TasksLoaded(tasks)),
          );
        },
      );
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<HomeState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      final result =
          await _databaseService.updateTask(event.taskId, event.task);

      await result.fold(
        (failure) async {
          emit(TaskError(failure.message));
          
          emit(currentState);
        },
        (_) async {
          
          final reloadResult =
              await _databaseService.getTasks(event.task.userId);

          reloadResult.fold(
            (failure) => emit(TaskError(failure.message)),
            (tasks) => emit(TasksLoaded(tasks,
                priority: currentState.priority, status: currentState.status)),
          );
        },
      );
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<HomeState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      final result = await _databaseService.deleteTask(event.taskId);

      await result.fold(
        (failure) async {
          emit(TaskError(failure.message));
          
          emit(currentState);
        },
        (_) async {
          
          final reloadResult =
              await _databaseService.getTasks(currentState.tasks.first.userId);

          reloadResult.fold(
            (failure) => emit(TaskError(failure.message)),
            (tasks) => emit(TasksLoaded(tasks,
                priority: currentState.priority, status: currentState.status)),
          );
        },
      );
    }
  }

  Future<void> _onFilterTasks(
      FilterTasks event, Emitter<HomeState> emit) async {
    final result = await _databaseService.getFilteredTasks(
      event.userId,
      priority: event.priority,
      status: event.status,
    );

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(
          TasksLoaded(tasks, priority: event.priority, status: event.status)),
    );
  }

  Future<void> _onUpdateTaskStatus(
      UpdateTaskStatus event, Emitter<HomeState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      final result = await _databaseService.updateTaskStatus(
        event.taskId,
        event.status,
      );

      await result.fold(
        (failure) async {
          emit(TaskError(failure.message));
          
          emit(currentState);
        },
        (_) async {
          
          final reloadResult =
              await _databaseService.getTasks(currentState.tasks.first.userId);

          reloadResult.fold(
            (failure) => emit(TaskError(failure.message)),
            (tasks) => emit(TasksLoaded(tasks,
                priority: currentState.priority, status: currentState.status)),
          );
        },
      );
    }
  }
}
