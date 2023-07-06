import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Task{

  Future<List<TaskModel>> getTaskData() async {
    List<TaskModel> taslList = [];
    final CollectionReference collectionRef =
    FirebaseFirestore.instance.collection("task");
    try {
        QuerySnapshot querySnapshot = await collectionRef.get();
        for (var document in querySnapshot.docs) {
          if (document.exists) {
            var data =
            TaskModel.fromJson(document.data() as Map<String, dynamic>);
            taslList.add(data);
          }
        }

    } catch (e) {
      log("$e");
    }
    return taslList;
  }

  Future<bool> createTask(TaskModel task) async {
    try {
      await FirebaseFirestore.instance
          .collection("task")
          .doc()
          .set(task.toJson());
      return true;
    } catch (e) {
      log("_error_create_task=>$e");
      return false;
    }
  }
}

class TaskModel {
  String? title;
  String? description;
  String? image;
  String? createdAt;

  TaskModel({this.title, this.description, this.image,this.createdAt});

  TaskModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json['image'];
    createdAt = json['createdat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['createdat'] = createdAt;
    return data;
  }
}
