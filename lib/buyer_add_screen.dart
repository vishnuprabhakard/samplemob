import 'dart:ffi';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import 'package:flutter/material.dart';
import './buyer_listing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BuyerApp",
      home: BuyerAddScreen(
        buyerData: const {},
        mode: '',
      ),
    );
  }
}

class BuyerAddScreen extends StatefulWidget {
  final Map<String, dynamic> buyerData;
  final String mode; // Add a mode parameter

  BuyerAddScreen({
    required this.buyerData,
    required this.mode, // Initialize the mode parameter
  });

  @override
  _BuyerAddScreenState createState() => _BuyerAddScreenState();
}

class _BuyerAddScreenState extends State<BuyerAddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  String? _selectedGender = 'M'; // Initialize as nullable
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController mode = TextEditingController();

  bool _isViewMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text fields with the passed data (if available).
    if (widget.buyerData.isNotEmpty) {
      _nameController.text = widget.buyerData['Name'] ?? '';
      _dobController.text = widget.buyerData['DOB'] ?? '';
      _departmentController.text = widget.buyerData['Department'] ?? '';
      _selectedGender = widget.buyerData['Gender'] ?? 'M';
      _mobileNumberController.text = widget.buyerData['MobileNumber'] ?? '';
      mode.text = widget.mode;
      if (widget.mode == 'VIEW') {
        _isViewMode = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Buyer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  enabled: !_isViewMode,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(labelText: 'DOB (YYYY-MM-DD)'),
                  enabled: !_isViewMode,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter a date of birth';
                    }
                    return null;
                  },
                ),
                // Add fields for Gender and MobileNumber
                TextFormField(
                  controller: _departmentController,
                  decoration: InputDecoration(labelText: 'Department'),
                  enabled: !_isViewMode,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter a department';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Text('Gender:'),
                    Radio(
                      value: 'M',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        if (!_isViewMode) {
                          // Only allow changes when not in view mode
                          setState(() {
                            _selectedGender = value as String?;
                          });
                        }
                      },
                      // Disable the radio button when in view mode
                      toggleable: !_isViewMode,
                    ),
                    Text('Male'),
                    Radio(
                      value: 'F',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        if (!_isViewMode) {
                          // Only allow changes when not in view mode
                          setState(() {
                            _selectedGender = value as String?;
                          });
                        }
                      },
                      // Disable the radio button when in view mode
                      toggleable: !_isViewMode,
                    ),
                    Text('Female'),
                  ],
                ),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  enabled: !_isViewMode,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) {
                      return 'Please enter a mobile number';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid integer';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                if (widget.mode == 'EDIT')
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        // Validation passed, proceed with updating data
                        _updateBuyer();
                        Navigator.pop(context); // Close the edit screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyerListingScreen(),
                          ),
                        );
                      }
                    },
                    child: Text('Update'),
                  )
                else if (widget.mode == 'DEL')
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog();
                    },
                    child: Text('Delete'),
                  )
                else if ((widget.mode != 'VIEW') &&
                    (widget.mode != 'EDIT') &&
                    (widget.mode != 'DEL'))
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        // Validation passed, proceed with saving data
                        saveToDatabase();
                      }
                    },
                    child: Text('Save'),
                  )
              ],
            )),
      ),
    );
  }

  void _reloadPreviousScreen() {
    // Use Navigator.pop to navigate back to the previous screen
    Navigator.pop(context);

    // If you need to refresh the previous screen, you can call a function or setState here.
    // For example, if the previous screen is EmployeeListingScreen, you can call a method to refresh its data.
  }

  //UPDATE WID
  Future<bool> updateBuyerInDataSource(
      Map<String, dynamic> updatedBuyerData) async {
    try {
      final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();

      // Extract the employeeID from the updatedEmployeeData
      final int buyerID = updatedBuyerData['BuyerID'];

      final queryResult =
          await _connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
        "UPDATE BuyerMob "
        "SET name = '${updatedBuyerData['Name']}', "
        "dob = '${updatedBuyerData['DOB']}', "
        "department = '${updatedBuyerData['Department']}', "
        "gender = '${updatedBuyerData['Gender']}', "
        "mobileNumber = '${updatedBuyerData['MobileNumber']}' "
        "WHERE BuyerID = $buyerID",
      );

      if (queryResult) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating buyer: $e');
      return false;
    }
  }

  void _updateBuyer() async {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.buyerData['Name'] = _nameController.text;
    widget.buyerData['DOB'] = _dobController.text;
    widget.buyerData['Department'] = _departmentController.text;
    widget.buyerData['Gender'] = _selectedGender;
    widget.buyerData['MobileNumber'] = _mobileNumberController.text;

    bool success = await updateBuyerInDataSource(widget.buyerData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record updated successfully.'),
        ),
      );
      _reloadPreviousScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update the record.'),
        ),
      );
    }
  }

  //DELETE  WID
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog.
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and proceed with the delete action.
                Navigator.of(context).pop();
                _deleteRecord();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecord() async {
    final int buyerID = widget.buyerData['BuyerID'] ?? '';

    bool success = await deleteRecordFromDataSource(buyerID);

    if (success) {
      // Optionally, you can show a confirmation message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted successfully.'),
        ),
      );
      _reloadPreviousScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete the record.'),
        ),
      );
    }
  }

  Future<bool> deleteRecordFromDataSource(int buyerID) async {
    final connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    await connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
      'Delete From BuyerMob where BuyerID = $buyerID',
    );
    return true;
  }

  //SAVE WID
  Future<void> saveToDatabase() async {
    // Initialize the connection to your SQL Server database
    final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    final connectionResult = await _connectToSqlServerDirectlyPlugin
        .initializeConnection('192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
            instance: 'sqlerp');

    try {
      if (connectionResult == null || connectionResult is String) {
        // Handle the case where connectionResult is a string (indicating an error)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to connect to the database: $connectionResult')),
        );
      } else {
        final queryResult =
            await _connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
          "INSERT INTO BuyerMob(name, dob, department, gender, mobileNumber)"
          "VALUES('${_nameController.text}', '${_dobController.text}', "
          "'${_departmentController.text}', '${_selectedGender}', "
          "'${_mobileNumberController.text}')",
        );

        if (queryResult) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8), // Spacer
                  Text('Data saved successfully'),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
          _reloadPreviousScreen();
          _nameController.clear();
          _dobController.clear();
          _departmentController.clear();
          _selectedGender = 'M'; // Assuming 'M' is the default value
          _mobileNumberController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save buyer data')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {}
  }
}

class BuyerListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Listing'),
      ),
      body: Center(
        child: Text('Buyer Listing Screen Content'),
      ),
    );
  }
}
