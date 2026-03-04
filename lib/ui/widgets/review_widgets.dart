import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/review_model.dart';
import '../../providers/review_provider.dart';
import '../../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class ReviewSection extends StatelessWidget {
  final String productId;
  const ReviewSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final reviewProv = Provider.of<ReviewProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle("REVIEWS"),
        const SizedBox(height: 20),
        if (reviewProv.isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.black))
        else if (reviewProv.reviews.isEmpty)
          const Text(
            "No reviews yet. Be the first to review!",
            style: TextStyle(color: Colors.grey),
          )
        else
          _buildReviewList(reviewProv.reviews, authProv.isAuthenticated),

        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 40),

        _buildTitle("WRITE A REVIEW"),
        const SizedBox(height: 20),
        if (authProv.isAuthenticated)
          AddReviewForm(productId: productId)
        else
          _buildLoginPrompt(context),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildReviewList(List<ReviewModel> reviews, bool isAuthenticated) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 40),
      itemBuilder: (context, index) {
        final rev = reviews[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 14,
                    color: i < rev.rating ? Colors.black : Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  rev.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rev.comment,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            if (isAuthenticated)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MiniReplyForm(productId: productId, reviewId: rev.id),
              ),

            if (rev.replies.isNotEmpty)
              ...rev.replies
                  .map(
                    (r) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10, left: 20),
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.userName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.comment,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
          ],
        );
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Please log in to share your feedback.",
              style: TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const LoginScreen()),
            ),
            child: const Text(
              "LOG IN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniReplyForm extends StatefulWidget {
  final String productId;
  final String reviewId;
  const MiniReplyForm({
    super.key,
    required this.productId,
    required this.reviewId,
  });

  @override
  State<MiniReplyForm> createState() => _MiniReplyFormState();
}

class _MiniReplyFormState extends State<MiniReplyForm> {
  bool _isExpanded = false;
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (!_isExpanded) {
      return InkWell(
        onTap: () => setState(() => _isExpanded = true),
        child: const Text(
          "REPLY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            hintText: "Write a reply...",
            hintStyle: TextStyle(fontSize: 12),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            isDense: true,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _isExpanded = false;
                _controller.clear();
              }),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _submitReply,
              child: _isLoading
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      "POST",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitReply() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    final success = await Provider.of<ReviewProvider>(context, listen: false)
        .addReply(
          productId: widget.productId,
          reviewId: widget.reviewId,
          comment: _controller.text,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) {
          _isExpanded = false;
          _controller.clear();
        }
      });
    }
  }
}

class AddReviewForm extends StatefulWidget {
  final String productId;
  const AddReviewForm({super.key, required this.productId});

  @override
  State<AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => setState(() => _rating = index + 1),
              child: Icon(
                Icons.star,
                color: index < _rating ? Colors.black : Colors.grey[300],
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _commentController,
          maxLines: 4,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "How do you feel about these kicks?",
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "POST REVIEW",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final success = await Provider.of<ReviewProvider>(context, listen: false)
        .addReview(
          productId: widget.productId,
          rating: _rating,
          comment: _commentController.text,
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        _commentController.clear();
        setState(() => _rating = 5);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("THANKS FOR YOUR REVIEW!")),
        );
      }
    }
  }
}
