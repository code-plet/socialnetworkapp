import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String content;
  final String uid;
  final String commentId;
  final DateTime dateComment;

  const Comment({
    required this.content,
    required this.uid,
    required this.commentId,
    required this.dateComment,
  });

  static Comment fromSnap(DocumentSnapshot snap) {
    final snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      content: snapshot['content'],
      uid: snapshot['uid'],
      commentId: snapshot['commentId'],
      dateComment: snapshot['dateComment'],
    );
  }

  Map<String, dynamic> toJson() => {
        "content": content,
        "uid": uid,
        "commentId": commentId,
        "dateComment": dateComment,
      };
}
