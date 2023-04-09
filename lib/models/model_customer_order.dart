import 'package:flutter/material.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/utils/utils.dart';

class CustomerOrderModel {
  final int id;
  final int orderId;
  final int productId;
  final String name;
  final String image;
  final PaymentType payment;
  late OrderStatus status;
  final Color statusColor;
  final String? date;
  final String? paymentName;
  final String? transactionID;
  final int? total;
  late int? quantity;
  final int currencyId;
  final int? unitId;
  final double unitPrice;
  final double totalPrice;
  final String? totalDisplay;
  final List<OrderResourceModel>? resource;
  final bool? allowCancel;
  final bool? allowPayment;
  final bool hasRefundRequest;
  final bool hasOpenComplaint;
  final bool hasRefusalToRefund;
  final int complaintsCount;
  final String? openComplaint;
  final String? refundRequest;
  final String? createdOn;
  final UserModel? createdBy;
  final String? paidOn;
  final String? createdVia;

  CustomerOrderModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.name,
    required this.image,
    required this.payment,
    required this.status,
    required this.statusColor,
    required this.date,
    this.paymentName,
    this.transactionID,
    this.total,
    this.quantity,
    required this.currencyId,
    this.unitId,
    required this.unitPrice,
    required this.totalPrice,
    this.totalDisplay,
    this.resource,
    this.allowCancel,
    this.allowPayment,
    required this.hasRefundRequest,
    required this.hasOpenComplaint,
    required this.hasRefusalToRefund,
    required this.complaintsCount,
    this.openComplaint,
    this.refundRequest,
    this.createdOn,
    this.createdBy,
    this.paidOn,
    this.createdVia,
  });

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus status = OrderStatus.cart;
    PaymentType payment = PaymentType.creditCard;
    UserModel? createdBy;
    if (json['status'] != null) {
      status = OrderStatus.values[int.parse(json['status'].toString())];
    }
    if (json['payment'] != null) {
      payment = PaymentType.values[int.parse(json['payment'].toString())];
    }

    if (json['createdBy'] != null) {
      createdBy = UserModel.fromJson(json['createdBy']);
    }

    return CustomerOrderModel(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: status,
      statusColor: UtilColor.getColorFromHex(json['statusColor']),
      date: json['date'],
      paymentName: payment.name,
      payment: payment,
      transactionID: json['transactionID'] ?? '1561515',
      total: json['total'] ?? 0,
      quantity: json['quantity'] ?? 0,
      currencyId: json['currencyId'] ?? 0,
      unitId: json['unitId'],
      unitPrice: double.parse(json['unitPrice']?.toString() ?? '0'),
      totalPrice: double.parse(json['total']?.toString() ?? '0'),
      totalDisplay: json['totalDisplay'] ?? '',
      resource: List.from(json['resources'] ?? []).map((item) {
        return OrderResourceModel.fromJson(item);
      }).toList(),
      allowCancel: json['allowCancel'] ?? false,
      allowPayment: json['allowPayment'] ?? false,
      hasRefundRequest: json['hasRefundRequest'] ?? false,
      hasOpenComplaint: json['hasOpenComplaint'] ?? false,
      hasRefusalToRefund: json['hasRefusalToRefund'] ?? false,
      complaintsCount: int.parse(json['complaintsCount'].toString()),
      openComplaint: json['openComplaint'],
      refundRequest: json['refundRequest'],
      createdOn: json['createdOn'] ?? '',
      createdBy: createdBy,
      paidOn: json['paidDate'] ?? '',
      createdVia: json['createdVia'] ?? '',
    );
  }
}
