import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info/package_info.dart';

import '../../../providers/index.dart';
import '../../../theme/index.dart';
import '../../../util/index.dart';
import '../../../widget/index.dart'
    show
        Toast,
        LoaderOverlay,
        WhatsappIconButton,
        CallIconButton,
        PolicyWebiewScreen;

import '../../auth/index.dart' show Welcome;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isProcessing = false;
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    this._updateBuildInfo();
  }

  _updateBuildInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      appVersion = version;
    });
  }

  _handleLogout() async {
    try {
      setState(() {
        isProcessing = true;
      });
      await Provider.of<ProfileProvider>(context, listen: false).logout();
      await Provider.of<OrdersProvider>(context, listen: false).resetOrder();
      await Provider.of<DeliveryProvider>(context, listen: false)
          .resetDelivery();
      await Provider.of<ProfileProvider>(context, listen: false).restProfile();
    } catch (err) {
      Toast(message: Http.message(err)).show(context);
    } finally {
      setState(() {
        isProcessing = false;
      });
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Welcome.routeName, (route) => false);
    }
  }

  Widget build(BuildContext context) {
    final profileInfo =
        Provider.of<ProfileProvider>(context, listen: false).profileInfo;
    if (profileInfo == null) {
      return SizedBox.shrink();
    }
    return LoaderOverlay(
      isLoading: isProcessing,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          'Business Name',
                          style: AppTheme.textStyle.w500.color100
                              .size(15)
                              .lineHeight(1.3),
                        ),
                        subtitle: Text(
                          profileInfo.businessName,
                          style: AppTheme.textStyle.w500.color50
                              .size(15)
                              .lineHeight(1.3),
                        ),
                      ),
                      _policyDivider(),
                      ListTile(
                        title: Text(
                          'Contact',
                          style: AppTheme.textStyle.w500.color100
                              .size(15)
                              .lineHeight(1.3),
                        ),
                        subtitle: Text(
                          '+91 ${profileInfo.contact.phone}',
                          style: AppTheme.textStyle.w500.color50
                              .size(15)
                              .lineHeight(1.3),
                        ),
                      ),
                      _policyDivider(),
                      ListTile(
                        title: Text(
                          'Watsapp',
                          style: AppTheme.textStyle.w500.color100
                              .size(15)
                              .lineHeight(1.3),
                        ),
                        subtitle: Text(
                          '+91 ${profileInfo.contact.whatsapp}',
                          style: AppTheme.textStyle.w500.color50
                              .size(15)
                              .lineHeight(1.3),
                        ),
                      ),
                      _policyDivider(),
                      ListTile(
                        title: Text(
                          'Email',
                          style: AppTheme.textStyle.w500.color100
                              .size(15)
                              .lineHeight(1.3),
                        ),
                        subtitle: Text(
                          profileInfo.contact.email,
                          style: AppTheme.textStyle.w500.color50
                              .size(15)
                              .lineHeight(1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: AppTheme.dividerColor,
                  thickness: 8,
                ),
                profileInfo != null
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/chat.png',
                                  height: 20,
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Need help?",
                                  style: AppTheme.textStyle.w700.color100
                                      .size(17)
                                      .lineHeight(1.5),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Any queries or concerns. We are always available to help you out.",
                              style: AppTheme.textStyle.w500.color50
                                  .size(13)
                                  .lineHeight(1.3),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monday - Friday',
                                      style: AppTheme.textStyle.w500.color100
                                          .size(15)
                                          .lineHeight(1.3),
                                    ),
                                    Text(
                                      '10 AM to 6 PM',
                                      style: AppTheme.textStyle.w500.color50
                                          .size(15)
                                          .lineHeight(1.3),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    WhatsappIconButton(number: '9910057232'),
                                    SizedBox(width: 16.0),
                                    CallIconButton(number: '9910057232'),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Divider(
                    color: AppTheme.dividerColor,
                    thickness: 1.2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      _policyTile(
                        'Cancellation Policy',
                        'https://s3.ap-south-1.amazonaws.com/products.image.prod/cancellationPolicy.html',
                      ),
                      _policyDivider(),
                      _policyTile(
                        'Privacy Policy',
                        'https://s3.ap-south-1.amazonaws.com/products.image.prod/privacyPolicy.html',
                      ),
                      _policyDivider(),
                      _policyTile(
                        'Terms & Conditions',
                        'https://s3.ap-south-1.amazonaws.com/products.image.prod/termsAndConditions.html',
                      ),
                      _policyDivider(),
                      _policyTile(
                        'Frequently Asked Questions',
                        'https://s3.ap-south-1.amazonaws.com/products.image.prod/faqMerchants.html',
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: AppTheme.dividerColor,
                        thickness: 8,
                      ),
                      ListTile(
                        onTap: () {
                          this._handleLogout();
                        },
                        title: Text('Logout',
                            style: AppTheme.textStyle.color100.size(15).w500),
                        trailing: Icon(
                          BotigaIcons.exit,
                          color: AppTheme.color50,
                          size: 25,
                        ),
                      ),
                      _policyDivider(),
                      ListTile(
                        title: Text('App version',
                            style: AppTheme.textStyle.color100.size(15).w500),
                        trailing: Text(appVersion,
                            style: AppTheme.textStyle.color50.size(15).w500),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _policyTile(String title, String url) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PolicyWebiewScreen(url),
          ),
        );
      },
      title: Text(title, style: AppTheme.textStyle.color100.size(15).w500),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.color50,
        size: 20,
      ),
    );
  }

  Widget _policyDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Divider(
        color: AppTheme.dividerColor,
        thickness: 1.2,
      ),
    );
  }
}
