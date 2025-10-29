import 'package:flutter/material.dart';
import '../state/inventory.dart';

class ShopOverlay extends StatefulWidget {
  static const id = 'ShopOverlay';

  final VoidCallback onClose;
  final int capacity;
  const ShopOverlay({super.key, required this.onClose, this.capacity = 20});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  late List<GameItem> npcItems;

  @override
  void initState() {
    super.initState();
    npcItems = <GameItem>[
      const GameItem('Potion', Icons.local_drink),
      const GameItem('Elixir', Icons.science),
      const GameItem('Sword', Icons.gavel),
      const GameItem('Shield', Icons.shield),
      const GameItem('Scroll', Icons.menu_book),
      const GameItem('Boots', Icons.directions_walk),
    ];
  }

  Future<void> _buy(GameItem item) async {
    if (Inventory.instance.items.length >= widget.capacity) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => const AlertDialog(content: Text('Hành trang đã đầy')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mua ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mua'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final added = Inventory.instance.add(item);
      if (added) {
        setState(() {
          npcItems.remove(item);
        });
      }
    }
  }

  Widget _grid(List<dynamic> items, {bool clickable = false}) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final GameItem? item = index < items.length
            ? items[index] as GameItem
            : null;
        final tile = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
          ),
          child: item == null
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 40,
                      color: Colors.black87,
                    ), // Increased icon size
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        );
        if (clickable && item != null) {
          return InkWell(onTap: () => _buy(item), child: tile);
        }
        return tile;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Book image size: 946x582, each page has 5x4 squares
    // We'll overlay 10 columns x 4 rows (total 40 slots)
    // Slot positions are manually calculated to fit the squares
    final double bookWidth = 800;
    final double bookHeight = 582;
    final double slotSize = 39; // smaller slot size
    final double slotSpacingX = 18; // smaller horizontal gap
    final double slotSpacingY = 16.5; // smaller vertical gap
    final double leftStartX = 155; // left page first slot x
    final double rightStartX = 430; // right page first slot x
    final double startY = 90; // move grid slots higher

    // Prepare all slot positions (left and right page)
    List<Offset> slotPositions = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        slotPositions.add(
          Offset(
            leftStartX + col * (slotSize + slotSpacingX),
            startY + row * (slotSize + slotSpacingY),
          ),
        );
      }
    }
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 4; col++) {
        slotPositions.add(
          Offset(
            rightStartX + col * (slotSize + slotSpacingX),
            startY + row * (slotSize + slotSpacingY),
          ),
        );
      }
    }

    return Center(
      child: SizedBox(
        width: bookWidth + 700, // reduce total width to shift everything left
        height: bookHeight,
        child: Row(
          children: [
            SizedBox(
              width: 450, // reduce Eleonore_Shop width to shift left
              height: bookHeight,
              child: Image.asset(
                'images/Eleonore_Shop.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              width: bookWidth,
              height: bookHeight,
              child: Stack(
                children: [
                  // Book background
                  Positioned.fill(
                    child: Image.asset(
                      'images/Book_Shop.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Close button (top right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: widget.onClose,
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
                  // Overlay slots
                  for (int i = 0; i < slotPositions.length; i++)
                    Positioned(
                      left: slotPositions[i].dx,
                      top: slotPositions[i].dy,
                      child: Builder(
                        builder: (context) {
                          final item = i < npcItems.length ? npcItems[i] : null;
                          return GestureDetector(
                            onTap: item != null ? () => _buy(item) : null,
                            child: Container(
                              width: slotSize,
                              height: slotSize,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.brown.shade700,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
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
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
