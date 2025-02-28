import 'package:heartless/shared/models/app_user.dart';

class Nurse extends AppUser {
  List<String> patients = []; // list of patients handled
  List<String> doctors = []; // list of doctors reporting

  Nurse() {
    // todo: add a default image for nurse
    imageUrl = 'https://i.imgur.com/BoN9kdC.png';
    userType = UserType.nurse;
  }

  Nurse.fromMap(Map<String, dynamic> map) {
    uid = map['uid'];
    name = map['name'];
    imageUrl = map['imageUrl'];
    email = map['email'];
    phone = map['phone'];
    password = map['password'];
    userType = UserType.values[map['userType']];
    isOnline = map['isOnline'];
    lastSeen = DateTime.parse(map['lastSeen'] ?? DateTime.now());
    patients = map['patients'] is Iterable ? List.from(map['patients']) : [];
    doctors = map['doctors'] is Iterable ? List.from(map['doctors']) : [];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'imageUrl': imageUrl,
      'email': email,
      'phone': phone,
      'password': password,
      'userType': userType.index,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toString(),
      'patients': patients,
      'doctors': doctors,
    };
  }
}
