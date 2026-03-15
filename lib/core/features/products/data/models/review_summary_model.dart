import '../../domain/entities/review_summary.dart';

class ReviewSummaryModel extends ReviewSummary {
  ReviewSummaryModel({
    required super.averageRating,
    required super.totalReviews,
    required super.ratingDistribution,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReviewSummaryModel(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      // Safely parse a Map<String, dynamic> into Map<int, int> (JSON keys are always Strings)
      ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(int.parse(key), value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution.map(
            (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }
}