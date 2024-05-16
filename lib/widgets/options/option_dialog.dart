import 'package:flutter/material.dart';
import 'package:general_mod_manager/utils/variables.dart';

class OptionDialog {
  updateDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: backgroundColor,
          child: Container(
            width: 400,
            height: 200,
            child: Center(
              child:
                  // Show loading animation if dialogLoading is true
                  Text(
                "You are all up to date! ^__^",
                style: style2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  loadingData(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: backgroundColor,
          child: Container(
            width: 400,
            height: 400,
            child: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
