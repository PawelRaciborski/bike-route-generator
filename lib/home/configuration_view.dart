import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfigurationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfigurationViewState();
}

class _ConfigurationViewState extends State<ConfigurationView> {
  int _originLocationSelection = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Bike Route Generator"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              _buildOriginOptionSelector(),
              _buildCustomLocationInput(),
            ],
          )));

  Widget _buildOriginOptionSelector() => Column(
        children: [
          Text("Select route origin:"),
          RadioListTile<int>(
            value: 0,
            groupValue: _originLocationSelection,
            title: Text("Current Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? 0;
              });
            },
          ),
          RadioListTile<int>(
            value: 1,
            groupValue: _originLocationSelection,
            title: Text("Custom Location"),
            onChanged: (value) {
              setState(() {
                _originLocationSelection = value ?? 0;
              });
            },
          ),
        ],
      );

  Widget _buildCustomLocationInput() => Column(
        children: [
          RegExpTextField(
            RegExp(r'^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Latitude',
          ),
          RegExpTextField(
            RegExp(r'^\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'),
            keyboardType: TextInputType.number,
            labelText: 'Longitude',
          ),
        ],
      );
}

class RegExpTextField extends StatefulWidget {
  final RegExp regExp;
  final String? labelText;
  final TextInputType? keyboardType;

  const RegExpTextField(this.regExp,
      {this.labelText, this.keyboardType, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => RegExpTextFieldState();
}

class RegExpTextFieldState extends State<RegExpTextField> {
  final _textController = TextEditingController();
  var _isValid = true;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isValid = _validateInput();
      });
    });
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _textController,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: widget.labelText,
            errorText: _isValid ? null : "Wrong input!"),
      );

  bool _validateInput() => widget.regExp.hasMatch(_textController.text);
}
