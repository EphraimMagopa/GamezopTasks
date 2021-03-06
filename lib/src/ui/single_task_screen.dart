import 'package:flutter/material.dart';
import 'package:gamez_taskop/src/bloc/single_task_screen_bloc.dart';
import 'package:gamez_taskop/src/model/task.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


// This widget appears on screen when a particular task is clicked.
// We can either delete or update a task details here.
// Completing a task functionality is not here because of time constraints.
// But can be easily done!
class SingleTaskScreen extends StatefulWidget {
  final Task task;

  SingleTaskScreen({this.task}) : assert(task != null);

  @override
  _SingleTaskScreenState createState() => _SingleTaskScreenState();
}

class _SingleTaskScreenState extends State<SingleTaskScreen> {
  TextEditingController _titleController, _descriptionController;

  File _image;
  DateTime selectedDate = DateTime.now();
  TimeOfDay dueTime = TimeOfDay.now();
  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");

  Future getImage(bool isCamera) async {
    File image;
    if (isCamera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print('${widget.task.isCompleted}');
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            title: Text('Task Detail'),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  getImage(true);
                },
                icon: Icon(Icons.camera_alt),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.task.imagePath.isEmpty
                  ? Image.network(
                      'https://mdl.ferlicot.fr/files/MDLDemoLibrary/metaphor.png',
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File.fromUri(Uri.parse(widget.task.imagePath)),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  DateTimePickerFormField(
                    format: dateFormat,
                    decoration: InputDecoration(labelText: 'Due Date'),
                    dateOnly: false,
                    initialValue: widget.task.dueDate,
                    initialDate: widget.task.dueDate,
                    onChanged: (date) {
                      selectedDate = date;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          onPressed: () async {
                            deleteTask();
                          },
                          child: Text(
                            'Delete',
                          ),
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                            onPressed: () async {
                              updateTask();
                            },
                            child: Text(
                              'Update',
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.indigo),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ]))
        ],
      ),
    );
  }

  // This method deletes the task.
  deleteTask() async {
    int deletedRowCount = await singleTaskBloc.deleteTask(Task(
      widget.task.taskId,
      _titleController.text,
      _descriptionController.text,
      widget.task.isCompleted,
      '',
      widget.task.createdDate,
      widget.task.dueDate,
      widget.task.finishedDate,
    ));
    if (deletedRowCount > 0) {
      Navigator.of(context).pop();
    }
  }

  // This method updates the task.
  updateTask() async {
    int updatedRowCount = await singleTaskBloc.updateTask(
      Task(
        widget.task.taskId,
        _titleController.text,
        _descriptionController.text,
        widget.task.isCompleted,
        _image == null ? widget.task.imagePath : _image.path,
        widget.task.createdDate,
        selectedDate == null ? widget.task.dueDate : selectedDate,
        widget.task.finishedDate,
      ),
    );
    if (updatedRowCount > 0) {
      // TODO show humane feedback
    }
  }
}
