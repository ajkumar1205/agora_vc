

import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProviderImpl  implements UserProvider{

  final store = FirebaseFirestore.instance.collection("users");

  @override
  Future<List<UserModel>> getUsers() async {
    final res = await store.get();
    if (res.docs.isEmpty) {
      return [];
    }
    return res.docs.map((e) => UserModel.fromJson(e.data())).toList();
  }
}