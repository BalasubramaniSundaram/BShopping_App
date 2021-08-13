import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/cart_service.dart';
import 'package:shopping_app/services/product_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(
      {Key? key,
      required this.data,
      required this.userData,
      required this.productService})
      : super(key: key);

  final List<Map<String, dynamic>> data;

  final Map<String, dynamic> userData;

  final ProductService productService;

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, CartService cart, _) {
        return ListView(
          children: List.generate(
            widget.data.length,
            (index) => Card(
              elevation: 2,
              shadowColor: Colors.blue.shade200,
              child: ListTile(
                contentPadding: EdgeInsets.all(10.0),
                leading: Image.asset(
                  widget.data[index]['productImage'].toString(),
                  fit: BoxFit.contain,
                  width: 60,
                  height: 60,
                ),
                subtitle: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Model: ${widget.data[index]['productModelNumber'].toString()}',
                        style: TextStyle(color: Colors.black26, fontSize: 10),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4),
                      alignment: Alignment.centerLeft,
                      child: Text(
                          'Price: \u{20B9} ${widget.data[index]['productPrice']}',
                          style: TextStyle(color: Colors.black, fontSize: 14)),
                    ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    widget.data[index]['productName'].toString(),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () async {
                    await cart.insert('cart', {
                      'id': widget.userData['id'],
                      'product': widget.data[index]['productModelNumber']
                    }).then((value) {
                      if (value) {
                        cart.usersService.update();
                      }
                    });
                  },
                ),
                onTap: () {
                  buildShowDialog(context, index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> buildShowDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.asset(
                    widget.data[index]['productImage'].toString(),
                    fit: BoxFit.contain,
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.data[index]['productName'].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Text(
                    'Model: ${widget.data[index]['productModelNumber'].toString()}',
                    style: TextStyle(color: Colors.black26, fontSize: 15),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Price: \u{20B9} ${widget.data[index]['productPrice']}',
                        style: TextStyle(color: Colors.black, fontSize: 14)),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${widget.data[index]['productDescription']}',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              letterSpacing: 1)),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
