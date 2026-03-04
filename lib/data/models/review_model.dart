class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final List<String> images;
  final List<ReplyModel> replies;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.replies,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    var userData = json['userId'];
    String name = "Guest";
    String uId = "";

    if (userData is Map) {
      name = "${userData['firstName']} ${userData['lastName']}";
      uId = userData['_id'] ?? "";
    } else {
      uId = userData.toString();
    }

    return ReviewModel(
      id: json['_id'] ?? "",
      userId: uId,
      userName: name,
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? "",
      images: List<String>.from(json['images'] ?? []),
      replies: (json['replies'] as List? ?? [])
          .map((r) => ReplyModel.fromJson(r))
          .toList(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ReplyModel {
  final String userName;
  final String comment;
  final DateTime createdAt;

  ReplyModel({
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    var userData = json['userId'];
    return ReplyModel(
      userName: userData is Map
          ? "${userData['firstName']} ${userData['lastName']}"
          : "Staff",
      comment: json['comment'] ?? "",
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
