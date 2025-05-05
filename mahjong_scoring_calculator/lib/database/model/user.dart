class User {
  final int? userId;
  final String? username;

  User({this.userId, this.username});

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'username': username,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    userId: map['user_id'],
    username: map['username'],
  );
}