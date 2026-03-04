import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
      separatorBuilder: (context, index) => const Divider(height: 40),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 100, height: 120, color: Colors.white),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 15),
                    Container(width: 60, height: 16, color: Colors.white),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Container(width: 80, height: 30, color: Colors.white),
                        const Spacer(),
                        Container(width: 30, height: 30, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
