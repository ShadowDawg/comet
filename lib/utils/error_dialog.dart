import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDialog({Key? key, required this.message, this.onRetry})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        if (onRetry != null)
          TextButton(
            child: Text('Retry'),
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
          ),
      ],
    );
  }
}

// Usage example:
void showErrorDialog(BuildContext context, String message,
    {VoidCallback? onRetry}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(message: message, onRetry: onRetry);
    },
  );
}
