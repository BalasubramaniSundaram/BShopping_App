import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/cart_service.dart';
import 'package:shopping_app/services/database_provider.dart';
import 'package:shopping_app/services/product_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key, required this.userData}) : super(key: key);

  final Map<String, dynamic> userData;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, int> localCartItems = {};

  @override
  void initState() {
    super.initState();
    groupCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, CartService value, child) {
        return SafeArea(
          child: Scaffold(
            appBar: buildAppBar(context),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight - 100,
                      child: buildReorderableListView(value),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Add Item'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildReorderableListView(CartService value) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          performReorder(oldIndex, newIndex);
        });
      },
      children: localCartItems.entries.map<Widget>((e) {
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          child: Consumer(
            builder: (context, ProductService value, child) {
              return FutureBuilder<Map<String, dynamic>>(
                initialData: {},
                future: value.getProductsByProductModel(e.key),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        strokeWidth: 1,
                      ),
                    );
                  }

                  return Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(5),
                      leading: Image.asset(snapshot.data!["productImage"]),
                      title: Text(snapshot.data!['productName']),
                      subtitle: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Model: ${snapshot.data!['productModelNumber'].toString()}',
                              style: TextStyle(
                                  color: Colors.black26, fontSize: 10),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(4),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                'Price: \u{20B9} ${snapshot.data!['productPrice']}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14)),
                          ),
                        ],
                      ),
                      trailing:
                          Container(width: 30, child: Text(e.value.toString())),
                    ),
                  );
                },
              );
            },
          ),
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (direction) async {
            await value.delete(
              'cart',
              {
                'id': widget.userData['id'],
                'product': e.key,
              },
            ).then(
              (canRefresh) async {
                if (canRefresh) {
                  localCartItems.remove(e.key);
                  await groupCartItems().then((_) {
                    value.usersService.update();
                  });
                }
              },
            );
          },
        );
      }).toList(),
    );
  }

  void performReorder(int oldIndex, int newIndex) {
    final List<String> tempKeys = localCartItems.keys.toList();
    final String replacementKey = tempKeys[oldIndex];

    /// Remove the item from old index
    tempKeys.removeAt(oldIndex);

    /// insert the removed item into the keys list
    tempKeys.insert(newIndex == 0 ? 0 : newIndex - 1, replacementKey);

    final Map<String, int> tempLocalItems = Map.from(localCartItems);

    /// Empty the local item
    localCartItems = {};

    /// Rearrange the items
    tempKeys.forEach((element) {
      localCartItems[element] = tempLocalItems[element]!;
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      leading: BackButton(
        color: Colors.blue,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Cart Items',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Future<void> groupCartItems() async {
    final db = await DatabaseProvider.get.db();
    await db.query('cart',
        where: "id = ?", whereArgs: [widget.userData['id']]).then((value) {
      setState(() {
        value.forEach((item) {
          if (!localCartItems.containsKey(item['product'])) {
            var count = value
                .where((element) => element["product"] == item["product"])
                .length;
            localCartItems[item['product'].toString()] = count;
          }
        });
      });
    });
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    groupCartItems();
  }
}
