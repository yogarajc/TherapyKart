class Order {
  final String title;
  final double price;
  final String image;
  final int quantity;
  final String status;

  Order({
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status,
  });

  // Convert Order to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'status': status,
    };
  }
}
