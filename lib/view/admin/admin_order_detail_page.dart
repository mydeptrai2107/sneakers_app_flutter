import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? orderData;
  bool isLoading = true;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      DocumentSnapshot orderSnapshot =
          await _firestore.collection('Orders').doc(widget.orderId).get();

      if (orderSnapshot.exists) {
        setState(() {
          orderData = orderSnapshot.data() as Map<String, dynamic>;
          selectedStatus = orderData!['status'];
          isLoading = false;
        });
      }
    } catch (_) {}
  }

  Future<void> updateOrderStatus(String newStatus) async {
    try {
      await _firestore.collection('Orders').doc(widget.orderId).update({
        'status': newStatus,
      });

      setState(() {
        selectedStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái thành công!')),
      );
    } catch (_) {}
  }

  Widget _buildOrderInfoTile(IconData icon, String title, String value) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card thông tin đơn hàng
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildOrderInfoTile(Icons.confirmation_number,
                          "Mã đơn hàng", orderData!['orderId']),
                      _buildOrderInfoTile(
                          Icons.email, "Email khách hàng", orderData!['email']),
                      _buildOrderInfoTile(
                          Icons.phone, "Số điện thoại", orderData!['phone']),
                      _buildOrderInfoTile(
                          Icons.location_on, "Địa chỉ", orderData!['address']),
                      _buildOrderInfoTile(Icons.attach_money, "Tổng tiền",
                          "\$${orderData!['totalPrice']}"),
                      _buildOrderInfoTile(
                          Icons.access_time, "Trạng thái", selectedStatus!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Danh sách sản phẩm
              const Text(
                "Danh sách sản phẩm",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(thickness: 1),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderData!['items'].length,
                itemBuilder: (context, index) {
                  var item = orderData!['items'][index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.shopping_bag, color: Colors.green),
                      title: Text(item['productName'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Số lượng: ${item['quantity']}"),
                      trailing: Text(
                        "\$${item['unitPrice']}",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Cập nhật trạng thái đơn hàng
              const Text(
                "Cập nhật trạng thái",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  underline: SizedBox(),
                  items: [
                    'pending',
                    'processing',
                    'shipped',
                    'delivered',
                    'cancelled'
                  ].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        _formatStatus(status),
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      updateOrderStatus(newStatus);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
