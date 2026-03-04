import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    notifyListeners();
    _reviews = await _service.getProductReviews(productId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReview({
    required String productId,
    required int rating,
    required String comment,
    List<String>? images,
  }) async {
    bool success = await _service.createReview(
      productId: productId,
      rating: rating,
      comment: comment,
      images: images,
    );

    if (success) {
      await fetchReviews(productId);
    }
    return success;
  }

  Future<bool> addReply({
    required String productId,
    required String reviewId,
    required String comment,
  }) async {
    bool success = await _service.replyReview(
      reviewId: reviewId,
      comment: comment,
    );

    if (success) {
      await fetchReviews(productId);
    }
    return success;
  }
}
