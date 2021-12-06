import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OnTextFieldCallback = void Function(String text);

/// `onEditingComplete`で文字列を受け取れるように拡張したTextField
class TextFieldEx extends StatefulWidget {
  const TextFieldEx({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.textAlign,
    this.initText = '',
    this.onChanged,
    this.onEditingComplete,
  }) : super(key: key);

  final String labelText;
  final String hintText;
  final TextAlign textAlign;
  final String initText;
  final OnTextFieldCallback? onChanged;
  final OnTextFieldCallback? onEditingComplete;

  @override
  _TextFieldExState createState() => _TextFieldExState();
}

class _TextFieldExState extends State<TextFieldEx> {
  String _inputText = '';
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    _textEditingController.text = widget.initText;
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: true,
      controller: _textEditingController,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      onChanged: (text) {
        widget.onChanged?.call(text);
        _inputText = text;
      },
      onEditingComplete: () {
        widget.onEditingComplete?.call(_inputText);
      },
      onSubmitted: (String value) {
        // キーボードを閉じる
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
      ),
      textAlign: widget.textAlign,
    );
  }
}
