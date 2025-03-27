import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/respository/components/route_names.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Quản lý thành viên"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.loginScreen);
            },
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm người dùng...",
                filled: true,
                fillColor: const Color.fromARGB(255, 234, 231, 231),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(40),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('User Data').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Không có dữ liệu người dùng"));
                }

                var users = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((user) {
                  String name = (user['Full name'] ?? "").toLowerCase();
                  String email = (user['Email'] ?? "").toLowerCase();
                  return name.contains(searchQuery) ||
                      email.contains(searchQuery);
                }).toList();

                return users.isEmpty
                    ? Center(child: Text("Không tìm thấy người dùng"))
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          var user = users[index];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: user['image'] != null &&
                                        user['image']!.isNotEmpty
                                    ? NetworkImage(user['image'])
                                    : AssetImage('assets/default_avatar.png')
                                        as ImageProvider,
                              ),
                              title: Text(user['Full name'] ?? "Không có tên",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Email: ${user['Email'] ?? 'Không có email'}"),
                                  Text(
                                      "SĐT: ${user['phone'] ?? 'Không có số'}"),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserDetailScreen(userData: user),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailScreen({super.key, required this.userData});

  Widget _buildUserInfo(String? label, String? value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết người dùng")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userData['image'] != null &&
                      userData['image']!.isNotEmpty
                  ? NetworkImage(userData['image'])
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 20),
            _buildUserInfo("Tên đầy đủ", userData['Full name'], Icons.person),
            _buildUserInfo("Email", userData['Email'], Icons.email),
            _buildUserInfo("Số điện thoại", userData['phone'], Icons.phone),
            _buildUserInfo("Địa chỉ", userData['address'], Icons.location_on),
          ],
        ),
      ),
    );
  }
}
