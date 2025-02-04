import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:taskmanager/onboarding.dart';
import 'package:taskmanager/presentation/auth/bloc/auth_bloc.dart';
import 'package:taskmanager/presentation/home/UI/custom_filter_chip.dart';
import 'package:taskmanager/presentation/home/bloc/home_bloc.dart';
import 'package:taskmanager/services/database/models/task_model.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _taskBloc;
  late final AuthBloc _authBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _taskBloc = context.read<HomeBloc>();
    _authBloc = context.read<AuthBloc>();
    _loadTasks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    _taskBloc.add(LoadTasks(widget.userId));
  }

  Future<void> _showFilterDialog() async {
    String? priority;
    String? status;

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Filter Tasks'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Priorities')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                ],
                onChanged: (String? value) {
                  priority = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Status')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                ],
                onChanged: (String? value) {
                  status = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _taskBloc.add(
                  FilterTasks(
                    widget.userId,
                    priority: priority,
                    status: status,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoggedOut) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Onboarding(),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _loadTasks,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(),
                SliverPersistentHeader(
                  delegate: _FilterHeaderDelegate(
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is TasksLoaded) {
                          return _buildFilterChips(state);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  floating: true,
                ),
                _buildTaskList(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showTaskDialog(),
            label: const Text('Add Task'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(TasksLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            CustomFilterChip(
              label: state.priority == null
                  ? 'All Priorities'
                  : 'Priority: ${state.priority}',
              selected: state.priority != null,
              onSelected: (selected) {
                _taskBloc.add(
                  FilterTasks(
                    widget.userId,
                    priority: selected ? 'high' : null,
                    status: state.status,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            CustomFilterChip(
              label: state.status == null
                  ? 'All Status'
                  : 'Status: ${state.status}',
              selected: state.status != null,
              onSelected: (selected) {
                _taskBloc.add(
                  FilterTasks(
                    widget.userId,
                    priority: state.priority,
                    status: selected ? 'completed' : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTaskDialog({TaskModel? task}) async {
    final titleController = TextEditingController(text: task?.title);
    final descriptionController =
        TextEditingController(text: task?.description);
    String priority = task?.priority ?? 'low';
    DateTime selectedDate = task?.dueDate ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (String? value) {
                  priority = value!;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTask = TaskModel(
                id: task?.id,
                userId: widget.userId,
                title: titleController.text,
                description: descriptionController.text,
                dueDate: selectedDate,
                status: task?.status ?? 'pending',
                priority: priority,
              );

              if (task != null) {
                _taskBloc.add(UpdateTask(task.id!, newTask));
              } else {
                _taskBloc.add(AddTask(newTask, widget.userId));
              }

              Navigator.pop(context);
            },
            child: Text(task == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color chipColor;
    switch (priority.toLowerCase()) {
      case 'high':
        chipColor = Colors.red;
        break;
      case 'medium':
        chipColor = Colors.orange;
        break;
      default:
        chipColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Hi There!',
          textAlign: TextAlign.start,
          style: TextStyle(fontWeight: FontWeight.bold, ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _authBloc.add(SignOut());
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is TaskError) {
          _showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TasksLoaded) {
          if (state.tasks.isEmpty) {
            return SliverFillRemaining(child: _buildEmptyState());
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildTaskCard(state.tasks[index]),
              childCount: state.tasks.length,
            ),
          );
        }
        return const SliverFillRemaining(child: SizedBox());
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first task',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final bool isOverdue =
        task.status != 'completed' && task.dueDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showTaskDialog(task: task),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => _deleteTask(task),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showTaskDialog(task: task),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCheckbox(task),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.status == 'completed'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      _buildPriorityChip(task.priority),
                    ],
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: isOverdue ? Colors.red : Colors.grey[600],
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 4),
                        const Text(
                          'Overdue',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(TaskModel task) {
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: task.status == 'completed',
        activeColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        onChanged: (bool? value) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          _taskBloc.add(
            UpdateTaskStatus(
              task.id!,
              value! ? 'completed' : 'pending',
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    _taskBloc.add(DeleteTask(task.id!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _taskBloc.add(AddTask(task, widget.userId));
          },
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
