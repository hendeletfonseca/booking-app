class BookingSchema {
  final int? id;
  final int userId;
  final int propertyId;
  final String checkinDate;
  final String checkoutDate;
  final int totalDays;
  final double totalPrice;
  final int amountGuest;
  final double? rating;

  BookingSchema({
    this.id,
    required this.userId,
    required this.propertyId,
    required this.checkinDate,
    required this.checkoutDate,
    required this.totalDays,
    required this.totalPrice,
    required this.amountGuest,
    this.rating,
  });

  // Converte o objeto BookingSchema para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'checkin_date': checkinDate,
      'checkout_date': checkoutDate,
      'total_days': totalDays,
      'total_price': totalPrice,
      'amount_guest': amountGuest,
      'rating': rating,
    };
  }

  // Cria um objeto BookingSchema a partir de um Map (JSON)
  factory BookingSchema.fromJson(Map<String, dynamic> json) {
    return BookingSchema(
      id: json['id'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      checkinDate: json['checkin_date'],
      checkoutDate: json['checkout_date'],
      totalDays: json['total_days'],
      totalPrice: json['total_price'],
      amountGuest: json['amount_guest'],
      rating: json['rating'],
    );
  }

  // Cria uma cópia do objeto BookingSchema com novos valores
  BookingSchema copy({
    int? id,
    int? userId,
    int? propertyId,
    String? checkinDate,
    String? checkoutDate,
    int? totalDays,
    double? totalPrice,
    int? amountGuest,
    double? rating,
  }) {
    return BookingSchema(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      checkinDate: checkinDate ?? this.checkinDate,
      checkoutDate: checkoutDate ?? this.checkoutDate,
      totalDays: totalDays ?? this.totalDays,
      totalPrice: totalPrice ?? this.totalPrice,
      amountGuest: amountGuest ?? this.amountGuest,
      rating: rating ?? this.rating,
    );
  }
}
