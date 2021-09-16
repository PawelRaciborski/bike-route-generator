
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
