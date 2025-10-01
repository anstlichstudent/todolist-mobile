import 'package:flutter/foundation.dart';
import '../models/task.dart';

//filter
enum TaskFilter { all, active, done }

//brain
class TaskProvider extends ChangeNotifier{
  final List<Task> _tasks = []; //data mentah
  TaskFilter _filter = TaskFilter.all;

  List<Task> get tasks{
    switch(_filter){
      case TaskFilter.active:
        return _tasks.where((t) => !t.isDone).toList();
      case TaskFilter.done:
        return _tasks.where((t) => t.isDone).toList();
      case TaskFilter.all:
        return List.unmodifiable(_tasks);
    }
  }

  // active filter?
  TaskFilter get filter => _filter;

  // count task
  int get activeCount => _tasks.where((t) => !t.isDone).length;

  void setFilter(TaskFilter filter){
    _filter = filter;
    notifyListeners();
  }

  void addTask(String title){
    final clean = title.trim();
    if(clean.length < 3){
      throw ArgumentError("Judul minimal 3 karakter"); 
    }

    _tasks.add(Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(), 
      title: clean
    ));

    notifyListeners();
  }

  void toggleDone(String id){
    final idx = _tasks.lastIndexWhere((t) => t.id == id);
    if(idx == -1) return; // kalo ndd diam

    _tasks[idx].isDone = !_tasks[idx].isDone;
    notifyListeners();
  }

  Task? removeById(String id){
    final idx = _tasks.indexWhere((t) => t.id == id);
    if(idx == -1) return null;
    final removed = _tasks.removeAt(idx);

    notifyListeners();
    return removed;
  }

  void insertAt(int index, Task task){
    _tasks.insert(index.clamp(0, _tasks.length), task);
    notifyListeners();
  }
}