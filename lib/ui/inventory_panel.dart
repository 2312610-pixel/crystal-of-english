import 'package:flutter/material.dart';
import '../state/inventory.dart';

class InventoryPanel extends StatelessWidget {
  final VoidCallback onClose;
  final int totalSlots;
  final int columns;

  const InventoryPanel({
    super.key,
    required this.onClose,
    this.totalSlots = 24,
    this.columns = 6,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spacing = 8.0;
    final gridPadding = 12.0;
    final panelWidth = size.width * 0.4;
    final gridWidth = panelWidth - gridPadding * 2;
    final cellSize = ((gridWidth - (columns - 1) * spacing) / columns)
        .floorToDouble();
    final rows = (totalSlots + columns - 1) ~/ columns; // expect 4
    final gridHeight = (rows * cellSize + (rows - 1) * spacing).floorToDouble();
    final headerApprox = 48.0 + 12.0 + 1.0;
    final panelHeight = (gridHeight + gridPadding * 2 + headerApprox)
        .floorToDouble()
        .clamp(0.0, (size.height * 0.9).floorToDouble());

    // Use Stack to layer slots over the backpack image
    // Use Stack to layer slots over the new backpack image (backPack.png)
    // 6x4 grid, 24 slots, matching the new image
    // Make slot boxes smaller and keep them aligned with the image grid
    return Center(
      child: SizedBox(
        width: 700,
        height: 560,
        child: Stack(
          children: [
            // Backpack background
            Positioned.fill(
              child: Image.asset('images/backPack.png', fit: BoxFit.contain),
            ),
            // Close button and title
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18, color: Colors.brown),
                  const SizedBox(width: 6),
                  const Text(
                    'Hành trang',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const Spacer(),
                  // Close button (top right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onClose,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                          'images/X_Button.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Slots grid overlay (manual grid for pixel-perfect fit, smaller slots)
            Positioned(
              top: 105,
              left: 122,
              child: SizedBox(
                width: 650, // 6*60 + 5*8 spacing
                height: 300, // 4*36 + 3*8 spacing
                child: AnimatedBuilder(
                  animation: Inventory.instance,
                  builder: (context, _) {
                    final items = Inventory.instance.items;
                    List<Widget> slotWidgets = [];
                    const slotSize = 64.0;
                    const slotSpacing = 14.0;
                    for (int row = 0; row < 4; row++) {
                      for (int col = 0; col < 6; col++) {
                        int index = row * 6 + col;
                        final item = index < items.length ? items[index] : null;
                        slotWidgets.add(
                          Positioned(
                            left: col * (slotSize + slotSpacing),
                            top: row * (slotSize + slotSpacing),
                            child: Container(
                              width: slotSize,
                              height: slotSize,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.brown.shade700,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: item == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          item.icon,
                                          size: 22,
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      }
                    }
                    return Stack(children: slotWidgets);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
