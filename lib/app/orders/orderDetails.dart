import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/orders/index.dart';
import '../../providers/index.dart' show OrdersProvider, DeliveryProvider;
import '../../theme/index.dart';
import '../../util/index.dart';
import '../../widget/index.dart';
import 'index.dart';

class OrderDetails extends StatefulWidget {
  static const routeName = 'order-details';

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool _isLoading;
  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refetchScreenData(String apartmentId, String selectedDateForRequest,
      bool shouldNavigateBack) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final deliveryProvider =
        Provider.of<DeliveryProvider>(context, listen: false);
    final Map<String, dynamic> routeArgs =
        ModalRoute.of(context).settings.arguments;
    if (routeArgs['flowType'] == 'order') {
      await ordersProvider.fetchOrderByDateApartment(
          apartmentId, selectedDateForRequest);
    } else {
      await deliveryProvider.fetchDeliveryListByApartment(
          apartmentId, selectedDateForRequest);
      if (shouldNavigateBack == true) {
        Navigator.of(context).pop();
      }
    }
  }

  void handleMarkAsDeliverd(String id, String apartmentName, String apartmentId,
      String selectedDateForRequest) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final deliveryProvider =
          Provider.of<DeliveryProvider>(context, listen: false);
      await deliveryProvider.setDeliveryStatus(id);
      await refetchScreenData(apartmentId, selectedDateForRequest, false);
      Toast(
        message: 'Order marked as deliverd',
        icon: Icon(
          BotigaIcons.truck,
          size: 24,
          color: AppTheme.backgroundColor,
        ),
      ).show(context);
    } catch (err) {
      Toast(message: Http.message(err)).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget getBottomNavbar(OrderByDateDetail orderDetail, String id,
      String apartmentName, String apartmentId, String selectedDateForRequest) {
    Function fn;
    String btnText;

    if (orderDetail.order.isOutForDelivery == true) {
      fn = handleMarkAsDeliverd;
      btnText = 'Mark as delivered';
    } else {
      return SizedBox.shrink();
    }
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 52,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  onPressed: () {
                    fn(id, apartmentName, apartmentId, selectedDateForRequest);
                  },
                  color: AppTheme.primaryColor,
                  child: Text(
                    btnText,
                    style: AppTheme.textStyle
                        .colored(AppTheme.backgroundColor)
                        .w500
                        .size(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> routeArgs =
        ModalRoute.of(context).settings.arguments;
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: true);
    final deliveryProvider =
        Provider.of<DeliveryProvider>(context, listen: true);
    final id = routeArgs['id'];
    final apartmentName = routeArgs['apartmentName'];
    final apartmentId = routeArgs['apartmentId'];
    final selectedDateForRequest = routeArgs['selectedDateForRequest'];

    OrderByDateDetail orderDetail = (routeArgs['flowType'] == 'order')
        ? ordersProvider.getOrderDetails(id)
        : deliveryProvider.getDeliveryDetails(
            id, apartmentId, selectedDateForRequest);
    if (orderDetail == null) {
      return Scaffold(
        body: SizedBox.shrink(),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: BotigaAppBar(''),
      bottomNavigationBar: getBottomNavbar(
          orderDetail, id, apartmentName, apartmentId, selectedDateForRequest),
      body: SafeArea(
        child: LoaderOverlay(
          isLoading: _isLoading,
          child: Container(
            color: AppTheme.backgroundColor,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      OrderSummary(orderDetail, apartmentName)
                    ],
                  ),
                ),
                Divider(
                  color: AppTheme.dividerColor,
                  thickness: 4,
                ),
                OrderStatusWidget(orderDetails: orderDetail),
                Divider(
                  color: AppTheme.dividerColor,
                  thickness: 4,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      OrderListSummary(orderDetail),
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
}
