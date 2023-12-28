import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/services/comment.dart';
import 'package:socialnetworkapp/utils/colors.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';
import 'package:socialnetworkapp/widget/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String ownerPostUid;
  const CommentsScreen(
      {super.key, required this.postId, required this.ownerPostUid});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();

  void postComment(LocalUser? user) async {
    final String? uid = user?.uid;
    final String? name = user?.displayName;
    final String profilePic = user?.photoURL ?? '';

    if (uid == null || name == null) {
      showSnackBar(
        context,
        'Can not read user information',
      );
    }

    try {
      String res = await CommentService().postComment(
        widget.postId,
        commentEditingController.text,
        uid!,
        profilePic,
        DateTime.now(),
        name!,
      );

      if (res != 'success') {
        if (context.mounted) showSnackBar(context, res);
      }
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      if (context.mounted) {
        showSnackBar(
          context,
          err.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    final profileImg = user?.photoURL != null
        ? NetworkImage(user!.photoURL)
        : const AssetImage('assets/image/empty_avatar.png')
            as ImageProvider<Object>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Comments',
        ),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => CommentCard(
              key: Key(snapshot.data!.docs[index].data()['commentId']),
              postId: widget.postId,
              ownerPostUid: widget.ownerPostUid,
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: profileImg,
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user?.displayName}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(user),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
