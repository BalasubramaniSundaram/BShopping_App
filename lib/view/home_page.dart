import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/product_service.dart';
import 'package:shopping_app/services/user_service.dart';
import 'package:shopping_app/view/cart_page.dart';
import 'package:shopping_app/view/login_page.dart';
import 'package:shopping_app/view/product_page.dart';

class ShoppingAppHomePage extends StatefulWidget {
  const ShoppingAppHomePage({Key? key}) : super(key: key);

  @override
  _ShoppingAppHomePageState createState() => _ShoppingAppHomePageState();
}

class _ShoppingAppHomePageState extends State<ShoppingAppHomePage>
    with SingleTickerProviderStateMixin {
  late UsersService usersService;
  Map<String, dynamic> userData = {};
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;
  int cartItemCount = 0;
  List<Map<String, dynamic>> cartItems = [{}];

  static const List<String> tabs = [
    'Mobile',
    'Laptop',
    'Watch',
    'HeadPhone',
    'AC'
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.index = 0;
    tabController.addListener(handleTabChange);
  }

  void handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, ProductService value, _) {
        return SafeArea(
          child: DefaultTabController(
            length: tabController.length,
            child: Scaffold(
              key: scaffoldKey,
              appBar: buildAppBar(context),
              drawer: buildDrawer(context),
              body: FutureBuilder<List<Map<String, dynamic>>>(
                future: value.getProducts(),
                initialData: [{}],
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.waiting) {}
                  return ProductPage(
                    data: getProductsByType(
                      snapshot,
                      tabs[tabController.index],
                    ),
                    userData: userData,
                    productService: value,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await usersService.clearJson({}).then(
                (value) async {
                  await Navigator.of(context)
                      .pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        canShowAuthenticateMessage: false,
                      ),
                    ),
                  )
                      .then(
                    (value) {
                      final snackBar =
                          SnackBar(content: Text('Logout Successfully'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  );
                },
              );
            },
            child: Text('Log Out'),
          )
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${userData["userName"]}',
              textAlign: TextAlign.start,
            ),
            buildCartIcon(context),
          ],
        ),
      ),
      bottom: buildTabBar(),
      leading: Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
            child: Image.asset(
              'images/People_Circle4.png',
            ),
          ),
        ),
      ),
    );
  }

  TabBar buildTabBar() {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      tabs: [
        Tab(
          text: 'Mobile',
          icon: Icon(Icons.mobile_friendly_outlined),
        ),
        Tab(
          text: 'Laptop',
          icon: Icon(Icons.laptop),
        ),
        Tab(
          text: 'Watch',
          icon: Icon(Icons.watch),
        ),
        Tab(
          text: 'HeadPhone',
          icon: Icon(Icons.headset),
        ),
        Tab(
          text: 'AC',
          icon: Icon(Icons.ac_unit_rounded),
        ),
      ],
    );
  }

  GestureDetector buildCartIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                userData: userData,
              ),
            ));
      },
      child: Stack(
        children: [
          Positioned(
            child: Icon(Icons.shopping_cart),
          ),
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$cartItemCount',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
            top: 5,
            width: 15,
            height: 15,
          ),
        ],
      ),
    );
  }

  Future<int> updateCartItemsCount(int userID) async {
    final db = await usersService.databaseProvider.db();
    cartItems = await db.query('cart', where: "id = ?", whereArgs: [userID]);
    return Future.value(cartItems.length);
  }

  Future<void> updateCartCount() async {
    cartItemCount = await updateCartItemsCount(userData['id']);
  }

  List<Map<String, dynamic>> getProductsByType(
      AsyncSnapshot<List<Map<String, dynamic>>> snapshot, String productType) {
    return snapshot.data
            ?.where((Map<String, dynamic> element) =>
                element["productType"] == productType)
            .toList() ??
        [{}];
  }

  @override
  void didUpdateWidget(covariant ShoppingAppHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateCartCount();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    usersService = Provider.of<UsersService>(context);
    await usersService.readFormJson().then((value) {
      setState(() {
        userData = value;
        updateCartCount();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}
