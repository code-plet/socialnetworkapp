import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialnetworkapp/models/comment.dart';
import 'package:uuid/uuid.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Post comment
  Future<String> postComment(String postId, String content, String uid,
      String avatar, DateTime dateComment, String userName) async {
    String res = "Some error occurred";

    try {
      if (content.isNotEmpty) {
        String commentId = const Uuid().v1();
        Comment comment = Comment(
            content: content,
            uid: uid,
            avatar: avatar,
            commentId: commentId,
            dateComment: dateComment,
            userName: userName);

        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
