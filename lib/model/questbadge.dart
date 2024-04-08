enum Grade { Beginner, Intermediate, Advanced }

enum BadgeType { activity, event, exploer }

BadgeType getTitleName(int titleNameValue) {
  switch (titleNameValue) {
    case 0:
      return BadgeType.activity;
    case 1:
      return BadgeType.event;
    case 2:
      return BadgeType.exploer;
    default:
      throw Exception('Invalid titleName value');
  }
}

class QuestBadge {
  final int id;
  final String name;
  final String imgName;
  final BadgeType titleName;
  final int filterName;
  final String description;
  final String getMethodDescription;

  QuestBadge({
    required this.id,
    required this.name,
    required this.imgName,
    required this.titleName,
    required this.filterName,
    required this.description,
    required this.getMethodDescription,
  });

  factory QuestBadge.fromCsv(Map<String, dynamic> json) {
    return QuestBadge(
      id: json['id'] as int,
      name: json['name'] as String,
      imgName: json['imgName'] as String,
      titleName: getTitleName(json['titleName'] as int),
      filterName: json['filterName'] as int,
      description: json['description'] as String,
      getMethodDescription: json['getMethodDescription'] as String,
    );
  }
}
