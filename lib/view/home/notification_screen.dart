import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/respository/components/app_styles.dart';
import 'package:ecommerce_app/respository/components/route_names.dart';
import 'package:ecommerce_app/utils/formatter.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> products = [];

  initData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference productsCollection = firestore.collection('products');
    try {
      QuerySnapshot querySnapshot = await productsCollection.get();
      products = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      setState(() {});
    } catch (_) {
    }
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfff7f7f9),
        appBar: AppBar(
          backgroundColor: const Color(0xfff7f7f9),
          title: const Text('Thông báo'),
          titleTextStyle: TextStyling.apptitle,
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.navbarscreen);
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
        body: products.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
                child: Column(
                  children: [
                    Container(
                      height: 135,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                products[4]['imagelink'],
                                height: 50,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chúng tôi có sản phẩm mới',
                                    style: TextStyle(
                                      color: AppColor.backgroundColor,
                                      fontFamily: 'Raleway-Medium',
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Text(
                                    'Sản phẩm có ưu đãi',
                                    style: TextStyle(
                                        color: AppColor.backgroundColor,
                                        fontFamily: 'Raleway-Medium',
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        Formatter.formatCurrency(double.parse(
                                                products[4]['unitprice'])
                                            .toInt()),
                                        style: const TextStyle(
                                            fontFamily: 'Poppins Medium',
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 135,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                products[6]['imagelink'],
                                height: 50,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chúng tôi có sản phẩm mới',
                                    style: TextStyle(
                                        color: AppColor.backgroundColor,
                                        fontFamily: 'Raleway-Medium',
                                        fontSize: 14),
                                  ),
                                  const Text(
                                    'Sản phẩm có ưu đãi',
                                    style: TextStyle(
                                      color: AppColor.backgroundColor,
                                      fontFamily: 'Raleway-Medium',
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        Formatter.formatCurrency(double.parse(
                                                products[6]['unitprice'])
                                            .toInt()),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins Medium',
                                          fontSize: 14,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 135,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                products[7]['imagelink'],
                                height: 50,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chúng tôi có sản phẩm mới',
                                    style: TextStyle(
                                        color: AppColor.backgroundColor,
                                        fontFamily: 'Raleway-Medium',
                                        fontSize: 14),
                                  ),
                                  const Text(
                                    'Sản phẩm có ưu đãi',
                                    style: TextStyle(
                                        color: AppColor.backgroundColor,
                                        fontFamily: 'Raleway-Medium',
                                        fontSize: 14),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        Formatter.formatCurrency(double.parse(
                                                products[7]['unitprice'])
                                            .toInt()),
                                        style: const TextStyle(
                                            fontFamily: 'Poppins Medium',
                                            fontSize: 14),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox());
  }
}
