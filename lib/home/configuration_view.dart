import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'reg_exp_text_field.dart';

class ConfigurationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  bool _originLocationSelection = false;

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: Text("Bike Route Generator"),
          ),
          body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOriginOptionSelector(),
                    _buildCustomLocationInput(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          //TODO: add API call trigger
                        },
                        child: Text("Generate!"),
                      ),
                    ),
                  ],
                )),
          ));

  Widget _buildOriginOptionSelector() =>
      Column(
        children: [
          Text("Select route origin:"),
          RadioListTile<bool>(
            value: false,
            groupValue: _originLocationSelection,
            title: Text("Current Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? false;
              });
            },
          ),
          RadioListTile<bool>(
            value: true,
            groupValue: _originLocationSelection,
            title: Text("Custom Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? false;
              });
            },
          ),
        ],
      );

  Widget _buildCustomLocationInput() =>
      Column(
        children: [
          RegExpTextField(
            RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Latitude',
            enabled: _originLocationSelection,
          ),
          RegExpTextField(
            RegExp(r'^\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Longitude',
            enabled: _originLocationSelection,
          ),
        ],
      );
}
