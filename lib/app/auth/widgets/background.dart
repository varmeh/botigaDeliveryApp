import 'package:flutter/material.dart';

import '../../../theme/index.dart';

class Background extends StatelessWidget {
  final String title;
  final Widget child;
  final bool backNavigation;

  Background({
    @required this.title,
    @required this.child,
    this.backNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        width: double.infinity,
        color: AppTheme.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20.0, 76.0, 20.0, 60.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                children: [
                  backNavigation
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppTheme.backgroundColor,
                            ),
                          ),
                        )
                      : Container(),
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: AppTheme.textStyle.w600
                        .size(28.0)
                        .lineHeight(1.5)
                        .colored(AppTheme.backgroundColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 22, right: 22, top: 32),
                decoration: new BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(32.0),
                    topRight: const Radius.circular(32.0),
                  ),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
