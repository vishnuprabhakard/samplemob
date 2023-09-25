import 'package:flutter/material.dart';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import './buyer_add_screen.dart';

class BuyerListingScreen extends StatefulWidget {
  @override
  _BuyerListingScreenState createState() => _BuyerListingScreenState();
}

class _BuyerListingScreenState extends State<BuyerListingScreen> {
  // Define a list to store the retrieved data.
  List<Map<String, dynamic>> buyersData = [];

  @override
  void initState() {
    super.initState();
    // Call the function to fetch data when the widget is initialized.
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
      final connection =
          await _connectToSqlServerDirectlyPlugin.initializeConnection(
              '192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
              instance: 'sqlerp');

      final result = await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult(
          'SELECT BuyerID,Name,DOB,Department,Gender,MobileNumber FROM BuyerMob');

      // Ensure that the result is a List<Map<String, dynamic>>.
      final List<Map<String, dynamic>> resultList = [];

      // Iterate through the result and cast each item to the desired type.
      for (var item in result) {
        if (item is Map<String, dynamic>) {
          resultList.add(item);
        }
      }

      // Update the state with the retrieved data.
      setState(() {
        buyersData = resultList;
      });
    } catch (e) {
      // Handle any errors here.
      print('Error: $e');
    }
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Listing'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerAddScreen(
                    buyerData: {},
                    mode: '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: buyersData.length,
          itemBuilder: (context, index) {
            final buyer = buyersData[index];
            return ListTile(
              title: Text(' ${buyer['Name']}'),
              subtitle: Text(' ${buyer['Department']}'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'view',
                    child: Text('View'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (String choice) {
                  if (choice == 'view') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerAddScreen(
                          buyerData: buyer,
                          mode: 'VIEW', // Pass 'VIEW' mode when viewing
                        ),
                      ),
                    );
                  } else if (choice == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerAddScreen(
                          buyerData: buyer,
                          mode: 'EDIT', // Pass 'EDIT' mode when editing
                        ),
                      ),
                    );
                  } else if (choice == 'delete') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerAddScreen(
                          buyerData: buyer,
                          mode: 'DEL', // Pass 'DEL' mode when deleting
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
