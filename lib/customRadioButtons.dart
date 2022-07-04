import 'package:flutter/material.dart';

import 'materialColor.dart';

class MyRadioListTile<T> extends StatelessWidget {
  final String value;
  final String groupValue;
  final Widget leading;
  final Widget title;
  final ValueChanged onChanged;

  const MyRadioListTile({
    @required this.value,
    @required this.groupValue,
    @required this.onChanged,
    @required this.leading,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        height: 56,
        child: Row(
          children: [
            _customRadioButton,
            SizedBox(width: 12),
            if (title != null) title,
          ],
        ),
      ),
    );
  }

  Widget get _customRadioButton {
    final isSelected = value == groupValue;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color:
          isSelected ? materialColor(RosePink.primary) : Colors.grey[300],
          width: 2,
        ),
      ),
      child: Center(child: leading),
    );
  }
}
