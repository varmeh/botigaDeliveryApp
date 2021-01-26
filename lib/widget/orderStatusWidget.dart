import 'package:flutter/material.dart';

import '../models/orders/index.dart' show OrderByDateDetail;
import '../theme/index.dart';
import 'index.dart' show StatusImageWidget, ImageStatus;

class OrderStatusWidget extends StatelessWidget {
  final OrderByDateDetail orderDetails;

  OrderStatusWidget({
    @required this.orderDetails,
  });

  @override
  Widget build(BuildContext context) {
    String paymentTitle;
    ImageStatus paymentStatus;

    // Order Payment Message
    if (orderDetails.payment.isSuccess) {
      paymentStatus = ImageStatus.success;
      paymentTitle = 'Paid via ${orderDetails.payment.paymentMode}';
    } else {
      paymentStatus = ImageStatus.failure;
      paymentTitle = 'Payment Failed';
    }

    return Container(
      child: Column(
        children: [
          _tile(
              baseImage: 'assets/images/card.png',
              status: paymentStatus,
              title: paymentTitle,
              context: context),
        ],
      ),
    );
  }

  Widget _tile(
      {String baseImage,
      ImageStatus status,
      String title,
      BuildContext context}) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusImageWidget(
                  baseImage: baseImage,
                  status: status,
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.textStyle.color100.w500
                        .size(13)
                        .lineHeight(1.38),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
