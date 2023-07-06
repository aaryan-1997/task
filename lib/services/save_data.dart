import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  Future<List<TaskModel>> getTaskData() async {
    List<TaskModel> taslList = [];
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("task");
    try {
      QuerySnapshot querySnapshot = await collectionRef.get();
      for (var document in querySnapshot.docs) {
        if (document.exists) {
          var result = document.data() as Map<String, dynamic>;

          var data = TaskModel.fromJson({
            'id': document.id,
            'title': result['title'],
            'description': result['description'],
            'image': result['image'],
            'createdat': result['createdat'],
          });
          taslList.add(data);
        }
      }
    } catch (e) {
      log("$e");
    }
    return taslList;
  }

  Future<void> updateTask(id) async {
    await FirebaseFirestore.instance.collection("task").doc(id).delete();
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
  String? id;
  String? title;
  String? description;
  String? image;

  String? createdAt;

  TaskModel(
      {this.id, this.title, this.description, this.image, this.createdAt});

  TaskModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];

    image = json['image'];
    createdAt = json['createdat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;

    data['image'] = image;
    data['createdat'] = createdAt;
    return data;
  }
}
