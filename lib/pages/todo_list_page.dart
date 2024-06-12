import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';

import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) => {setState(() => todos = value)});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'To-do',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.pink[900]),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: todoController,
                            decoration: InputDecoration(
                              labelText: 'Adicione uma Tafera',
                              hintText: 'Ex. Estudar Inglês',
                              errorText: errorText,
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink[900]!)
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.pink[700]!)
                              )
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            String text = todoController.text;
                            if (text.isEmpty) {
                              setState(() {
                                errorText = 'Adicione um título a tarefa!';
                              });
                              return;
                            } else {
                              setState(() {
                                todos.add(Todo(title: text, date: DateTime.now()));
                                errorText = null;
                              });
                              todoRepository.saveTodoList(todos);
                              todoController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.pink[800],
                          ),
                          child: Icon(Icons.add),
                        )
                      ],
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Você possui ${todos.length} tarefas'),
                    ),
                    ElevatedButton(
                      onPressed: showDeleteTodosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.pink[800], padding: EdgeInsets.all(10)),
                      child: Text(
                        'Limpar Tudo',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    int position = todos.indexOf(todo);
    setState(() {
      todos.remove(todo);
      todoRepository.saveTodoList(todos);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.pink[600],
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              todos.insert(position, todo);
            });
          },
        ),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar Tudo?'),
        content: Text('Você tem certeza que deseja deletar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.pink[800]),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                todos.clear();
                todoRepository.saveTodoList(todos);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(backgroundColor: Colors.pink[800]),
            child: Text(
              'Deletar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
