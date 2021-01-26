import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/index.dart' show ProfileProvider;
import '../../theme/index.dart';
import '../../widget/index.dart' show Loader, HttpExceptionWidget;
import '../delivery/index.dart' show DeliveryScreen;
import '../profile/index.dart' show ProfileScreen;

class HomeScreen extends StatefulWidget {
  static const routeName = 'home-screen';

  final int index;

  HomeScreen({this.index});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> _pages = [
    DeliveryScreen(),
    ProfileScreen(),
  ];

  int _selectedPageIndex;
  bool _isLoading = false;
  bool _isError = false;
  var _error;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = widget.index ?? 0;
    _initializeHome();
  }

  void _selectPage(int index) {
    setState(() => _selectedPageIndex = index);
    setStatusBarBrightness();
  }

  void setStatusBarBrightness() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
          _selectedPageIndex == 0 ? Brightness.dark : Brightness.light,
    ));
  }

  void _initializeHome() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (!profileProvider.hasProfile) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _error = null;
      });
      try {
        await profileProvider.fetchProfile();
      } catch (err) {
        setState(() {
          _isError = true;
          _error = err;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _isLoading
          ? Loader()
          : _isError
              ? HttpExceptionWidget(
                  exception: _error,
                  onTap: () {
                    _initializeHome();
                  },
                )
              : _pages[_selectedPageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: AppTheme.color25, blurRadius: 20)]),
        child: (!_isLoading && !_isError)
            ? BottomNavigationBar(
                backgroundColor: AppTheme.backgroundColor,
                selectedItemColor: AppTheme.primaryColor,
                selectedLabelStyle: AppTheme.textStyle.w500.size(12),
                unselectedLabelStyle: AppTheme.textStyle.w500.size(13),
                unselectedItemColor: AppTheme.navigationItemColor,
                type: BottomNavigationBarType.fixed,
                onTap: _selectPage,
                currentIndex: _selectedPageIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(BotigaIcons.package),
                    label: 'Delivery',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(BotigaIcons.profile),
                    label: 'Profile',
                  ),
                ],
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
