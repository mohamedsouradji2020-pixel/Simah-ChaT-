class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String about;
  final bool online;
  final DateTime lastSeen;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.about = 'Salut, j\'utilise ChatModerne !',
    this.online = false,
    required this.lastSeen,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'Utilisateur',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      about: map['about'] ?? 'Salut, j\'utilise ChatModerne !',
      online: map['online'] ?? false,
      lastSeen: map['lastSeen']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'about': about,
      'online': online,
      'lastSeen': lastSeen,
    };
  }
}
