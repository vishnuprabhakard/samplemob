import 'package:flutter/material.dart';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import './employye_Add_Screen.dart';

class EmployeeListingScreen extends StatefulWidget {
  @override
  _EmployeeListingScreenState createState() => _EmployeeListingScreenState();
}

class _EmployeeListingScreenState extends State<EmployeeListingScreen> {
  List<Map<String, dynamic>> employeesData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
      final connection =
          await _connectToSqlServerDirectlyPlugin.initializeConnection(
              '192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
              instance: 'sqlerp');

      // Execute a SQL query to select data from the "EmployeeMob" table.
      final result = await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult(
          'SELECT EmployeeID,Username,Password,Name,DOB,Department,Gender,MobileNumber FROM EmployeeMob');

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
        employeesData = resultList;
      });
    } catch (e) {
      // Handle any errors here.
      print('Error: $e');
    }
  }

  Future<void> _handleRefresh() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Listing'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeAddScreen(
                    employeeData: {},
                    mode: '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Scrollbar(
          child: ListView.builder(
            itemCount: employeesData.length,
            itemBuilder: (context, index) {
              final employee = employeesData[index];
              return ListTile(
                title: Text(' ${employee['Name']}'),
                subtitle: Text(' ${employee['Department']}'),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
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
                          builder: (context) => EmployeeAddScreen(
                            employeeData: employee,
                            mode: 'VIEW', // Pass 'VIEW' mode when viewing
                          ),
                        ),
                      );
                    } else if (choice == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeAddScreen(
                            employeeData: employee,
                            mode: 'EDIT', // Pass 'EDIT' mode when editing
                          ),
                        ),
                      );
                    } else if (choice == 'delete') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeAddScreen(
                            employeeData: employee,
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
      ),
    );
  }
}
