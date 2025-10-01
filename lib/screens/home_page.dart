import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = context.read<TaskProvider>();
        provider.addTask(_textController.text);
        _textController.clear();
        
        // Tutup keyboard setelah menambah task
        FocusScope.of(context).unfocus();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            return Text('To-Do List Mini');
          },
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Form untuk menambah task
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan tugas baru',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.add_task),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        if (value.trim().length < 3) {
                          return 'Judul minimal 3 karakter';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ),
          ),
          
          // Filter buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    const Text('Filter: '),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Semua'),
                      selected: provider.filter == TaskFilter.all,
                      onSelected: (_) => provider.setFilter(TaskFilter.all),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Aktif'),
                      selected: provider.filter == TaskFilter.active,
                      onSelected: (_) => provider.setFilter(TaskFilter.active),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Selesai'),
                      selected: provider.filter == TaskFilter.done,
                      onSelected: (_) => provider.setFilter(TaskFilter.done),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Daftar tasks
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = provider.tasks;
                
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getEmptyMessage(provider.filter),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => provider.toggleDone(task.id),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: task.isDone
                                ? Colors.grey[600]
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.active:
        return 'Tidak ada tugas aktif';
      case TaskFilter.done:
        return 'Tidak ada tugas yang selesai';
      case TaskFilter.all:
        return 'Belum ada tugas\nTambahkan tugas pertama Anda!';
    }
  }

  void _deleteTask(task) {
    final provider = context.read<TaskProvider>();
    final removedTask = provider.removeById(task.id);
    
    if (removedTask != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item "${removedTask.title}" dihapus'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              // Masukkan kembali task yang dihapus
              provider.insertAt(0, removedTask);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
