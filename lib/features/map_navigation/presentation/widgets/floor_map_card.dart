import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/map_floor_data.dart';
import '../../domain/map_models.dart';

class FloorMapCard extends StatelessWidget {
  const FloorMapCard({
    super.key,
    required this.plan,
    this.startId,
    this.endId,
    this.showRoute = false,
    this.subtitle,
    this.showStartMarker = true,
    this.showStartIcon = true,
  });

  final FloorPlan plan;
  final String? startId;
  final String? endId;
  final bool showRoute;
  final String? subtitle;
  final bool showStartMarker;
  final bool showStartIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        children: [
          SizedBox(
            height: 188,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final chipSizes = {
                  for (final n in plan.nodes)
                    n.id: _measureChipSize(
                      node: n,
                      isStart: n.id == startId,
                      isEnd: n.id == endId,
                      context: context,
                    ),
                };
                if (plan.level == 2 && chipSizes.containsKey('f2_rooms')) {
                  final current = chipSizes['f2_rooms']!;
                  final stretchedWidth = (size.width - 16).clamp(
                    current.width,
                    size.width,
                  );
                  chipSizes['f2_rooms'] = _ChipSize(
                    width: stretchedWidth,
                    height: current.height,
                    fontSize: current.fontSize,
                  );
                }
                final layoutData = _computeLayout(plan, size, chipSizes);
                final positions = layoutData.positions;
                final routePoints =
                    showRoute && startId != null && endId != null
                    ? _buildRoutePoints(
                        plan: plan,
                        startId: startId!,
                        endId: endId!,
                        positions: positions,
                        layout: layoutData,
                        sizes: chipSizes,
                      )
                    : <Offset>[];

                final nodesById = {for (final n in plan.nodes) n.id: n};

                return Stack(
                  children: [
                    CustomPaint(
                      size: size,
                      painter: _ConnectionsPainter(
                        plan: plan,
                        positions: positions,
                        sizes: chipSizes,
                        layout: layoutData,
                      ),
                    ),
                    if (routePoints.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _RoutePainter(points: routePoints),
                          ),
                        ),
                      ),
                    ...plan.nodes.map((node) {
                      final pos = positions[node.id]!;
                      final sizeInfo = chipSizes[node.id]!;
                      return Positioned(
                        left: pos.dx - sizeInfo.width / 2,
                        top: pos.dy - sizeInfo.height / 2,
                        child: SizedBox(
                          width: sizeInfo.width,
                          height: sizeInfo.height,
                          child: _PlaceChip(
                            node: nodesById[node.id]!,
                            isStart: node.id == startId && showStartMarker,
                            isEnd: node.id == endId,
                            fontSize: sizeInfo.fontSize,
                            isElevator: node.id == plan.elevatorId,
                            showStartIcon: showStartIcon,
                            forceRedBorder:
                                showRoute && node.id == plan.elevatorId,
                          ),
                        ),
                      );
                    }),
                    if (routePoints.isNotEmpty)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _RouteArrowHeadPainter(
                              points: routePoints,
                            ),
                          ),
                        ),
                      ),
                    if (subtitle != null && positions[plan.elevatorId] != null)
                      Positioned(
                        top:
                            positions[plan.elevatorId]!.dy +
                            (chipSizes[plan.elevatorId]?.height ?? 0) / 2 +
                            2,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({
    required this.node,
    required this.isStart,
    required this.isEnd,
    required this.fontSize,
    required this.isElevator,
    required this.showStartIcon,
    required this.forceRedBorder,
  });

  final MapNode node;
  final bool isStart;
  final bool isEnd;
  final double fontSize;
  final bool isElevator;
  final bool showStartIcon;
  final bool forceRedBorder;

  @override
  Widget build(BuildContext context) {
    final isGuestRooms = node.id == 'f2_rooms';
    final bg = Colors.white;
    final border = (isStart || isEnd || forceRedBorder)
        ? Colors.red.shade300
        : Colors.grey.shade300;
    final textColor = isStart ? Colors.black87 : AppTheme.textPrimary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: isElevator ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isGuestRooms ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: isGuestRooms
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (!isGuestRooms) ...[
            SizedBox(width: 20, child: Image.asset(node.img)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                node.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ] else ...[
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.asset('assets/images/icons/door.png'),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(child: Image.asset('assets/images/icons/bed.png')),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                node.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize,
                ),
              ),
            ),
            const SizedBox(width: 6),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Image.asset('assets/images/icons/door.png'),
              ),
            ),
          ],
          if (isStart && showStartIcon) ...[
            const SizedBox(width: 4),
            const Icon(Icons.location_on_rounded, color: Colors.red, size: 16),
          ],
        ],
      ),
    );
  }
}

class _ConnectionsPainter extends CustomPainter {
  _ConnectionsPainter({
    required this.plan,
    required this.positions,
    required this.sizes,
    required this.layout,
  });

  final FloorPlan plan;
  final Map<String, Offset> positions;
  final Map<String, _ChipSize> sizes;
  final _LayoutData layout;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final c in plan.connections) {
      final pts = _edgePathById(c.from, c.to, positions, layout, sizes: sizes);
      if (pts.length < 2) continue;
      for (int i = 0; i < pts.length - 1; i++) {
        canvas.drawLine(pts[i], pts[i + 1], paint);
      }
    }

    if (plan.level == 2) {
      final topY = layout.topY;
      final leftX = layout.margin;
      final rightX = layout.width - layout.margin;
      canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), paint);

      final elevatorPos = positions[plan.elevatorId];
      if (elevatorPos != null) {
        canvas.drawLine(
          Offset(elevatorPos.dx, topY),
          Offset(elevatorPos.dx, elevatorPos.dy),
          paint,
        );
      }

      final exitPos = positions['f2_exit'];
      if (exitPos != null) {
        canvas.drawLine(
          Offset(exitPos.dx, topY),
          Offset(exitPos.dx, exitPos.dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p1 = points[points.length - 2];
    final p2 = points.last;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);

    Offset? arrowBase;
    final drawPoints = List<Offset>.from(points);

    if (len > 0) {
      final ux = dx / len;
      final uy = dy / len;
      const maxHeadLen = 1.0;
      final headLen = min(maxHeadLen, len * 0.8);
      arrowBase = Offset(p2.dx - ux * headLen, p2.dy - uy * headLen);
      drawPoints[drawPoints.length - 1] = arrowBase;
    }

    for (var i = 0; i < drawPoints.length - 1; i++) {
      canvas.drawLine(drawPoints[i], drawPoints[i + 1], linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      !listEquals(points, oldDelegate.points);
}

class _RouteArrowHeadPainter extends CustomPainter {
  _RouteArrowHeadPainter({required this.points});

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final p1 = points[points.length - 2];
    final p2 = points.last;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len <= 0) return;

    final ux = dx / len;
    final uy = dy / len;
    const maxHeadLen = 1.0;
    final headLen = min(maxHeadLen, len * 0.8);
    final base = Offset(p2.dx - ux * headLen, p2.dy - uy * headLen);

    _drawArrowHead(canvas, base, p2, Colors.red);
  }

  @override
  bool shouldRepaint(covariant _RouteArrowHeadPainter oldDelegate) =>
      !listEquals(points, oldDelegate.points);
}

void _drawArrowHead(Canvas canvas, Offset base, Offset tip, Color color) {
  const arrowSize = 10.0;
  final angle = atan2(tip.dy - base.dy, tip.dx - base.dx);
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(
      base.dx - arrowSize * cos(angle - pi / 6),
      base.dy - arrowSize * sin(angle - pi / 6),
    )
    ..lineTo(
      base.dx - arrowSize * cos(angle + pi / 6),
      base.dy - arrowSize * sin(angle + pi / 6),
    )
    ..close();
  canvas.drawPath(path, paint);
}

double _measureText(String text, double fontSize, BuildContext context) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return painter.size.width;
}

class _ChipSize {
  _ChipSize({
    required this.width,
    required this.height,
    required this.fontSize,
  });
  final double width;
  final double height;
  final double fontSize;
}

_ChipSize _measureChipSize({
  required MapNode node,
  required bool isStart,
  required bool isEnd,
  required BuildContext context,
}) {
  const minWidth = 90.0;
  const maxWidth = 400.0;
  const maxWide = 520.0;
  final height = node.id.contains('elevator') ? 52.0 : 36.0;
  double fontSize = 12;
  double measured = _measureText(node.label, fontSize, context);

  const padding = 6.0 * 2;
  const leadingIcon = 16.0;
  const gapAfterIcon = 5.0;
  const startExtras = 4.0 + 16.0;
  double width = padding + leadingIcon + gapAfterIcon + measured;
  if (isStart || isEnd) {
    width += startExtras;
  }
  final isBottom = node.position.dy >= 0.5 && !node.id.contains('elevator');
  if (!isBottom) {
    final limit = node.label.contains('Guest Rooms zone') ? maxWide : maxWidth;
    width = width.clamp(minWidth, limit);
  } else {
    width = max(width + 20, minWidth);
  }
  return _ChipSize(width: width, height: height, fontSize: fontSize);
}

class _LayoutData {
  _LayoutData({
    required this.positions,
    required this.topY,
    required this.midY,
    required this.bottomY,
    required this.width,
    required this.height,
    required this.margin,
    required this.level,
    required this.topXs,
    required this.hasBottomRow,
  });
  final Map<String, Offset> positions;
  final double topY;
  final double midY;
  final double bottomY;
  final double width;
  final double height;
  final double margin;
  final int level;

  final List<double> topXs;
  final bool hasBottomRow;
}

_LayoutData _computeLayout(
  FloorPlan plan,
  Size size,
  Map<String, _ChipSize> chipSizes,
) {
  const margin = 8.0;
  final width = size.width;
  final height = size.height;
  final top = <MapNode>[];
  final bottom = <MapNode>[];
  MapNode? exitNode;

  for (final n in plan.nodes) {
    if (n.id == plan.elevatorId) continue;
    if (n.label.toLowerCase().contains('emergency')) {
      exitNode = n;
      continue;
    }
    if (n.position.dy < 0.5) {
      top.add(n);
    } else {
      bottom.add(n);
    }
  }
  top.sort((a, b) => a.position.dx.compareTo(b.position.dx));
  bottom.sort((a, b) => a.position.dx.compareTo(b.position.dx));

  final topY = height * 0.2;
  final midY = height * 0.52;
  final bottomY = height * 0.84;

  final positions = <String, Offset>{};

  void layoutRow(
    List<MapNode> nodes,
    double y, {
    bool alignLeftForSingle = false,
  }) {
    if (nodes.isEmpty) return;
    final totalWidth = nodes.fold<double>(
      0,
      (sum, n) => sum + chipSizes[n.id]!.width,
    );
    final gaps = nodes.length == 1
        ? 0.0
        : (width - 2 * margin - totalWidth) / (nodes.length - 1);
    if (nodes.length == 1) {
      final n = nodes.first;
      final w = chipSizes[n.id]!.width;
      positions[n.id] = Offset(
        alignLeftForSingle ? margin + w / 2 : width / 2,
        y,
      );
    } else {
      double cursor = margin;
      for (final n in nodes) {
        final w = chipSizes[n.id]!.width;
        positions[n.id] = Offset(cursor + w / 2, y);
        cursor += w + gaps;
      }
    }
  }

  layoutRow(top, topY);
  layoutRow(bottom, bottomY, alignLeftForSingle: plan.level <= 0);
  if (plan.level == 2 && positions.containsKey('f2_rooms')) {
    positions['f2_rooms'] = Offset(width / 2, topY);
  }
  if (exitNode != null) {
    final exitSize = chipSizes[exitNode.id]!;
    final exitX = width - margin - exitSize.width / 2;
    positions[exitNode.id] = Offset(exitX, bottomY);
  }
  positions[plan.elevatorId] = Offset(width / 2, midY);

  final hasBottomRow = bottom.isNotEmpty || exitNode != null;

  return _LayoutData(
    positions: positions,
    topY: topY,
    midY: midY,
    bottomY: bottomY,
    width: width,
    height: height,
    margin: margin,
    level: plan.level,
    topXs: top.map((n) => positions[n.id]!.dx).toList(),
    hasBottomRow: hasBottomRow,
  );
}

List<String> _shortestPathNodes(FloorPlan plan, String startId, String endId) {
  if (startId == endId) return [startId];
  final graph = <String, List<String>>{};
  void addEdge(String a, String b) {
    graph.putIfAbsent(a, () => []).add(b);
    graph.putIfAbsent(b, () => []).add(a);
  }

  for (final c in plan.connections) {
    addEdge(c.from, c.to);
  }

  final queue = <String>[startId];
  final visited = <String>{startId};
  final prev = <String, String>{};

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    if (current == endId) break;
    for (final next in graph[current] ?? const []) {
      if (visited.add(next)) {
        prev[next] = current;
        queue.add(next);
      }
    }
  }

  if (!visited.contains(endId)) return const [];

  final path = <String>[];
  var node = endId;
  while (true) {
    path.add(node);
    if (node == startId) break;
    node = prev[node]!;
  }
  return path.reversed.toList();
}

List<Offset> _buildRoutePoints({
  required FloorPlan plan,
  required String startId,
  required String endId,
  required Map<String, Offset> positions,
  required _LayoutData layout,
  required Map<String, _ChipSize> sizes,
}) {
  var nodePath = _shortestPathNodes(plan, startId, endId);
  if (nodePath.length < 2) return const [];
  if (!positions.containsKey(startId) || !positions.containsKey(endId)) {
    return const [];
  }

  final startPos = positions[startId];
  final endPos = positions[endId];
  if (startPos != null && endPos != null) {
    final rowFrom = _rowFor(startPos.dy, layout);
    final rowTo = _rowFor(endPos.dy, layout);
    if (rowFrom != rowTo) {
      double anchorFromX = startPos.dx;
      double anchorToX = endPos.dx;
      if (layout.topXs.isNotEmpty && layout.hasBottomRow) {
        if (rowFrom == RowPos.bottom) {
          anchorFromX = _closest(layout.topXs, startPos.dx);
        }
        if (rowTo == RowPos.bottom) {
          anchorToX = _closest(layout.topXs, endPos.dx);
        }
      }
      if ((anchorFromX - anchorToX).abs() < 0.5) {
        nodePath = [startId, endId];
      }
    }
  }

  final points = <Offset>[];
  for (var i = 0; i < nodePath.length - 1; i++) {
    final a = nodePath[i];
    final b = nodePath[i + 1];
    final isLast = i == nodePath.length - 2;
    final segment = _edgePathById(
      a,
      b,
      positions,
      layout,
      sizes: sizes,
      trimEnd: isLast,
    );
    if (segment.isEmpty) continue;
    if (points.isNotEmpty) {
      points.addAll(segment.skip(1));
    } else {
      points.addAll(segment);
    }
  }
  return _dedupePoints(points);
}

List<Offset> _dedupePoints(List<Offset> points) {
  if (points.length < 2) return points;
  final result = <Offset>[points.first];
  for (final p in points.skip(1)) {
    final last = result.last;
    if ((p.dx - last.dx).abs() < 0.01 && (p.dy - last.dy).abs() < 0.01) {
      continue;
    }
    result.add(p);
  }
  return result;
}

List<Offset> _edgePathById(
  String fromId,
  String toId,
  Map<String, Offset> positions,
  _LayoutData layout, {
  required Map<String, _ChipSize> sizes,
  bool trimEnd = false,
}) {
  final from = positions[fromId];
  final to = positions[toId];
  if (from == null || to == null) {
    return const [];
  }
  final rowFrom = _rowFor(from.dy, layout);
  final rowTo = _rowFor(to.dy, layout);
  final sameRow = rowFrom == rowTo;
  double anchorFromX = from.dx;
  double anchorToX = to.dx;
  if (layout.topXs.isNotEmpty && layout.hasBottomRow) {
    if (rowFrom == RowPos.bottom) {
      anchorFromX = _closest(layout.topXs, from.dx);
    }
    if (rowTo == RowPos.bottom) {
      anchorToX = _closest(layout.topXs, to.dx);
    }
  }
  final midY = layout.midY;
  final path = <Offset>[from];
  if (sameRow) {
    path.add(Offset(to.dx, from.dy));
  } else {
    if ((anchorFromX - from.dx).abs() > 0.1) {
      path.add(Offset(anchorFromX, from.dy));
    }
    path.add(Offset(anchorFromX, midY));
    if ((anchorToX - anchorFromX).abs() > 0.1) {
      path.add(Offset(anchorToX, midY));
    }
    if ((to.dy - midY).abs() > 0.1) {
      path.add(Offset(anchorToX, to.dy));
    }
    if ((anchorToX - to.dx).abs() > 0.1 &&
        !(trimEnd && rowTo == RowPos.bottom)) {
      path.add(Offset(to.dx, to.dy));
    }
  }
  final target = (trimEnd && rowTo == RowPos.bottom)
      ? Offset(anchorToX, to.dy)
      : to;
  var endPoint = target;

  if (trimEnd && sizes.containsKey(toId)) {
    final sz = sizes[toId]!;
    if (rowTo == RowPos.bottom) {
      const tipGap = 0.0;
      final targetY = target.dy - (sz.height / 2) - tipGap;
      final adjusted = _dedupePoints(path);
      if (adjusted.length == 1) {
        adjusted.add(Offset(target.dx, targetY));
      } else {
        final prev = adjusted[adjusted.length - 2];
        adjusted[adjusted.length - 2] = Offset(target.dx, prev.dy);
        adjusted[adjusted.length - 1] = Offset(target.dx, targetY);
      }
      return adjusted;
    }

    while (path.length >= 2) {
      final last = path.last;
      if ((last.dx - target.dx).abs() < 0.1 &&
          (last.dy - target.dy).abs() < 0.1) {
        path.removeLast();
      } else {
        break;
      }
    }

    Offset prev = path.isNotEmpty ? path.last : from;

    double dx = to.dx - prev.dx;
    double dy = to.dy - prev.dy;

    if (dx.abs() < 0.01 && dy.abs() < 0.01) {
      for (int i = path.length - 2; i >= 0; i--) {
        final candidate = path[i];
        dx = to.dx - candidate.dx;
        dy = to.dy - candidate.dy;
        if (dx.abs() > 0.01 || dy.abs() > 0.01) {
          prev = candidate;
          break;
        }
      }
    }

    if (rowTo == RowPos.bottom) {
      const tipGap = 10.0;

      if (path.isNotEmpty && (path.last.dy - to.dy).abs() < 0.1) {
        path.removeLast();
        prev = path.isNotEmpty ? path.last : from;
      }
      final targetY = to.dy - (sz.height / 2) - tipGap;
      endPoint = Offset(prev.dx, targetY);
      path.add(endPoint);
      return path;
    }

    final segmentLen = sqrt(dx * dx + dy * dy);

    const gap = 0.0;

    if (dx.abs() > dy.abs()) {
      final sign = dx >= 0 ? 1 : -1;

      final offset = min((sz.width / 2) + gap, segmentLen);
      endPoint = Offset(to.dx - sign * offset, to.dy);
    } else {
      final sign = dy >= 0 ? 1 : -1;
      final extraBottomOffset = rowTo == RowPos.bottom ? (sz.height / 2) : 0.0;
      final offset = min((sz.height / 2) + gap + extraBottomOffset, segmentLen);
      endPoint = Offset(to.dx, to.dy - sign * offset);
    }

    if (rowTo == RowPos.bottom) {
      const tipGap = 0.0;
      final targetY = to.dy - (sz.height / 2) - tipGap;
      endPoint = Offset(endPoint.dx, targetY);
    }
  }

  path.add(endPoint);
  return path;
}

enum RowPos { top, mid, bottom }

RowPos _rowFor(double y, _LayoutData layout) {
  if (y < layout.midY - 1) return RowPos.top;
  if (y > layout.midY + 1) return RowPos.bottom;
  return RowPos.mid;
}

double _closest(List<double> list, double target) {
  if (list.isEmpty) return target;
  double best = list.first;
  double bestDiff = (best - target).abs();
  for (final v in list.skip(1)) {
    final d = (v - target).abs();
    if (d < bestDiff) {
      bestDiff = d;
      best = v;
    }
  }
  return best;
}
