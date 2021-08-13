import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/cart_service.dart';
import 'package:shopping_app/services/database_provider.dart';
import 'package:shopping_app/services/product_service.dart';
import 'package:shopping_app/services/user_service.dart';
import 'package:shopping_app/view/login_page.dart';

Future<void> main() async {
  /// Need to initial binding for necessary things.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UsersService(DatabaseProvider.get)),
        ProxyProvider<UsersService, ProductService>(
          update: (context, value, previous) => ProductService(value),
        ),
        ProxyProvider<UsersService, CartService>(
          update: (context, value, previous) =>
              CartService(value, DatabaseProvider.get),
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginPage(
        canShowAuthenticateMessage: true,
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
