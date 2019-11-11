import "dart:html";
import "dart:typed_data";

import "package:LoaderLib/Loader.dart";
import 'package:WFCLib/WFCLib.dart';

Future<void> main() async {
    /*const int stride = 5;
    final Int32List input = Int32List.fromList(<int>[
        0, 0, 0, 0, 0,
        0, 1, 1, 1, 0,
        0, 1, 0, 1, 0,
        0, 1, 0, 1, 0,
        0, 0, 0, 0, 0,
    ]);*/

    /*const int stride = 11;
    final Int32List input = Int32List.fromList(<int>[
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 0,
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
        0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0,
        0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ]);*/

    const int stride = 20;
    final Int32List input = Int32List.fromList(<int>[
        0,
        2,
        2,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        0,
        4,
        4,
        4,
        0,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        1,
        1,
        0,
        4,
        4,
        4,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        2,
        2,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        4,
        4,
        4,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        2,
        2,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        4,
        4,
        4,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        2,
        2,
        0,
        0,
        0,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        3,
        3,
        0,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        3,
        3,
        3,
        0,
        1,
        1,
        3,
        3,
        3,
        0,
        0,
        0,
        1,
        1,
        3,
        3,
        0,
        0,
        0,
        0,
        3,
        3,
        3,
        0,
        1,
        1,
        3,
        3,
        3,
        0,
        4,
        4,
        1,
        1,
        3,
        3,
        2,
        2,
        0,
        0,
        3,
        3,
        3,
        0,
        1,
        1,
        3,
        3,
        3,
        0,
        4,
        4,
        1,
        1,
        3,
        3,
        2,
        2,
        0,
        0,
        3,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        2,
        2,
        0,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        0,
        4,
        4,
        4,
        2,
        2,
        2,
        0,
        1,
        1,
        3,
        3,
        0,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        0,
        4,
        4,
        4,
        2,
        2,
        2,
        0,
        1,
        1,
        3,
        3,
        0,
        0,
        0,
        0,
        1,
        1,
        0,
        0,
        0,
        4,
        4,
        4,
        2,
        0,
        0,
        0,
        1,
        1,
        3,
        3,
        3,
        0,
        0,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        4,
        4,
        4,
        1,
        1,
        3,
        3,
        3,
        0,
        0,
        1,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        4,
        4,
        4,
        1,
        1,
        3,
        3,
        3,
        0,
        0,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        2,
        2,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        0,
        4,
        4,
        4,
        0,
        0,
        0,
        0,
    ]);

    /*final WFC wfc = new WFC(input, stride, 3, periodicInput: true, mirror: true, rotate: true);

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
    printTile(generated, size);*/

    //print("");
    //printAdjacencies(wfc.tiles.first, 1, -1);

    /*const int size = 100;
    OverlappingModel wfc = new OverlappingModel(input, stride, 3, size, size, true, false, 8, 0);

    final bool success = wfc.run(0, 0);

    Int32List result = wfc.getOutput();
    
    printTile(result, size);

    print(success);*/

    Formats.init();
    querySelector("#button").append(FileFormat.loadButton(Formats.png, load));

    //generateTest(input, stride);
}

Future<void> load(ImageElement image, String name) async {
    final WaveFunctionCollapse wfc = new WaveFunctionCollapse();

    final Element output = querySelector("#output");

    output..children.clear()..text = "Working...";

    final NumberInputElement width = querySelector("#width");
    final NumberInputElement height = querySelector("#width");
    final NumberInputElement N = querySelector("#N");
    final NumberInputElement symmetry = querySelector("#symmetry");
    final NumberInputElement ground = querySelector("#ground");
    final CheckboxInputElement periodicInput = querySelector("#periodicInput");
    final CheckboxInputElement periodicOutput = querySelector("#periodicOutput");
    final NumberInputElement seed = querySelector("#seed");

    print("WFC init");
    final List<int> palette = await wfc.initWithImage(image, N.valueAsNumber, width.valueAsNumber, height.valueAsNumber, symmetry: symmetry.valueAsNumber, ground: ground.valueAsNumber, periodicInput: periodicInput.checked, periodicOutput: periodicOutput.checked);

    print("generating");
    final ImageElement result = await wfc.generateImage(seed.valueAsNumber, palette);
    
    wfc.destroy();

    output
        ..children.clear()
        ..append(result);
}

Future<void> generateTest(Int32List input, int stride) async {

    const int size = 100;
    final WaveFunctionCollapse wfc = new WaveFunctionCollapse();

    print("WFC init");
    await wfc.init(input, stride, 3, size, size, periodicOutput: false);

    print("generating");
    final Int32List result = await wfc.generate(0);

    printTile(result, size);
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

/*void printAdjacencies(WFCTile tile, int xOffset, int yOffset) {
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
}*/