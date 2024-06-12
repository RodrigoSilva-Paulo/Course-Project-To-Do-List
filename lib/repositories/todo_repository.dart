import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

const todoListKey = 'todo_list';

class TodoRepository{

    late SharedPreferences sharedPreferences;

    void saveTodoList(List<Todo> todos){
      final String jsonString = jsonEncode(todos);
      sharedPreferences.setString(todoListKey, jsonString);
    }

    Future<List<Todo>> getTodoList() async {
      sharedPreferences = await SharedPreferences.getInstance();
      final String todosString = sharedPreferences.getString(todoListKey) ?? '[]';
      final List jsonDecoded = jsonDecode(todosString);
      return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
    }

}