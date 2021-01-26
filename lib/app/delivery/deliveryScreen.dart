import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../models/profile/index.dart';
import '../../providers/index.dart' show ProfileProvider, DeliveryProvider;
import '../../theme/index.dart';
import '../../util/index.dart';
import '../../widget/index.dart';
import 'deliveryRow.dart';

const rupeeSymbol = '\u20B9';

class DeliveryScreen extends StatefulWidget {
  static const routeName = 'all-delivery-list';
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  bool _isLoading;
  bool _isError;
  bool _isInit;
  bool _isProcessing;
  DateTime selectedDate;
  Apartment apartment;
  var _error;
  String _query;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      fetchDefaultDeliveryDetails();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isError
        ? HttpExceptionWidget(
            exception: _error,
            onTap: () {
              fetchDefaultDeliveryDetails();
            },
          )
        : LoaderOverlay(
            isLoading: _isLoading,
            child: Scaffold(
              appBar: BotigaAppBar(
                'Delivery',
                neverShowLeadingBtn: true,
              ),
              backgroundColor: AppTheme.backgroundColor,
              body: GestureDetector(
                onVerticalDragDown: (_) => FocusScope.of(context).unfocus(),
                child: SafeArea(
                  child: LoaderOverlay(
                    isLoading: _isProcessing,
                    child: Container(
                      color: AppTheme.backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _getSearch(),
                            ],
                          ),
                          ListTile(
                            onTap: () {
                              showApartmentList();
                            },
                            leading: Icon(
                              BotigaIcons.building,
                              color: AppTheme.color100,
                            ),
                            title: Transform(
                              transform:
                                  Matrix4.translationValues(-16, 0.0, 0.0),
                              child: Text('${apartment.apartmentName}',
                                  style: AppTheme.textStyle.color100
                                      .size(16)
                                      .lineHeight(1.2)
                                      .w500),
                            ),
                            trailing: Icon(
                              Icons.expand_more_sharp,
                              color: AppTheme.color100,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => pullToRefresh(),
                              color: AppTheme.primaryColor,
                              child: ListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  Consumer<DeliveryProvider>(
                                      builder: (ctx, deliveryProvider, _) {
                                    var deliveryListByApartment;
                                    deliveryListByApartment = deliveryProvider
                                            .deliveryByApartmentToday[
                                        '${apartment.id}-${selectedDate.getRequestFormatDate()}'];

                                    if (deliveryListByApartment == null ||
                                        deliveryListByApartment.length == 0) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Text(
                                            'No deliveries today',
                                            style: AppTheme
                                                .textStyle.w700.color100
                                                .size(16)
                                                .lineHeight(1.4),
                                          ),
                                        ),
                                      );
                                    }

                                    var deliveries = deliveryListByApartment;
                                    if (_query != '' && _query != null) {
                                      deliveries = deliveries.where(
                                        (_delivery) {
                                          if (_delivery.order.number
                                                  .toLowerCase()
                                                  .contains(
                                                      _query.toLowerCase()) ==
                                              true) {
                                            return true;
                                          }
                                          if (_delivery.buyer.house
                                                  .toLowerCase()
                                                  .contains(
                                                      _query.toLowerCase()) ==
                                              true) {
                                            return true;
                                          }
                                          return false;
                                        },
                                      );
                                    }

                                    var deliveryList =
                                        deliveries.where((_delivery) {
                                      if (_delivery.order.isOutForDelivery ||
                                          _delivery.order.isDelivered) {
                                        return true;
                                      }
                                    });

                                    return Column(
                                      children: [
                                        ...deliveryList.map(
                                          (deliveryRow) {
                                            return DeliveryRow(
                                                deliveryRow,
                                                apartment.apartmentName,
                                                apartment.id,
                                                selectedDate,
                                                this._handleMarkAsDeliverd);
                                          },
                                        )
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void loadSettings() async {
    final deafaultApartment =
        Provider.of<ProfileProvider>(context, listen: false).defaultApartment;
    _isLoading = false;
    _isError = false;
    _isInit = false;
    _isProcessing = false;
    apartment = deafaultApartment;
    selectedDate = DateTime.now();
    _error = null;
    _query = '';
  }

  void fetchDeliveryData(String aprtmentId, String currentDate) async {
    if (aprtmentId != null &&
        aprtmentId != '' &&
        currentDate != null &&
        currentDate != '') {
      final deliveryProvider =
          Provider.of<DeliveryProvider>(context, listen: false);
      if (deliveryProvider
              .deliveryByApartmentToday['$aprtmentId-$currentDate'] !=
          null) {
        return;
      }
      setState(() {
        _isError = false;
        _isLoading = true;
        _error = null;
      });
      try {
        await deliveryProvider.fetchDeliveryListByApartment(
            aprtmentId, currentDate);
      } catch (err) {
        setState(() {
          _isError = true;
          _isLoading = false;
          _error = err;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleMarkAsDeliverd(String orderId) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      final deliveryProvider =
          Provider.of<DeliveryProvider>(context, listen: false);
      final date = DateTime.now();
      await deliveryProvider.setDeliveryStatus(orderId);
      await deliveryProvider.fetchDeliveryListByApartment(
          apartment.id, date.getRequestFormatDate());
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
        _isProcessing = false;
      });
    }
  }

  void fetchDefaultDeliveryDetails() {
    final apartment =
        Provider.of<ProfileProvider>(context, listen: false).defaultApartment;
    final aprtmentId = apartment != null ? apartment.id : '';
    final currentDate = DateTime.now().getRequestFormatDate();
    if (aprtmentId != null && aprtmentId != '') {
      fetchDeliveryData(aprtmentId, currentDate);
    }
  }

  Widget _getSearch() {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
      child: SearchBar(
        placeholder: "Search by order, house number ...",
        onClear: () {
          setState(() {
            _query = '';
          });
        },
        onChange: (value) {
          setState(() {
            _query = value;
          });
        },
        onSubmit: (_) {},
      ),
    );
  }

  Future pullToRefresh() async {
    final aprtmentId = apartment != null ? apartment.id : '';
    return await Provider.of<DeliveryProvider>(context, listen: false)
        .fetchDeliveryListByApartment(
            aprtmentId, selectedDate.getRequestFormatDate());
  }

  void showApartmentList() {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    BotigaBottomModal(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Select apartment',
                  style: AppTheme.textStyle.color100.size(22).w700,
                ),
                SizedBox(
                  height: 25,
                ),
                SafeArea(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.40,
                    child: ListView(
                      children: [
                        ...profileProvider.allApartment.map((apt) {
                          return apartmentItem(apt);
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
            isDismissible: true)
        .show(context);
  }

  Widget apartmentItem(Apartment apt) {
    bool isSelectedApt = apartment.id == apt.id;
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            setState(() {
              apartment = apt;
            });
            final currentDate = DateTime.now().getRequestFormatDate();
            fetchDeliveryData(apt.id, currentDate);
          },
          contentPadding: EdgeInsets.all(0),
          title: Text(
            apt.apartmentName,
            style: isSelectedApt
                ? AppTheme.textStyle
                    .colored(AppTheme.primaryColor)
                    .w500
                    .size(17)
                : AppTheme.textStyle.color100.w500.size(15),
          ),
          leading: isSelectedApt
              ? Icon(
                  Icons.radio_button_on,
                  color: AppTheme.primaryColor,
                )
              : Icon(
                  Icons.radio_button_off,
                  color: AppTheme.color100,
                ),
        ),
        Divider(
          color: AppTheme.dividerColor,
          thickness: 1.5,
        )
      ],
    );
  }
}
