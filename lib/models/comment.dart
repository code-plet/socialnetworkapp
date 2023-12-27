import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String content;
  final String uid;
  final String avatar;
  final String commentId;
  final DateTime dateComment;
  final String userName;

  const Comment(
      {required this.content,
      required this.uid,
      required this.avatar,
      required this.commentId,
      required this.dateComment,
      required this.userName});

  static Comment fromSnap(DocumentSnapshot snap) {
    final snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
        content: snapshot['content'],
        uid: snapshot['uid'],
        avatar: snapshot['avatar'],
        commentId: snapshot['commentId'],
        dateComment: snapshot['dateComment'],
        userName: snapshot['userName']);
  }

  Map<String, dynamic> toJson() => {
        "content": content,
        "uid": uid,
        "avatar": avatar,
        "commentId": commentId,
        "dateComment": dateComment,
        "userName": userName
      };
}
