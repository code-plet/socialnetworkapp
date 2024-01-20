import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/settings/profile_settings.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';

import '../../widget/post_card.dart';

class PersonalProfile extends StatefulWidget {
  final String? userId;
  const PersonalProfile({super.key, this.userId});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  LocalUser? user;

  dynamic image = const AssetImage("assets/images/empty_avatar.png");

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      LocalUser? parseUser = LocalUser.fromSnap(
          await db.collection('users').doc(widget.userId).get());
      setState(() {
        user = parseUser;
      });
    } catch (e) {
      print(e.toString());
      if (context.mounted) {
        showSnackBar(
          context,
          'Can not get profile.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLoginUser = Provider.of<LocalUser?>(context);

    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";
    final postSnapshot = FirebaseFirestore.instance
        .collection('posts')
        .where("uid", isEqualTo: user?.uid)
        .snapshots();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.blue),
                      borderRadius: BorderRadius.circular(100)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(
                              user!.photoURL.toString(),
                            )
                          : image,
                      radius: 50,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(displayName)
              ],
            ),
            StreamBuilder(
                stream: postSnapshot,
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        snapshot.data!.docs.length.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        "Posts",
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    ],
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where("uid", isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  int likeCount = 0;
                  snapshot.data?.docs.forEach((post) async {
                    likeCount += post.data()['likes']?.length as int;
                  });
                  return Column(
                    children: [
                      Text(
                        likeCount.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        "Like",
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    ],
                  );
                }),
          ]),
          const SizedBox(
            height: 15,
          ),
          currentLoginUser?.uid == user?.uid
              ? OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileSettings(
                                  userId: user?.uid ?? "",
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(width: 2, color: Colors.grey),
                      fixedSize: const Size(350, 35)),
                  child: const Text("Edit Profile"),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: postSnapshot,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return Column(children: [
                  const SizedBox(
                    height: 50,
                  ),
                  currentLoginUser?.uid == user?.uid
                      ? const Text("This wall is currently empty!")
                      : const Text(
                          "Your wall is empty! Try post something on Social.")
                ]);
              }
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return PostCard(snap: snapshot.data!.docs[index].data());
                  });
            },
          )
        ],
      ),
    );
  }
}
