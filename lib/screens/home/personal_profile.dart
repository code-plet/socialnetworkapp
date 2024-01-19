import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/settings/profile_settings.dart';
import 'package:socialnetworkapp/services/auth.dart';

import '../../widget/post_card.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  Uint8List? photo;

  dynamic image = const AssetImage("assets/images/empty_avatar.png");

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";

    Future<int> getComment() async {
      int count = 0;
      FirebaseFirestore db = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> snapshot = await db.collection("posts").where("uid", isEqualTo: user?.uid).get();
      snapshot.docs.forEach((post) async {
        count += (await post.reference.collection("comments").where("uid", isEqualTo: user?.uid).count()) as int;
      });
      return count;
    }

    return Scaffold(
      body: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.blue),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: photo != null
                            ? MemoryImage(photo!)
                            : photoUrl.isNotEmpty
                            ? NetworkImage(
                          user!.photoURL.toString(),
                        )
                            : const AssetImage("assets/images/empty_avatar.png")
                        as ImageProvider<Object>,
                        radius: 50,
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('posts').where("uid", isEqualTo: user?.uid).snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      return Column(
                        children: [
                          Text(
                            snapshot.data!.docs.length.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),

                          Text("Posts", style: TextStyle(color: Colors.grey.shade700), )
                        ],
                      );
                    }
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('posts').where("uid", isEqualTo: user?.uid).snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        int countComments = 0;
                        snapshot.data?.docs.forEach((post) async {
                          await post.reference.collection('comments').where('uid', isEqualTo: user?.uid).get().then((commentSnapshot) {
                            countComments = countComments + 1;
                            for (var comment in commentSnapshot.docs) {
                              print('${comment.id} => ${comment.data()}');
                            }
                          });
                        });
                      return Column(
                        children: [
                          Text(
                            countComments.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
                          Text("Comments", style: TextStyle(color: Colors.grey.shade700), )
                        ],
                      );
                    }
                  ),
                  Column(
                    children: [
                      Text("12", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
                      Text("Likes", style: TextStyle(color: Colors.grey.shade700),)
                    ],
                  ),
                ]
              ),
              SizedBox(height: 15,),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettings()));
                },
                child: Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10)),
                  side: BorderSide( width: 2, color: Colors.grey),
                  fixedSize: Size(350, 35)
                ),

              ),
              const SizedBox(
                height: 40,
              ),
      Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').where("uid", isEqualTo: user?.uid).snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if(snapshot.data!.docs.length == 0){
                return Column(children: [SizedBox(height: 50,), Text("Your wall is empty! Try post something on Social.")]);
              }
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return PostCard(snap: snapshot.data!.docs[index].data());
                  });
            },
          )
        ],
      ),
            ],
          ),
        ),
      ]),
    );
  }
}
