import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/services/user_service.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({Key? key}) : super(key: key);

  @override
  _UserRegisterPageState createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  GlobalKey<FormState> registerFormGlobalKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditController = TextEditingController();
  TextEditingController passwordTextEditController = TextEditingController();
  TextEditingController dataOfBirthEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final UsersService usersService = Provider.of<UsersService>(context);
    return Consumer<UsersService>(
      builder: (context, value, child) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              leading: BackButton(
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      width: constraints.maxWidth,
                      child: Column(
                        children: [
                          Form(
                            key: registerFormGlobalKey,
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                buildUserNameTextFormField(),
                                buildPasswordTextFormField(),
                                buildDateOfBirthTextFormField(context),
                                buildRegisterButton(usersService, context),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  ElevatedButton buildRegisterButton(
      UsersService usersService, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (registerFormGlobalKey.currentState!.validate()) {
          final isUserExist = await usersService.isExist(
              userNameTextEditController.text, passwordTextEditController.text);
          if (!isUserExist) {
            usersService.insert(
              'users',
              {
                "name": userNameTextEditController.text,
                "password": passwordTextEditController.text,
                "dateOfBirth": dataOfBirthEditController.text
              },
            ).then((value) {
              if (value) {
                Navigator.of(context).pop();
                final snackBar =
                    SnackBar(content: Text('Registered Successfully'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            });
          } else {
            final snackBar = SnackBar(content: Text('User already exist'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      },
      child: Center(
        child: Text('Register'),
      ),
    );
  }

  TextFormField buildDateOfBirthTextFormField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          hintText: 'DataOfBirth',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: EdgeInsets.all(6.0)),
      readOnly: true,
      keyboardType: TextInputType.datetime,
      controller: dataOfBirthEditController,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter password';
        }

        return null;
      },
      onTap: () {
        showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.parse("1990-01-01"),
                lastDate: DateTime.now())
            .then((DateTime? value) {
          if (value != null) {
            dataOfBirthEditController.text =
                DateFormat('MM/dd/yyyy').format(value);
          }
        });
      },
    );
  }

  TextFormField buildPasswordTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: EdgeInsets.all(6.0)),
      controller: passwordTextEditController,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter password';
        }

        RegExp textExp = new RegExp(r'^(?=.*?[A-Z])\w+');
        RegExp numericExp = new RegExp(r'^(?=.*?[0-9])\w+');
        RegExp specialExp = new RegExp(r'^(?=.*?[!@#\$&*~])\w+');
        String passwordRegExp =
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
        RegExp regExp = new RegExp(passwordRegExp);
        if (!regExp.hasMatch(value)) {
          if (!textExp.hasMatch(value)) {
            return 'Password must contain any one upperCase';
          }

          if (!numericExp.hasMatch(value)) {
            return 'Password must contain any one numeric';
          }

          if (!specialExp.hasMatch(value)) {
            return 'Password must contain any one special';
          }

          if (value.length < 8) {
            return 'Password must contain more than 8 characters';
          }
        } else {
          return null;
        }

        return null;
      },
    );
  }

  TextFormField buildUserNameTextFormField() {
    return TextFormField(
      decoration: InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: EdgeInsets.all(6.0)),
      controller: userNameTextEditController,
      keyboardType: TextInputType.text,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))],
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter name';
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    userNameTextEditController.dispose();
    passwordTextEditController.dispose();
    dataOfBirthEditController.dispose();
  }
}
