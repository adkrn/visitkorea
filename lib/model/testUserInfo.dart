class TestUser {
  final int id;
  final String snsId;

  TestUser({
    required this.id,
    required this.snsId,
  });

  factory TestUser.fromJson(Map<String, dynamic> json) {
    return TestUser(id: json['id'], snsId: json['snsId']);
  }
}
