import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/services/comment.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';

class CommentCard extends StatefulWidget {
  final String postId;
  final String ownerPostUid;
  final snap;
  const CommentCard(
      {super.key,
      required this.snap,
      required this.postId,
      required this.ownerPostUid});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  void initState() {
    super.initState();
  }

  deleteComment(String commentId) async {
    try {
      await CommentService().deleteComment(widget.postId, commentId);
    } catch (err) {
      if (context.mounted) {
        showSnackBar(
          context,
          'Can not delete comment.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    final String? uid = user?.uid;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.snap['uid'])
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Widget errorText = const Center(
            child: Text(
              "Can not get comment owner information",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
            ),
          );

          final ownerComment = snapshot.data?.data();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                snapshot.hasError
                    ? errorText
                    : CircleAvatar(
                        backgroundImage: ownerComment?['photoURL'].toString() !=
                                    null.toString() &&
                                ownerComment!['photoURL'].isNotEmpty
                            ? NetworkImage(
                                ownerComment['photoURL'].toString(),
                              )
                            : const AssetImage('assets/images/empty_avatar.png')
                                as ImageProvider<Object>,
                        radius: 18,
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        snapshot.hasError
                            ? errorText
                            : Text(
                                ownerComment?['displayName'] == null
                                    ? ""
                                    : ownerComment!['displayName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: ' ${widget.snap['content']}',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat.yMMMd().format(
                              widget.snap['dateComment'].toDate(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == uid ||
                        widget.ownerPostUid == uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deleteComment(
                                                  widget.snap['commentId']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          );
        });
  }
}
