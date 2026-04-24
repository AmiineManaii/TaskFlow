import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 36,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ??
        (user != null
            ? _colorFromName(user!.name)
            : Colors.grey);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      backgroundImage: user?.avatarUrl != null
          ? NetworkImage(user!.avatarUrl!)
          : null,
      child: user?.avatarUrl == null
          ? Text(
              user?.initials ?? '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }

  Color _colorFromName(String name) {
    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFFDB2777),
      const Color(0xFFDC2626),
      const Color(0xFFEA580C),
      const Color(0xFF16A34A),
      const Color(0xFF0891B2),
    ];
    final index = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }
}
