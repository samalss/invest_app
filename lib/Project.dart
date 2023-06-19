import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String projectId;
  final String projectName;
  final String projectDescription;
  final int projectTotalCost;
  final int projectCurrentCost;
  final String userId;
  final bool verified;
  final Timestamp project_created_date;
  final String verification_documents;
  final int interest;
  late double total;
  late String img;
  final String short_description;

  Project({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.projectTotalCost,
    required this.projectCurrentCost,
    required this.userId,
    required this.verified,
    required this.project_created_date,
    required this.verification_documents,
    required this.interest,
    required this.img,
    required this.short_description,
  });
  Project.forAnalytic({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.projectTotalCost,
    required this.projectCurrentCost,
    required this.userId,
    required this.verified,
    required this.project_created_date,
    required this.verification_documents,
    required this.interest,
    required this.total,
    required this.short_description
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      projectName: data['project_name'] ?? '',
      projectDescription: data['project_description'] ?? '',
      projectTotalCost: data['project_total_cost'] ?? 0,
      projectCurrentCost: data['project_current_cost'] ?? 0,
      userId: data['user_id'] ?? "",
      verified: data['user_id'] ?? false,
      project_created_date: data['project_created_date'] ?? "",
      verification_documents: data['verification_documents'] ?? "",
      interest: data['interest'] ?? "",
      projectId: data['projectId'] ?? "",
      img: data['img'] ?? "",
      short_description: data['short_description'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'project_name': projectName,
      'project_description': projectDescription,
      'project_total_cost': projectTotalCost,
      'project_current_cost': projectCurrentCost,
      'user_id': userId,
      'verified': verified,
      'interest': interest,
      'projectId': projectId,
      'img': img,
      'short_description': short_description,
    };
  }

  // Convert a Project object into a Map of key-value pairs
  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'projectDescription': projectDescription,
      'projectTotalCost': projectTotalCost,
      'projectCurrentCost': projectCurrentCost,
      'userId': userId,
      'verified': verified,
      'project_created_date': project_created_date,
      'interest': interest,
      'projectId': projectId,
      'img': img,
      'short_description': short_description,
    };
  }

  // Create a Project object from a Map of key-value pairs
  static Project fromMap(Map<String, dynamic> map) {
    return Project(
      projectName: map['projectName'],
      projectDescription: map['projectDescription'],
      projectTotalCost: map['projectTotalCost'],
      projectCurrentCost: map['projectCurrentCost'],
      userId: map['userId'],
      verified: map['verified'],
      project_created_date: map['project_created_date'],
      verification_documents: map['verification_documents'],
      interest: map['interest'],
      projectId: map['projectId'],
      img: map['img'],
      short_description: map['short_description'],
    );
  }


}
