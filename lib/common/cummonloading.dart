import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  final int durationInSeconds;

  LoadingDialog({required this.durationInSeconds});

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    // Set a timer to close the dialog after the specified duration
    Future.delayed(Duration(seconds: widget.durationInSeconds), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}