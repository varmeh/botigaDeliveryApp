import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/auth/index.dart' show Welcome, VerifyOtp;

import 'app/delivery/index.dart' show DeliveryScreen;
import 'app/home/index.dart' show HomeScreen;
import 'app/onboarding/index.dart' show SplashScreen;
import 'app/orders/index.dart' show OrderDetails;
import 'providers/index.dart'
    show ProfileProvider, ServicesProvider, DeliveryProvider, OrdersProvider;
import 'util/index.dart' show Http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restricting Orientation to Portrait Mode only
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  // await Flavor.shared.init();
  await Http.fetchToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServicesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeliveryProvider(),
        ),
      ],
      child: BotigaDeliveryApp(),
    ),
  );
}

class BotigaDeliveryApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      title: 'Botiga Business',
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (ctx) => SplashScreen(),
        OrderDetails.routeName: (ctx) => OrderDetails(),
        DeliveryScreen.routeName: (ctx) => DeliveryScreen(),
        Welcome.routeName: (ctx) => Welcome(),
        VerifyOtp.routeName: (ctx) => VerifyOtp(),
        HomeScreen.routeName: (ctx) => HomeScreen()
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => null,
        );
      },
    );
  }
}
