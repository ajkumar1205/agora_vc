import 'package:agora_vc/src/domain/models/user/user_model.dart';
import 'package:agora_vc/src/domain/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire;

class AuthProviderImpl implements AuthProvider {
  final auth = fire.FirebaseAuth.instance;
  final store = FirebaseFirestore.instance.collection("users");

  @override
  Future<UserModel?> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (res.user == null) return null;
    final authUser = res.user;
    final userModel = UserModel(uid: authUser!.uid, name: name, email: email);
    final doc = await store.add(userModel.toJson());
    final user = userModel.copyWith(id: doc.id);
    return user;
  }

  @override
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final res = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (res.user == null) return null;
    final authUser = res.user;
    final doc = await store.where("email", isEqualTo: email).limit(1).get();
    final user = UserModel.fromJson(doc.docs.last.data());
    return user;
  }
}
