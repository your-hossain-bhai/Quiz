class User {
  final String uid;
  final String? displayName;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final String? rank;
  final int score;
  final DateTime? createdAt;

  User({
    required this.uid,
    this.displayName,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.rank,
    this.score = 0,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> data, [String? documentId]) {
    return User(
      uid: documentId ?? data['uid'] ?? data['id'] ?? '',
      displayName: data['displayName'],
      email: data['email'] ?? '',
      bio: data['bio'],
      avatarUrl: data['avatarUrl'],
      rank: data['rank'],
      score: data['score'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
                ? DateTime.tryParse(data['createdAt'])
                : data['createdAt'].runtimeType.toString() == 'Timestamp'
                ? data['createdAt'].toDate()
                : null)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'score': score,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? bio,
    String? avatarUrl,
    String? rank,
    int? score,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
