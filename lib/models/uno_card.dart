class UnoCard {
  final String color;
  final String value;
  final bool isWild;
  final bool isActionCard;

  UnoCard({
    required this.color,
    required this.value,
    this.isWild = false,
    this.isActionCard = false,
  });

  @override
  String toString() => '$color $value';
}
