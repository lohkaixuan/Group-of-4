// lib/models/models.dart

// ✅ User model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
    );
  }

  // 🔹 Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

// ✅ Wallet model
class Wallet {
  final String id;
  final String type;
  final double balance;

  Wallet({
    required this.id,
    required this.type,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      type: json['wallet_type'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }

  // 🔹 Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_type': type,
      'balance': balance,
    };
  }
}

// ✅ Transaction model
class Transaction {
  final String id;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String status;

  Transaction({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  // 🔹 Convert back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'amount': amount,
      'status': status,
    };
  }
}
