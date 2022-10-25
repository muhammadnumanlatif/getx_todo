import 'package:getx_todo/app/data/providers/task/provider.dart';

import '../../models/task.dart';

class TaskRepository{

  TaskProvider taskProvider;

  TaskRepository({required this.taskProvider});

  List<Task> readTasks()=>taskProvider.readTasks();

  void writeTasks(List<Task> tasks)=> taskProvider.writeTasks(tasks);
}