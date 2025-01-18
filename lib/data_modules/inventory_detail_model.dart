class InventoryDetail {
  final int id;
  final int headerId;
  final String product;
  final int qty;
  final String remark;

  InventoryDetail({
    required this.id,
    required this.headerId,
    required this.product,
    required this.qty,
    required this.remark,
  });

  factory InventoryDetail.fromJson(Map<String, dynamic> json) {
    return InventoryDetail(
      id: json['id'],
      headerId: json['headerid'],
      product: json['product'] ?? '-',
      qty: json['qty'],
      remark: json['remark'],
    );
  }
}
