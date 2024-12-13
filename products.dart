import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/main.dart';

class ProductsPage extends StatelessWidget {
  final Stream<QuerySnapshot> _productsStream =
  FirebaseFirestore.instance.collection('products').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Custom height for the AppBar
        child: AppBar(
          automaticallyImplyLeading: false, // Remove default back button
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue, // Dark navy blue
                  Color(0xFF005792), // Lighter blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Products',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true, // Center the title
          backgroundColor: Colors.transparent, // Make background transparent
          elevation: 0, // Remove shadow
        ),
      ),
      backgroundColor: Colors.lightBlue[100],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _productsStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Check if there are any documents in the snapshot
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No products available.'));
                }

                // Build the data rows for each product
                List<DataRow> productRows = snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                  String name = data['name'] ?? 'Unnamed Product';
                  bool inStock = data['inStock'] ?? false;

                  return DataRow(cells: [
                    DataCell(Text(name)),
                    DataCell(Text(inStock ? 'Yes' : 'No')),
                  ]);
                }).toList();

                // Display the products in a table
                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'Product Name',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'In Stock',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                        rows: productRows,
                        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            return Colors.white; // Background color for rows
                          },
                        ),
                        headingRowColor: MaterialStateProperty.all(Colors.blueAccent),
                        headingTextStyle: TextStyle(color: Colors.white),
                        columnSpacing: 24.0,
                        dividerThickness: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16), // Add spacing between the table and the button
          CustomElevatedButton(
            text: 'Access TCP Sensor Data',
            onPressed: () {
              Navigator.pushNamed(context, '/tcp'); // Navigate to the TCP Sensor Data page
            },
          ),
          SizedBox(height: 16), // Add spacing between buttons
          CustomElevatedButton(
            text: 'View Sensor Data Graph',
            onPressed: () {
              Navigator.pushNamed(context, '/chart'); // Navigate to the Chart Page
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/manage');
        },
        child: Icon(Icons.manage_accounts),
        tooltip: 'Manage Products',
      ),
    );
  }
}
