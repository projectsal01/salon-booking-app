import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

final _auth = FirebaseAuth.instance;
final _firestoreService = FirestoreService();

Future<void> signUpUser(String email, String password, String userType) async {
  final userCredential = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  await _firestoreService.createUser(
    uid: userCredential.user!.uid,
    email: email,
    userType: userType, // 'customer' or 'salonOwner'
  );
}
