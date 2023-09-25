import 'dart:ffi';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import 'package:flutter/material.dart';
import './employee_listing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Employee App",
      home: EmployeeAddScreen(
        employeeData: const {},
        mode: '',
      ),
    );
  }
}

class EmployeeAddScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  final String mode; // Add a mode parameter

  EmployeeAddScreen({
    required this.employeeData,
    required this.mode, // Initialize the mode parameter
  });

  @override
  _EmployeeAddScreenState createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _departmentController = TextEditingController();
  String? _selectedGender = 'M';
  TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController mode = TextEditingController();
  bool _isViewMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _departmentController.dispose();
    _mobileNumberController.dispose();
    _usernameController.dispose(); // Dispose of username controller
    _passwordController.dispose(); // Dispose of password controller
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the text fields with the passed data (if available).
    if (widget.employeeData.isNotEmpty) {
      _nameController.text = widget.employeeData['Name'] ?? '';
      _dobController.text = widget.employeeData['DOB'] ?? '';
      _departmentController.text = widget.employeeData['Department'] ?? '';
      _selectedGender = widget.employeeData['Gender'] ?? 'M';
      _mobileNumberController.text = widget.employeeData['MobileNumber'] ?? '';
      _usernameController.text = widget.employeeData['Username'] ?? '';
      _passwordController.text = widget.employeeData['Password'] ?? '';

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
        title: Text('Add Employee'),
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
              // Add fields for username and password
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                enabled: !_isViewMode,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                enabled: !_isViewMode,
                obscureText: true, // Hide the password input
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              if (widget.mode == 'EDIT')
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() == true) {
                      _updateEmployee();
                      Navigator.pop(context);
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
                      saveToDatabase();
                    }
                  },
                  child: Text('Save'),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _reloadPreviousScreen() {
    Navigator.pop(context);
  }

  //UPDATE WID
  Future<bool> updateEmployeeInDataSource(
      Map<String, dynamic> updatedEmployeeData) async {
    try {
      final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();

      // Extract the employeeID from the updatedEmployeeData
      final int employeeID = updatedEmployeeData['EmployeeID'];

      final queryResult =
          await _connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
        "UPDATE EmployeeMob "
        "SET name = '${updatedEmployeeData['Name']}', "
        "dob = '${updatedEmployeeData['DOB']}', "
        "department = '${updatedEmployeeData['Department']}', "
        "gender = '${updatedEmployeeData['Gender']}', "
        "mobileNumber = '${updatedEmployeeData['MobileNumber']}',"
        "username = '${updatedEmployeeData['Username']}',"
        "password = '${updatedEmployeeData['Password']}'"
        "WHERE EmployeeID = $employeeID",
      );

      if (queryResult) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }

  void _updateEmployee() async {
    // Validate the form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.employeeData['Name'] = _nameController.text;
    widget.employeeData['DOB'] = _dobController.text;
    widget.employeeData['Department'] = _departmentController.text;
    widget.employeeData['Gender'] = _selectedGender;
    widget.employeeData['MobileNumber'] = _mobileNumberController.text;
    widget.employeeData['Username'] = _usernameController.text;
    widget.employeeData['Password'] = _passwordController.text;

    bool success = await updateEmployeeInDataSource(widget.employeeData);

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
    final int employeeID = widget.employeeData['EmployeeID'] ?? '';

    bool success = await deleteRecordFromDataSource(employeeID);

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

  Future<bool> deleteRecordFromDataSource(int employeeID) async {
    final connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    await connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(
      'Delete From EmployeeMob where EmployeeID = $employeeID',
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
          "INSERT INTO EmployeeMob(name, dob, department, gender, mobileNumber, username, password)"
          "VALUES('${_nameController.text}', '${_dobController.text}', "
          "'${_departmentController.text}', '${_selectedGender}', "
          "'${_mobileNumberController.text}', '${_usernameController.text}', '${_passwordController.text}')",
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
          _usernameController.clear();
          _passwordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save employee data')),
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

class EmployeeListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Listing'),
      ),
      body: Center(
        child: Text('Employee Listing Screen Content'),
      ),
    );
  }
}
