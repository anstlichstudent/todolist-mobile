import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Week 5 To-do',
        theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true
        ),
        home: const HomePage(),
      ),
    );
  }
}

class _SmokeTestPage extends StatelessWidget {
  const _SmokeTestPage();

  @override
  Widget build(BuildContext context) {
    final active = context.watch<TaskProvider>().activeCount;
    return Scaffold(
      appBar: AppBar(title: Text('Smoke Test — Aktif: $active')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<TaskProvider>().addTask('Tugas dummy');
          },
          child: const Text('Tambah 1 task dummy'),
        ),
      ),
    );
  }
}
