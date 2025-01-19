class Inventory {
  final int id;
  final String transcode;
  final String transdate;
  final String remark;
  final int categoryId;

  Inventory({
    required this.id,
    required this.transcode,
    required this.transdate,
    required this.remark,
    required this.categoryId,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      transcode: json['transcode'],
      transdate: json['transdate'],
      remark: json['remark'],
      categoryId: json['category']['id'],
    );
  }
}
