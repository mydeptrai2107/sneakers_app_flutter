import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/respository/components/product_container.dart';
import 'package:ecommerce_app/respository/components/route_names.dart';
import 'package:ecommerce_app/utils/fav_provider.dart';
import 'package:ecommerce_app/utils/formatter.dart';
import 'package:ecommerce_app/view/home/product_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  final db2 = FirebaseFirestore.instance.collection('Favourites');
  final id = FirebaseAuth.instance.currentUser!.uid.toString();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  // Biến cho bộ lọc giá và sắp xếp tên
  double minPrice = 0;
  double maxPrice = 1000000;
  String selectedSort = 'Tất cả';

  Future<void> initData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection = firestore.collection('products');

    try {
      QuerySnapshot querySnapshot = await productsCollection.get();
      products = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Khởi tạo filteredProducts với toàn bộ sản phẩm
      filteredProducts = List.from(products);
      setState(() {});
    } catch (_) {}
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  void searchProducts(String query) {
    // Lọc sản phẩm theo tên và giá
    List<Map<String, dynamic>> tempList = products.where((product) {
      double price = double.tryParse(product['productprice'].toString()) ?? 0;
      bool matchesQuery = product['productname']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase());
      bool matchesPrice = price >= minPrice && price <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();

    // Sắp xếp theo tên nếu cần
    if (selectedSort == 'A-Z') {
      tempList.sort((a, b) =>
          a['productname'].toString().compareTo(b['productname'].toString()));
    } else if (selectedSort == 'Z-A') {
      tempList.sort((a, b) =>
          b['productname'].toString().compareTo(a['productname'].toString()));
    }

    setState(() {
      filteredProducts = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favprovider = Provider.of<FavouriteProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f9),
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, RouteNames.navbarscreen);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Tất cả sản phẩm'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Tìm kiếm sản phẩm
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xff6A6A6A)),
                    hintText: 'Tìm kiếm giày...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: searchProducts,
                ),
                const SizedBox(height: 10),

                // Bộ lọc giá và sắp xếp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Lọc theo giá
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lọc theo giá:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RangeSlider(
                            values: RangeValues(minPrice, maxPrice),
                            min: 0,
                            max: 1000000,
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey[300],
                            divisions: 20,
                            labels: RangeLabels(
                              Formatter.formatCurrency(minPrice.toInt()),
                              Formatter.formatCurrency(maxPrice.toInt()),
                            ),
                            onChanged: (values) {
                              setState(() {
                                minPrice = values.start;
                                maxPrice = values.end;
                              });
                              searchProducts(searchController.text);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Dropdown filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButton<String>(
                        value: selectedSort,
                        underline: Container(),
                        icon: const Icon(Icons.sort, color: Colors.blue),
                        items: ['Tất cả', 'A-Z', 'Z-A'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedSort = newValue!;
                          });
                          searchProducts(searchController.text);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ShowProductContainer(
                    subtitle: filteredProducts[index]['productname'],
                    imagelink: filteredProducts[index]['imagelink'],
                    price: Formatter.formatCurrency(
                      double.parse(filteredProducts[index]['productprice'])
                          .toInt(),
                    ),
                    quantity: 0,
                    fav: IconButton(
                      onPressed: () async {
                        if (favprovider.items
                            .contains(filteredProducts[index]['productId'])) {
                          favprovider
                              .remove(filteredProducts[index]['productId']);
                          db2
                              .doc(id)
                              .collection('items')
                              .doc(filteredProducts[index]['productId'])
                              .delete();
                        } else {
                          favprovider.add(filteredProducts[index]['productId']);
                          db2
                              .doc(id)
                              .collection('items')
                              .doc(filteredProducts[index]['productId'])
                              .set({
                            'product id':
                                filteredProducts[index]['productId'].toString(),
                            'name': filteredProducts[index]['productname']
                                .toString(),
                            'subtitle':
                                filteredProducts[index]['title'].toString(),
                            'image':
                                filteredProducts[index]['imagelink'].toString(),
                            'price': filteredProducts[index]['productprice']
                                .toString(),
                            'description': filteredProducts[index]
                                    ['description']
                                .toString(),
                          });
                        }
                      },
                      icon: Icon(
                        favprovider.items
                                .contains(filteredProducts[index]['productId'])
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
                        color: Colors.red,
                      ),
                    ),
                    onclick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ProductDetails(
                            title: filteredProducts[index]['productname'],
                            price: filteredProducts[index]['productprice'],
                            productid: filteredProducts[index]['productId'],
                            unitprice: filteredProducts[index]['unitprice'],
                            image: filteredProducts[index]['imagelink'],
                            description: filteredProducts[index]['description'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
