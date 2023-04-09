import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

enum PaymentType { creditCard, paypal, fdss, fdsa }

enum OrderType { cart, order }

enum OrderStatus {
  cart,
  order,
  awaitingApproval,
  outStock,
  progress,
  onShipping,
  finished,
  returned,
}

class OrderModel {
  final int orderId;
  final String userName;
  final OrderType type;
  late PaymentType payment;
  final OrderStatus status;
  final Color statusColor;
  final double total;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? memo;
  final bool isReviewed;
  final bool isContainsReturned;
  final String? date;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.orderId,
    required this.userName,
    required this.type,
    required this.payment,
    required this.status,
    required this.statusColor,
    required this.total,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.memo,
    required this.isReviewed,
    required this.isContainsReturned,
    this.date,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderType type = OrderType.cart;
    PaymentType payment = PaymentType.creditCard;
    OrderStatus status = OrderStatus.cart;
    if (json['type'] != null) {
      type = OrderType.values[int.parse(json['type'].toString())];
    }
    if (json['payment'] != null) {
      payment = PaymentType.values[int.parse(json['payment'].toString())];
    }
    if (json['status'] != null) {
      status = OrderStatus.values[int.parse(json['status'].toString())];
    }
    return OrderModel(
      orderId: json['orderId'],
      userName: json['userName'] ?? '',
      type: type,
      payment: payment,
      status: status,
      statusColor: UtilColor.getColorFromHex(json['statusColor']),
      total: double.parse(json['total']?.toString() ?? '0'),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      memo: json['memo'],
      isReviewed: json['isReviewed'] ?? false,
      isContainsReturned: json['isContainsReturned'] ?? false,
      date: json['date'],
      orderItems: List.from(json['orderItems'] ?? []).map((item) {
        return OrderItemModel.fromJson(item);
      }).toList(),
    );
  }
}
