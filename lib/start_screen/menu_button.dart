import 'package:geo_quiz/shared/common.dart';

class MenuButton extends StatelessWidget {
  final Routes route;
  final IconData iconData;
  final String label;

  const MenuButton({
    super.key,
    required this.route,
    required this.iconData,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ElevatedButton(
          onPressed: () => route.push(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(iconData),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}