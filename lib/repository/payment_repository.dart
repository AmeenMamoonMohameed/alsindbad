import 'package:flutter/material.dart';
import 'package:akarak/api/api.dart';
import 'package:akarak/blocs/bloc.dart';
import 'package:akarak/models/model.dart';

class PaymentRepository {
  static Future<String?> createPaymentIntent({
    required String paymentType,
    required int id,
    required String amount,
    required String currency,
    required String paymentMethodType,
  }) async {
    final response = await Api.requestCreatePaymentIntent({
      'paymentType': paymentType,
      'id': id,
      'currency': 'USD',
      'paymentMethodTypes': 'card'
    });
    if (response.succeeded) {
      return response.data['clientSecret'];
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }

  static Future<Map<String, String>?> createPaymentLink(
      {required int productId,
      required String amount,
      required String currency,
      required String paymentMethodType}) async {
    final response = await Api.requestCreatePaypalLink({
      'productId': productId,
      'amount': 2500,
      'currency': 'USD',
      // 'paymentMethodTypes': 'card'
    });
    if (response.succeeded) {
      return {
        'executeUrl': response.data['executeUrl'],
        'approvalUrl': response.data['approvalUrl']
      };
    }
    AppBloc.messageCubit.onShow(response.message);
    return null;
  }
}
