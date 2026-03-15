class ReviewSummary {
  final double averageRating; // e.g., 4.5
  final int totalReviews; // e.g., 12,450
  final Map<int, int> ratingDistribution; // e.g., {5: 10000, 4: 1500, 3: 500, 2: 250, 1: 200}

  ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}