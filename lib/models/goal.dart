class Goal {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double savedAmount;
  final DateTime createdAt;
  final DateTime? deadline;
  final String iconKey;

  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.targetAmount,
    this.savedAmount = 0,
    required this.createdAt,
    this.deadline,
    this.iconKey = 'savings',
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0).toDouble();
  }

  double get remaining => (targetAmount - savedAmount).clamp(0.0, double.infinity).toDouble();

  Goal copyWith({
    String? title,
    String? description,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    bool clearDeadline = false,
    String? iconKey,
  }) => Goal(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        createdAt: createdAt,
        deadline: clearDeadline ? null : (deadline ?? this.deadline),
        iconKey: iconKey ?? this.iconKey,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'iconKey': iconKey,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Untitled goal',
        description: json['description'] as String? ?? '',
        targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
        savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        deadline: DateTime.tryParse(json['deadline'] as String? ?? ''),
        iconKey: json['iconKey'] as String? ?? 'savings',
      );
}
