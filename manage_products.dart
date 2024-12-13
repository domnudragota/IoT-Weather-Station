import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2/main.dart';

class ManageProductsPage extends StatefulWidget {
  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController inStockController = TextEditingController();

  String? editingProductId;

  void saveProduct() {
    String name = nameController.text;
    List<String> colors = colorController.text.split(',').map((e) => e.trim()).toList();
    bool inStock = inStockController.text.toLowerCase() == 'true';

    if (editingProductId == null) {
      FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'color': colors,
        'inStock': inStock,
      });
    } else {
      FirebaseFirestore.instance.collection('products').doc(editingProductId).update({
        'name': name,
        'color': colors,
        'inStock': inStock,
      });
      editingProductId = null;
    }

    nameController.clear();
    colorController.clear();
    inStockController.clear();
  }

  void deleteProduct(String id) {
    FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  void editProduct(DocumentSnapshot document) {
    setState(() {
      editingProductId = document.id;
      nameController.text = document['name'] ?? 'Unnamed Product';
      colorController.text = (document['color'] as List).join(', ') ?? 'Unknown';
      inStockController.text = document['inStock'].toString() ?? 'false';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'Manage Products',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      backgroundColor: Colors.lightBlue[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Product Name TextField
            CustomTextField(
              controller: nameController,
              labelText: 'Product Name',
            ),
            SizedBox(height: 10),
            // Colors TextField
            CustomTextField(
              controller: colorController,
              labelText: 'Colors (comma separated)',
            ),
            SizedBox(height: 10),
            // In Stock TextField
            CustomTextField(
              controller: inStockController,
              labelText: 'In Stock (true/false)',
            ),
            SizedBox(height: 20),
            // Add/Update Button
            CustomElevatedButton(
              text: editingProductId == null ? 'Add Product' : 'Update Product',
              onPressed: saveProduct,
            ),
            SizedBox(height: 20),
            // Products List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      String name = data['name'] ?? 'Unnamed Product';
                      List<dynamic> colors = data['color'] ?? ['Unknown'];
                      bool inStock = data['inStock'] ?? false;

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Colors: ${colors.join(', ')}\nIn Stock: ${inStock ? "Yes" : "No"}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () => editProduct(document),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => deleteProduct(document.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
