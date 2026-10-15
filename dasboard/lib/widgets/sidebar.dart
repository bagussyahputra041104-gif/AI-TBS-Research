import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const Color darkGreen = Color(0xFF0E3827);

  static const List<SidebarItem> items = [
    SidebarItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    SidebarItem(
      label: 'Analyze',
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt_rounded,
    ),
    SidebarItem(
      label: 'History',
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
    ),
    SidebarItem(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
    ),
    SidebarItem(
      label: 'Reports',
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
    ),
    SidebarItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
    ),
    SidebarItem(
      label: 'About',
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(color: darkGreen),
      child: Column(
        children: [
          _buildBrand(),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _SidebarMenuItem(
                  item: items[index],
                  selected: selectedIndex == index,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
          _buildBottomStatus(),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 27, 18, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'PalmVision',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatus() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF55D98A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Engine Ready',
                  style: TextStyle(
                    color: Color(0xFFE4F4E9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              'Small U-Net • TBS Segmentation',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.52),
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI TBS Research',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarMenuItem extends StatefulWidget {
  final SidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    final backgroundColor = selected
        ? Colors.white.withValues(alpha: 0.105)
        : hovering
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.transparent;

    final iconColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.76);

    final textColor = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.76);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            hovering = true;
          });
        },
        onExit: (_) {
          setState(() {
            hovering = false;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 3,
                  height: selected ? 27 : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF65D894),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: selected ? 9 : 12),
                Icon(
                  selected ? widget.item.activeIcon : widget.item.icon,
                  color: iconColor,
                  size: 21,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF65D894),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
