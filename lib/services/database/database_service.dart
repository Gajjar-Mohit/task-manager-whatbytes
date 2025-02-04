import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:taskmanager/core/exceptions.dart';
import 'package:taskmanager/services/database/models/task_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<DatabaseException, String>> createTask(
      TaskModel task, String userId) async {
    try {
      final DocumentReference documentReference =
          await _firestore.collection('tasks').add({
        'userId': userId,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate,
        'status': task.status,
        'priority': task.priority,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return right(documentReference.id);
    } on FirebaseException catch (e) {
      print(e.message);
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, List<TaskModel>>> getTasks(
      String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .get();

      final List<TaskModel> tasks = querySnapshot.docs
          .map((doc) => TaskModel.fromJson(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id},
              ))
          .toList();

      return right(tasks);
    } on FirebaseException catch (e) {
      print(e.message);
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, List<TaskModel>>> getFilteredTasks(
      String userId,
      {String? priority,
      String? status,
      DateTime? startDate,
      DateTime? endDate}) async {
    try {
      Query query =
          _firestore.collection('tasks').where('userId', isEqualTo: userId);

      if (priority != null && priority != 'all') {
        query = query.where('priority', isEqualTo: priority);
      }

      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null && endDate != null) {
        query = query
            .where('dueDate', isGreaterThanOrEqualTo: startDate)
            .where('dueDate', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('dueDate', descending: false);

      final QuerySnapshot querySnapshot = await query.get();

      final List<TaskModel> tasks = querySnapshot.docs
          .map((doc) => TaskModel.fromJson(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id},
              ))
          .toList();

      return right(tasks);
    } on FirebaseException catch (e) {
      print(e.message);
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, Unit>> updateTask(
      String taskId, TaskModel task) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate,
        'status': task.status,
        'priority': task.priority,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (e) {
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, Unit>> updateTaskStatus(
      String taskId, String status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (e) {
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, Unit>> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      return right(unit);
    } on FirebaseException catch (e) {
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Future<Either<DatabaseException, TaskModel>> getTaskById(
      String taskId) async {
    try {
      final DocumentSnapshot documentSnapshot =
          await _firestore.collection('tasks').doc(taskId).get();

      if (!documentSnapshot.exists) {
        return left(DatabaseException('Task not found'));
      }

      final TaskModel task = TaskModel.fromJson({
        ...documentSnapshot.data() as Map<String, dynamic>,
        'id': documentSnapshot.id
      });

      return right(task);
    } on FirebaseException catch (e) {
      return left(DatabaseException(e.message ?? 'Something went wrong'));
    }
  }

  Stream<Either<DatabaseException, List<TaskModel>>> getTasksStream(
      String userId) {
    try {
      return _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate', descending: false)
          .snapshots()
          .map((snapshot) {
        try {
          final List<TaskModel> tasks = snapshot.docs
              .map((doc) => TaskModel.fromJson(
                    {...doc.data(), 'id': doc.id},
                  ))
              .toList();
          return right(tasks);
        } catch (e) {
          return left(DatabaseException('Error parsing tasks'));
        }
      });
    } catch (e) {
      return Stream.value(
          left(DatabaseException('Error getting tasks stream')));
    }
  }

  Stream<Either<DatabaseException, List<TaskModel>>> getFilteredTasksStream(
      String userId,
      {String? priority,
      String? status,
      DateTime? startDate,
      DateTime? endDate}) {
    try {
      Query query =
          _firestore.collection('tasks').where('userId', isEqualTo: userId);

      if (priority != null && priority != 'all') {
        query = query.where('priority', isEqualTo: priority);
      }

      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null && endDate != null) {
        query = query
            .where('dueDate', isGreaterThanOrEqualTo: startDate)
            .where('dueDate', isLessThanOrEqualTo: endDate);
      }

      query = query.orderBy('dueDate', descending: false);

      return query.snapshots().map((snapshot) {
        try {
          final List<TaskModel> tasks = snapshot.docs
              .map((doc) => TaskModel.fromJson(
                    {...doc.data() as Map<String, dynamic>, 'id': doc.id},
                  ))
              .toList();
          return right(tasks);
        } catch (e) {
          return left(DatabaseException('Error parsing tasks'));
        }
      });
    } catch (e) {
      return Stream.value(
          left(DatabaseException('Error getting filtered tasks stream')));
    }
  }
}
