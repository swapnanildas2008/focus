class IslandItem {
  int? id;
  String itemId;
  String category;
  double positionX;
  double positionY;
  DateTime placedAt;
  bool isUnlocked;

  IslandItem({
    this.id,
    required this.itemId,
    required this.category,
    required this.positionX,
    required this.positionY,
    required this.placedAt,
    this.isUnlocked = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'category': category,
      'positionX': positionX,
      'positionY': positionY,
      'placedAt': placedAt.millisecondsSinceEpoch,
      'isUnlocked': isUnlocked ? 1 : 0,
    };
  }

  static IslandItem fromMap(Map<String, dynamic> map) {
    return IslandItem(
      id: map['id'],
      itemId: map['itemId'],
      category: map['category'],
      positionX: map['positionX'],
      positionY: map['positionY'],
      placedAt: DateTime.fromMillisecondsSinceEpoch(map['placedAt']),
      isUnlocked: map['isUnlocked'] == 1,
    );
  }
}
