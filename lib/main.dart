import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:task/services/save_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TaskModel> taslList = [];
  bool isChecked = false;
  @override
  void initState() {
    getTask();
    super.initState();
  }

  getTask() async {
    await Task().getTaskData().then((value) {
      setState(() {
        taslList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task"),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: taslList.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      background: const Text(
                        "Swape to delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      secondaryBackground: const Text(
                        "Swape to delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onDismissed: (value) async {
                        await Task()
                            .updateTask(taslList[index].id)
                            .then((value) => getTask());
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Data Deleted")));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: Colors.grey.shade300)),
                        child: ExpansionTile(
                          title: Text('${taslList[index].title}'),
                          children: [
                            // CheckboxListTile(
                            //   onChanged: (value) async {
                            //     await Task()
                            //         .updateTask(taslList[index].id)
                            //         .then((value) => getTask());
                            //   },
                            //   value: false,
                            //   title: Text(
                            //     '${taslList[index].title}',
                            //     style: const TextStyle(fontSize: 15),
                            //   ),
                            // ),
                            Text(
                              '${taslList[index].description}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            if (taslList[index].image != null &&
                                taslList[index].image != "")
                              Image.network(
                                "${taslList[index].image}",
                                height: 200,
                              )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddTask()))
              .whenComplete(() => getTask());
        },
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  uploadImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 15),
                child: const Text(
                  'Title',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  isDense: true,
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 15),
                child: const Text(
                  'Description',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  isDense: true,
                  focusedBorder: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  uploadImage();
                },
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width - 20,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10)),
                        child: image == null
                            ? null
                            : Image.file(
                                File(image!.path),
                              ),
                      ),
                      const Positioned(
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (titleController.text.trim().isNotEmpty) {
                    String imagepath = "";
                    if (image != null) {
                      imagepath = await Task().uploadImage(image!);
                    }
                    var task = TaskModel(
                        title: titleController.text,
                        description: descriptionController.text,
                        image: imagepath,
                        createdAt: DateFormat('dd/MM/yyyy hh:mm:ss')
                            .format(DateTime.now()));
                    await Task().createTask(task).then((value) {
                      if (value) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Task not added!")));
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Title required")));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Add',
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
