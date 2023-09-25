import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'employee_listing_screen.dart';
import 'buyer_listing_screen.dart';
import './login.dart';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart';
import 'WebView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color myColor = Color.fromRGBO(26, 187, 156, 1.0);

    MaterialColor myMaterialColor = MaterialColor(
      myColor.value,
      <int, Color>{
        50: myColor.withOpacity(0.1),
        100: myColor.withOpacity(0.2),
        200: myColor.withOpacity(0.3),
        300: myColor.withOpacity(0.4),
        400: myColor.withOpacity(0.5),
        500: myColor.withOpacity(0.6),
        600: myColor.withOpacity(0.7),
        700: myColor.withOpacity(0.8),
        800: myColor.withOpacity(0.9),
        900: myColor.withOpacity(1.0),
      },
    );

    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: myMaterialColor,
      ),
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/employee': (context) => EmployeeListingScreen(),
        '/buyer': (context) => BuyerListingScreen(),
        '/login': (context) => CredentialEditScreen(),
        '/change_password': (context) => ChangePasswordScreen(),
        '/webview': (context) => MyWebViewScreen(), // Add this route
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/employee');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/buyer');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/webview');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final userData = await fetchUserData(username!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Username: ${userData['Username']}'),
              Text('Name: ${userData['Name']}'),
              Text('DOB: ${userData['DOB']}'),
              Text('Department: ${userData['Department']}'),
              Text('Gender: ${userData['Gender']}'),
              Text('Mobile Number: ${userData['MobileNumber']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  // Add this function to navigate to the Change Password screen
  void _changePassword() {
    Navigator.pushNamed(context, '/change_password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIT ONE BOX'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int result) {
              if (result == 0) {
                _logout();
              } else if (result == 1) {
                _changePassword(); // Add the change password option
              } else if (result == 2) {
                Navigator.pushNamed(context, '/login');
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('User Info'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Change Password'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _currentIndex == 0
          ? HomeContent()
          : _currentIndex == 1
              ? EmployeeListingScreen()
              : BuyerListingScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Employee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Buyer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'WebView',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "WHY FIT ONE BOX ?",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            "At FOB, our developers and researchers passionately believe that offering business solutions to our clients is not merely a project but an art of mastering their trade and delivering solutions that provide value and growth to our clients.",
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 16.0),
          Text(
            "Our never-ending quality management process constantly increases the operational efficiency. With innovative Techniques and accomplished professionals and in-depth knowledge of the field makes us totally stand out from our competition.",
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 16.0),
          Text(
            "We do this by working across disciplines to manifest a world-class business software by introducing the best practices of the industry.",
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 16.0),
          Text(
            "FOB is a very friendly and predictive tool that is easy to learn and efficient to use and is structured with high standards in terms of the product's functionality, reliability, and performance.",
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Old Password is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'New Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final prefs = await SharedPreferences.getInstance();
                    final username = prefs.getString('username');
                    final oldPassword = _oldPasswordController.text;
                    final newPassword = _newPasswordController.text;

                    // Check if the old password matches the stored password
                    final userData = await fetchUserData(username!);
                    if (userData['Password'] != oldPassword) {
                      // Old password doesn't match
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Old Password is incorrect.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Update the password in the database
                      await updatePassword(username, newPassword);

                      // Password updated successfully
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Success'),
                            content: Text('Password updated successfully.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .pop(); // Close the Change Password screen
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updatePassword(String username, String newPassword) async {
    final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    await _connectToSqlServerDirectlyPlugin.initializeConnection(
      '192.168.1.3',
      'Traininng',
      'sa',
      'JPLjeevan123',
      instance: 'sqlerp',
    );

    // Update the password in the database
    final updateQuery =
        "UPDATE EmployeeMob SET Password = '$newPassword' WHERE Username = '$username'";
    await _connectToSqlServerDirectlyPlugin.getStatusOfQueryResult(updateQuery);
  }
}

Future<Map<String, dynamic>> fetchUserData(String username) async {
  final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
  await _connectToSqlServerDirectlyPlugin.initializeConnection(
      '192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
      instance: 'sqlerp');
  final results = await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult(
    "SELECT * FROM EmployeeMob WHERE Username = '$username'",
  );

  if (results.isNotEmpty) {
    final userData = results.first;
    return userData;
  } else {
    return {};
  }
}
