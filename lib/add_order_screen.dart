import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddOrderScreen extends StatefulWidget {
  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final DBHelper dbHelper = DBHelper();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _targetCostController = TextEditingController();
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> selectedItems = [];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    final items = await dbHelper.getFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  Future<void> _saveOrder() async {
    if (_dateController.text.isEmpty || _targetCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    double totalCost = selectedItems.fold(
      0.0,
      (sum, item) => sum + item['cost'],
    );

    if (totalCost > double.parse(_targetCostController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected items exceed target cost!')),
      );
      return;
    }

    String foodItemNames = selectedItems.map((item) => item['name']).join(', ');

    await dbHelper.database.then((db) {
      db.insert('order_plan', {
        'date': _dateController.text,
        'target_cost': double.parse(_targetCostController.text),
        'food_items': foodItemNames,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Order'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _targetCostController,
              decoration: InputDecoration(labelText: 'Target Cost'),
              keyboardType: TextInputType.number,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return ListTile(
                    title: Text('${item['name']} - \$${item['cost']}'),
                    trailing: Checkbox(
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedItems.add(item);
                          } else {
                            selectedItems.remove(item);
                          }
                        });
                      },
                      value: selectedItems.contains(item),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveOrder,
              child: Text('Save Order'),
            ),
          ],
        ),
      ),
    );
  }
}
