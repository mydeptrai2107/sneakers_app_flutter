import 'package:ecommerce_app/respository/components/route_names.dart';
import 'package:ecommerce_app/view/admin/admin_order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  final List<String> _statusList = [
    'Tất cả',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusList.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(fontSize: 18),
        ),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statusList
              .map((status) => Tab(text: _formatStatus(status)))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statusList.map((status) {
          return _buildOrderList(status == 'Tất cả' ? null : status);
        }).toList(),
      ),
    );
  }

  /// Hàm hiển thị danh sách đơn hàng theo trạng thái
  Widget _buildOrderList(String? status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Orders')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Không có đơn hàng nào.'));
        }

        var orders = snapshot.data!.docs;

        // Lọc theo trạng thái nếu có chọn
        if (status != null) {
          orders = orders.where((order) {
            var orderData = order.data() as Map<String, dynamic>;
            return orderData['status'] == status;
          }).toList();
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            var orderData = order.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text("Đơn hàng: ${orderData['orderId']}"),
                subtitle:
                    Text("Trạng thái: ${_formatStatus(orderData['status'])}"),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: _getStatusColor(orderData['status'])),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Hàm chuyển trạng thái từ key thành text dễ hiểu
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

  /// Hàm đổi màu trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
