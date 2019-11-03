import "dart:typed_data";

import "package:CommonLib/Collection.dart";
import 'package:WFCLib/WFCLib.dart';

void main() {
    const int stride = 5;
    final Int32List input = Int32List.fromList(<int>[
        0, 0, 0, 0, 0,
        0, 1, 1, 1, 0,
        0, 1, 0, 1, 0,
        0, 1, 0, 1, 0,
        0, 0, 0, 0, 0,
    ]);

    final WFC wfc = new WFC(input, stride, 3, periodicInput: true);

    for (int i=0; i<wfc.tiles.length; i++) {
        final WeightPair<WFCTile> pair = wfc.tiles.getPair(i);
        final WFCTile tile = pair.item;

        print("");
        print("$i @ ${pair.weight} ----- ${tile.hashCode}");
        print("");
        printTile(tile.data, tile.size);
    }

    const int size = 20;
    final Int32List generated = wfc.generateWithRetries(size, size);

    print("OUTPUT:");
    printTile(generated, size);
}

void printTile(Int32List data, int stride) {
    final int width = stride;
    final int height = data.length ~/ stride;

    for (int y=0; y<height; y++) {
        String out = "";
        for (int x=0; x<width; x++) {
            out += "${data[y*width +x]} ";
        }
        print(out);
    }
}
