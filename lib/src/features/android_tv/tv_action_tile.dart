import 'package:flutter/material.dart';

/// A remote-friendly focused action tile with high contrast and visible focus.
class TvActionTile extends StatefulWidget {
  final String label;
  final String? description;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;
  const TvActionTile({super.key, required this.label, required this.icon,
    required this.onPressed, this.description, this.selected = false});
  @override
  State<TvActionTile> createState() => _TvActionTileState();
}
class _TvActionTileState extends State<TvActionTile> {
  bool focused = false;
  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    onShowFocusHighlight: (value) => setState(() => focused = value),
    child: AnimatedScale(
      scale: focused ? 1.035 : 1,
      duration: const Duration(milliseconds: 110),
      child: Material(
        color: focused ? const Color(0xFF2468A4) :
          widget.selected ? const Color(0xFF173E60) : const Color(0xFF17283B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: focused ? Colors.white : Colors.white24,
            width: focused ? 3 : 1)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [
            Icon(widget.icon, size: 29, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w700)),
              if (widget.description != null) Text(widget.description!,
                maxLines: 2,overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15,color: Colors.white70)),
            ])),
          ])),
        ),
      ),
    ),
  );
}
