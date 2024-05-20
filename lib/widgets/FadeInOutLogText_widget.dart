import 'package:flutter/material.dart';
import 'package:general_mod_manager/utils/variables.dart';
import 'package:provider/provider.dart';
import '../services/log_provider.dart';

class FadeInFadeOutText extends StatefulWidget {
  @override
  _FadeInFadeOutTextState createState() => _FadeInFadeOutTextState();
}

class _FadeInFadeOutTextState extends State<FadeInFadeOutText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _translateAnimation;
  String _latestLog = '';
  LogProvider logProvider = LogProvider();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _latestLog = '';
          });
        }
      });

    _translateAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -2))
        .animate(_controller);

    logProvider = Provider.of<LogProvider>(context, listen: false);
    logProvider.addListener(_updateLog);
  }

  @override
  void dispose() {
    // Remove the listener before disposing the controller

    logProvider.removeListener(_updateLog);
    _controller.dispose();
    super.dispose();
  }

  void _updateLog() {
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    setState(() {
      _latestLog = logProvider.logs.last;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return _latestLog.isNotEmpty
        ? FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(20))),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                _latestLog,
                style: style3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
