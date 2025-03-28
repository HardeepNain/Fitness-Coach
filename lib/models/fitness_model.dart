class FitnessModel {
  final String fitnessId;
  final String title;
  final String fitnessEntry;
  final String createdAt;

  FitnessModel({
    required this.fitnessId,
    required this.title,
    required this.fitnessEntry,
    required this.createdAt,
  });

  factory FitnessModel.fromJson(Map<String, dynamic> json) {
    return FitnessModel(
      fitnessId: json['_id'],
      title: json['title'],
      fitnessEntry: json['fitness_entry'],
      createdAt: json['datetime'],
    );
  }
}