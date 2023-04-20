import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:todo_example/constants.dart';
import 'package:todo_example/model/todo.dart';
import 'package:todo_example/snackbar_utils.dart';
import 'package:todo_example/todo_add_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  bool _isLoading = false;

  Future<List<Todo>> getTodoList() async {
    final response = await Dio().get(Constants.notes);
    List<Todo> items = List.from(response.data["data"])
        .map((e) => Todo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return items;
  }

  @override
  Widget build(BuildContext mainContext) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Todo List"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TodoAddScreen(),
              ),
            );
            if (result == true) {
              setState(() {});
            }
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<Todo>>(
          future: getTodoList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                if (snapshot.data != null) {
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: ValueKey(snapshot.data![index].id),
                        endActionPane: ActionPane(
                          motion: StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) async {
                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final response = await Dio().delete(
                                      "${Constants.notes}/${snapshot.data![index].id}");
                                  if (response.statusCode == 200) {
                                    SnackBarUtils.showMessage(
                                      context: mainContext,
                                      message: "Notes deleted successfully",
                                    );
                                  }
                                } catch (e) {
                                  SnackBarUtils.showMessage(
                                    context: mainContext,
                                    message: "Unable to delete notes",
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(snapshot.data![index].title),
                          subtitle: Text(snapshot.data![index].description),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return TodoAddScreen(
                                    todo: snapshot.data![index],
                                  );
                                },
                              ),
                            );
                            if (result == true) {
                              setState(() {});
                            }
                          },
                        ),
                      );
                    },
                    itemCount: snapshot.data!.length,
                  );
                } else {
                  return const Center(
                    child: Text("No Data Available"),
                  );
                }
              }
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
