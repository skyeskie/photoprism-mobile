import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:photoprism/pages/settings_page.dart';
import 'package:provider/provider.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({Key key, this.context}) : super(key: key);
  final BuildContext context;

  @override
  _AuthDialogState createState() => _AuthDialogState(context);
}

class _AuthDialogState extends State<AuthDialog> {
  _AuthDialogState(BuildContext context) {
    model = Provider.of<PhotoprismModel>(context);
    _httpBasicUserController = TextEditingController();
    _httpBasicPasswordController = TextEditingController();
    httpBasicEnabled = model.photoprismAuth.httpBasicEnabled;
    _passwordController = TextEditingController();
    enabled = model.photoprismAuth.enabled;
  }

  PhotoprismModel model;
  TextEditingController _httpBasicUserController;
  TextEditingController _httpBasicPasswordController;
  bool httpBasicEnabled;
  TextEditingController _passwordController;
  bool enabled;

  @override
  Widget build(BuildContext context) {
    Future<void> saveAndPop() async {
      model.photoprismAuth.setHttpBasicEnabled(httpBasicEnabled);
      model.photoprismAuth.setHttpBasicUser(_httpBasicUserController.text);
      model.photoprismAuth
          .setHttpBasicPassword(_httpBasicPasswordController.text);
      model.photoprismAuth.setEnabled(enabled);
      model.photoprismAuth.setPassword(_passwordController.text);
      model.photoprismRemoteConfigLoader.loadApplicationColor();
      await SettingsPage.emptyCache(context);
      Navigator.of(context).pop();
    }

    _httpBasicUserController.text = model.photoprismAuth.httpBasicUser;
    _httpBasicPasswordController.text = model.photoprismAuth.httpBasicPassword;
    _passwordController.text = model.photoprismAuth.password;

    return AlertDialog(
      title: const Text('Authentication').tr(),
      content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          SwitchListTile(
            title: const Text('PhotoPrism'),
            onChanged: (bool value) {
              setState(() {
                enabled = value;
              });
            },
            value: enabled,
          ),
          Visibility(
              visible: enabled,
              child: ListTile(
                  subtitle: const Text('Password').tr(),
                  title: TextField(
                    key: const ValueKey<String>('password'),
                    controller: _passwordController,
                    decoration: const InputDecoration(hintText: 'password'),
                    obscureText: true,
                  ))),
          SwitchListTile(
            title: const Text('HTTP Basic').tr(),
            onChanged: (bool value) {
              setState(() {
                httpBasicEnabled = value;
              });
            },
            value: httpBasicEnabled,
          ),
          Visibility(
              visible: httpBasicEnabled,
              child: ListTile(
                  subtitle: const Text('HTTP basic user').tr(),
                  title: TextField(
                    key: const ValueKey<String>('httpBasicUserTextField'),
                    controller: _httpBasicUserController,
                    decoration: const InputDecoration(hintText: 'user'),
                  ))),
          Visibility(
              visible: httpBasicEnabled,
              child: ListTile(
                  subtitle: const Text('HTTP basic password').tr(),
                  title: TextField(
                    key: const ValueKey<String>('httpBasicPasswordTextField'),
                    controller: _httpBasicPasswordController,
                    decoration: const InputDecoration(hintText: 'password'),
                    obscureText: true,
                  ))),
        ],
      )),
      actions: <Widget>[
        FlatButton(
          child: const Text('Cancel').tr(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: const Text('Save').tr(),
          onPressed: () => saveAndPop(),
        )
      ],
    );
  }
}
