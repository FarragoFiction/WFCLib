import "dart:typed_data";

import "package:CommonLib/Collection.dart";
import 'package:WFCLib/WFCLib.dart';

void main() {
    /*const int stride = 5;
    final Int32List input = Int32List.fromList(<int>[
        0, 0, 0, 0, 0,
        0, 1, 1, 1, 0,
        0, 1, 0, 1, 0,
        0, 1, 0, 1, 0,
        0, 0, 0, 0, 0,
    ]);*/

    const int stride = 11;
    final Int32List input = Int32List.fromList(<int>[
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ]);

    final WFC wfc = new WFC(input, stride, 3, periodicInput: true, mirror: true, rotate: true);

    for (int i=0; i<wfc.tiles.length; i++) {
        final WeightPair<WFCTile> pair = wfc.tiles.getPair(i);
        final WFCTile tile = pair.item;

        print("");
        print("$i @ ${pair.weight} ----- ${tile.hashCode}");
        print("");
        printTile(tile.data, tile.size);
        print(tile.validNeighbours);
    }

    const int size = 10;
    final Int32List generated = wfc.generateWithRetries(size, size);

    print("OUTPUT:");
    printTile(generated, size);

    //print("");
    //printAdjacencies(wfc.tiles.first, 1, -1);

}

void printTile(Int32List data, int stride) {
    final int width = stride;
    final int height = data.length ~/ stride;

    for (int y=0; y<height; y++) {
        String out = "";
        for (int x=0; x<width; x++) {
            final int v = data[y*width +x];
            out += "${v == -1 ? "X" : v} ";
        }
        print(out);
    }
}

void printAdjacencies(WFCTile tile, int xOffset, int yOffset) {
    print("Tile:");
    printTile(tile.data, tile.size);

    final int o = (tile.size-1) ~/2;
    final Set<WFCTile> adjacencies = tile.validNeighbours[(yOffset + o) * tile.size + (xOffset + o)];

    print("");
    print("Adjacencies at $xOffset,$yOffset (${adjacencies.length})");

    for (final WFCTile adj in adjacencies) {
        print("");
        printTile(adj.data, adj.size);
    }
}