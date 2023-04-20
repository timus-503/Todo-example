import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:todo_example/constants.dart';
import 'package:todo_example/custom_text_field.dart';
import 'package:todo_example/model/todo.dart';
import 'package:todo_example/snackbar_utils.dart';

class TodoAddScreen extends StatefulWidget {
  final Todo? todo;
  const TodoAddScreen({super.key, this.todo});

  @override
  State<TodoAddScreen> createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
  bool _isLoading = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
    }
  }

  onUpdate() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final Map<String, dynamic> data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
      };
      final response =
          await Dio().put("${Constants.notes}/${widget.todo?.id}", data: data);
      if (response.statusCode == 200) {
        SnackBarUtils.showMessage(
          context: context,
          message: "Notes Updated Successfully",
        );
        _titleController.clear();
        _descriptionController.clear();
        Navigator.of(context).pop(true);
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response!.data["message"])),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  onSave() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final Map<String, dynamic> data = {
        "title": _titleController.text,
        "description": _descriptionController.text,
      };
      final response = await Dio().post(Constants.notes, data: data);
      if (response.statusCode == 200) {
        SnackBarUtils.showMessage(
          context: context,
          message: "Notes Added Successfully",
        );
        _titleController.clear();
        _descriptionController.clear();
        Navigator.of(context).pop(true);
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.response!.data["message"])),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add TODO"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            CustomTextField(
              label: "Title",
              hintText: "Title",
              controller: _titleController,
            ),
            CustomTextField(
              label: "Description",
              hintText: "Description",
              controller: _descriptionController,
            ),
            MaterialButton(
              onPressed: () async {
                if (widget.todo != null) {
                  onUpdate();
                } else {
                  onSave();
                }
              },
              child: Text(widget.todo != null ? "Update" : "Save"),
            )
          ],
        ),
      ),
    );
  }
}
