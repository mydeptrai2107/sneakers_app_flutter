import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/respository/components/app_styles.dart';
import 'package:ecommerce_app/respository/components/route_names.dart';
import 'package:ecommerce_app/utils/formatter.dart';
import 'package:ecommerce_app/view/admin/admin_edit_product_page.dart';
import 'package:flutter/material.dart';

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    CollectionReference productsCollection = firestore.collection('products');
    QuerySnapshot querySnapshot = await productsCollection.get();
    setState(() {
      products = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      _filteredProducts = products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      _filteredProducts = products
          .where((product) => product['productname']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> addOrUpdateProduct(
      {String? id, Map<String, dynamic>? product}) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProductScreen(productId: id, productData: product),
      ),
    );

    if (isUpdated == true) {
      fetchProducts();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await firestore.collection('products').doc(id).delete();
      fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xóa sản phẩm thành công!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi xóa sản phẩm!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> confirmDeleteProduct(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteProduct(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Quản Lý Sản Phẩm",
          style: TextStyle(fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.loginScreen);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 176, 173, 173),
                ),
                hintText: 'Tìm kiếm giày',
                hintStyle: TextStyling.hinttext,
                filled: true,
                fillColor: const Color.fromARGB(255, 234, 231, 231),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(child: Text("Không tìm thấy sản phẩm nào!"))
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.network(
                            product['imagelink'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          title: Text(product['productname']),
                          subtitle: Text(
                              "Giá: ${Formatter.formatCurrency(double.parse(product['productprice']).toInt())}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => addOrUpdateProduct(
                                    id: product['id'], product: product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    confirmDeleteProduct(product['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrUpdateProduct(),
        child: Icon(Icons.add),
      ),
    );
  }
}
