import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/biometric_auth_provider.dart';
import 'package:shopping_app/services/user_service.dart';
import 'package:shopping_app/view/user_register_page.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.canShowAuthenticateMessage})
      : super(key: key);

  final bool canShowAuthenticateMessage;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> loginFormGlobalKey = GlobalKey<FormState>();
  final TextEditingController userNameTextEditController =
      TextEditingController();
  final TextEditingController passwordTextEditController =
      TextEditingController();
  bool isInValidUserNameOrPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.canShowAuthenticateMessage) {
      LocalAuthProvider.authenticate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersService>(
      builder: (BuildContext context, UsersService usersService, _) {
        return SafeArea(
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      buildForm(),
                      Column(
                        children: [
                          buildSignInWidget(usersService, context),
                          Center(
                            child: SizedBox(
                              width: 150,
                              child: TextButton(
                                onPressed: () async {
                                  await LocalAuthProvider.authenticate();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(Icons.fingerprint),
                                    Text(
                                      'FingerPrint',
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          buildSignUpOption(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Center buildSignUpOption(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: Row(
          children: [
            Text("Don't have an account?"),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserRegisterPage(),
                  ));
                },
                child: Text('Sign Up'))
          ],
        ),
      ),
    );
  }

  Widget buildSignInWidget(UsersService usersService, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (loginFormGlobalKey.currentState!.validate()) {
          final isUserExist = await usersService.isExist(
              userNameTextEditController.text, passwordTextEditController.text);
          if (isUserExist) {
            List<Map<String, dynamic>> user = await usersService.get(
                id: null,
                userName: userNameTextEditController.text,
                password: passwordTextEditController.text);

            /// loading the user details
            loadingUserDetailsInJson(usersService, user, context);
          } else {
            setState(() {
              isInValidUserNameOrPassword = true;
            });
          }
        }
      },
      child: Center(
        child: Text('Sign In'),
      ),
    );
  }

  void loadingUserDetailsInJson(UsersService usersService,
      List<Map<String, dynamic>> user, BuildContext context) {
    /// loading the user details
    usersService.writeIntoJson(
      {
        "id": user[0]["id"],
        "userName": user[0]["name"],
        "password": user[0]["password"],
        "dateOfBirth": user[0]["dateOfBirth"],
      },
    ).then((value) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ShoppingAppHomePage(),
      ));
    });
  }

  Form buildForm() {
    return Form(
      key: loginFormGlobalKey,
      child: Column(
        children: [
          Center(
            child: Text(
              'Login',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Visibility(
            visible: isInValidUserNameOrPassword,
            child: Text(
              'Invalid UserName or Password',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter UserName',
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            controller: userNameTextEditController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }

              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter Password',
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            controller: passwordTextEditController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    userNameTextEditController.dispose();
    passwordTextEditController.dispose();
  }
}
