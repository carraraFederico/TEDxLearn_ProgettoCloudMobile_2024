import 'package:flutter/material.dart';
import 'package:tedxlearn/styles/stile.dart';

class BottomBar extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onLeaderboardPressed;
  final VoidCallback onAccountPressed;

  const BottomBar({
    super.key,
    required this.onHomePressed,
    required this.onLeaderboardPressed,
    required this.onAccountPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bottomBarColor,
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, size: DimApp.dimIcon),
              onPressed: onHomePressed,
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard, size: DimApp.dimIcon),
              onPressed: onLeaderboardPressed,
            ),
            IconButton(
              icon: const Icon(Icons.account_circle, size: DimApp.dimIcon),
              onPressed: onAccountPressed,
            ),
          ],
        ),
      ),
    );
  }
}
