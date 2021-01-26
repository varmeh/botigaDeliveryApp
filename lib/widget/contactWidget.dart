import 'package:flutter/material.dart';

import 'buttons/index.dart' show CallButton;

class ContactWidget extends StatelessWidget {
  final String phone;

  ContactWidget({
    @required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: CallButton(number: phone)),
      ],
    );
  }
}
