import 'package:flutter/material.dart';
import 'db_helper.dart';

class ViewOrdersScreen extends StatefulWidget {
  @override
  _ViewOrdersScreenState createState() => _ViewOrdersScreenState();
}

class _ViewOrdersScreenState extends State<ViewOrdersScreen> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> orders = [];

  Future<void> _loadOrders(String date) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'order_plan',
      where: 'date = ?',
      whereArgs: [date],
    );

    setState(() {
      orders = results;
    });

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No orders found for this date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Orders'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
            ),
            ElevatedButton(
              onPressed: () {
                _loadOrders(_dateController.text);
              },
              child: Text('Search Orders'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Date: ${order['date']}'),
                      subtitle: Text('Items: ${order['food_items']}'),
                      trailing: Text('Target Cost: \$${order['target_cost']}'),
                    ),
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
