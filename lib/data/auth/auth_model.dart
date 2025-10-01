class User {
  final String uid;
  final String email;
  final bool isPremium;

  User({
    required this.uid,
    required this.email,
    this.isPremium = false,
  });

  // Simple factory constructor for creating a mock user
  factory User.mock({bool isPremium = false}) {
    return User(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      email: isPremium ? 'premium@morphix.pro' : 'guest@morphix.pro',
      isPremium: isPremium,
    );
  }
}