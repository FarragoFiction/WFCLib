import "dart:typed_data";

import "package:CommonLib/Collection.dart";
import "package:CommonLib/Random.dart";

abstract class WFCBase<T> {
    int tileSize;

    WeightedList<WFCTile> tiles = new WeightedList<WFCTile>();

    WFCBase(Int32List input, int stride, int this.tileSize, {bool periodicInput = false, bool mirror = true, bool rotate = true}) {
        this.generateTiles(input, stride, periodicInput, mirror, rotate);
    }

    void generateTiles(Int32List input, int stride, bool periodic, bool mirror, bool rotate) {
        final int w = stride;
        final int h = input.length ~/ w;
        if (w*h != input.length) { throw Exception("WFC Input must be rectangular: w: $w, h: $h, length: ${input.length}, expected length: ${w*h}"); }

        final int ymax = (periodic ? h : h - (this.tileSize - 1));
        final int xmax = (periodic ? w : w - (this.tileSize - 1));

        for(int y=0; y < ymax; y++) {
            for(int x=0; x < xmax; x++) {
                final WFCTile tile = new WFCTile(tileSize, input, (int tx, int ty) {
                    int ix = x + tx;
                    if (ix >= w) { ix -= w; }
                    int iy = y + ty;
                    if (iy >= h) { iy -= h; }
                    return iy * w + ix;
                });
                this.tiles.add(tile);
                if (mirror) { this.tiles.add(tile.reflect()); }

                if (rotate) {
                    final WFCTile r1 = tile.rotate();
                    this.tiles.add(r1);

                    final WFCTile r2 = r1.rotate();
                    this.tiles.add(r2);

                    final WFCTile r3 = r2.rotate();
                    this.tiles.add(r3);

                    if (mirror) {
                        this.tiles.add(r1.reflect());
                        this.tiles.add(r2.reflect());
                        this.tiles.add(r3.reflect());
                    }
                }

                // shift duplicate tiles into single entries
                this.tiles.collateWeights();
            }
        }
    }

    Int32List generate(int width, int height, {List<bool> mask, Random rand, bool periodic = false}) {
        rand ??= new Random();

        final int length = width*height;
        final Int32List output = new Int32List.fromList(new List<int>.filled(length, -1));
        final List<WFCNode> nodeMap = new List<WFCNode>(length);

        final T open = createOpenSet();

        void addNewNode(int x, int y, int id, List<WFCTile> tiles) {
            final WFCNode node = new WFCNode(x, y, id, tiles);
            nodeMap[id] = node;
            addToOpenSet(open, node);
        }

        void updateNode(WFCNode node) {
            //print("update 1");
            node.tiles.retainWhere((WFCTile tile) => tile.match(node.x,node.y,output, (int x, int y) {
                int ox = node.x + x;
                int oy = node.y + y;

                if (periodic) {
                    if (ox < 0) {
                        ox += width;
                    } else if (ox >= width) {
                        ox -= width;
                    }
                    if (oy < 0) {
                        oy += height;
                    } else if (oy >= height) {
                        oy -= height;
                    }
                } else {
                    if (ox < 0 || ox >= width || oy < 0 || oy >= height) {
                        return -1;
                    }
                }

                //print("nx: ${node.x}, ny: ${node.y}, x: $x, y: $y, ox: $ox, oy: $oy");

                return oy * width + ox;
            }));
            //print("update 2");
            node.potential = this.tiles.length;
        }

        // first node
        int initial;
        //WFCNode initialNode;
        // initial block, for the sake of vars
        {
            if (mask != null) {

            } else {
                initial = rand.nextInt(length);
            }
            final int y = initial ~/ width;
            final int x = initial % width;
            addNewNode(x, y, initial, tiles);
        }

        // main loop
        while (!openIsEmpty(open)) {
            //print("loop 1");
            final WFCNode node = getNextNode(open);
            updateNode(node);

            final WFCTile tile = node.collapse(rand);

            if (tile == null) {
                return null; // fail state
            }

            output[node.id] = tile.value;
            nodeMap[node.id] = null;

            //print("loop 2");

            int x,y,id;
            for (int oy = -1; oy <= 1; oy++) {
                for (int ox = -1; ox <= 1; ox++) {
                    if (ox == 0 && oy == 0) { continue; }

                    x = node.x + ox;
                    y = node.y + oy;

                    //print("loop inner 1");

                    // loop or discard if out of bounds
                    if (periodic) {
                        if (x < 0) {
                            x += width;
                        } else if (x >= width) {
                            x -= width;
                        }
                        if (y < 0) {
                            y += height;
                        } else if (y >= height) {
                            y -= height;
                        }
                    } else {
                        if (x < 0 || x >= width || y < 0 || y >= height) {
                            continue;
                        }
                    }

                    id = y * width + x;

                    // discard if out of mask
                    if (mask != null) {
                        if (!mask[id]) {
                            continue;
                        }
                    }

                    //print("loop inner 2");

                    // discard if already filled or update if a node
                    if (output[id] != -1) {
                        continue;
                    }
                    //print("loop inner 3");
                    if (nodeMap[id] != null) {
                        // update the node then do whatever the open list needs
                        //nodeMap[id].update(output, nodeMap, periodic);
                        updateNode(nodeMap[id]);
                        updateListForNode(open, nodeMap[id]);
                        continue;
                    }

                    //print("loop inner 4");
                    // add a new node if needed and update it
                    addNewNode(x, y, id, tiles);
                    //nodeMap[id].update(output, nodeMap, periodic);
                    //print("loop inner 5");
                    updateNode(nodeMap[id]);
                    //print("loop inner 6");
                    updateListForNode(open, nodeMap[id]);

                    //print("loop inner 7");
                }
            }
        }

        return output;
    }

    Int32List generateWithRetries(int width, int height, {List<bool> mask, Random rand, bool periodic = false}) {
        Int32List output;
        int tries = 0;
        while (output == null) {
            output = this.generate(width, height, mask:mask, rand:rand, periodic:periodic);
            tries++;

            if (tries > 1000) {
                throw Exception("Aborting generation after 1000 failed attempts");
            }
        }
        print("Generated after $tries attempts");
        return output;
    }

    T createOpenSet();
    void addToOpenSet(T open, WFCNode node);
    bool openIsEmpty(T open);
    WFCNode getNextNode(T open);
    void updateListForNode(T open, WFCNode node);
}

class WFCTile {
    int size;
    Int32List data;
    int _hash;

    WFCTile(int this.size, Int32List input, int Function(int x, int y) transform ) {
        data = new Int32List(size*size);

        for (int y=0; y<size; y++) {
            for (int x=0; x<size; x++) {
                data[y*size +x] = input[transform(x,y)];
            }
        }
    }

    WFCTile reflect() => new WFCTile(size, data, (int x, int y) => y * size + (size - 1 - x));

    WFCTile rotate() => new WFCTile(size, data, (int x, int y) => x * size + (size - 1 - y));

    int get value => data[(data.length-1) ~/ 2];

    bool match(int x, int y, Int32List map, int Function(int x, int y) getId) {
        final int o = (size-1) ~/ 2;

        //print("match 1");

        int ox,oy, id, mapval;
        for (int iy = 0; iy < size; iy++) {
            for (int ix = 0; ix < size; ix++) {
                //print("match loop");
                ox = ix - o;
                oy = iy - o;

                if (ox == 0 && oy == 0) { continue; } // don't need to check the middle

                id = getId(ox,oy);

                // if id is -1, then it's out of bounds and we're not periodic, so ignore
                if (id == -1) {
                    continue;
                }

                mapval = map[id];
                if (mapval != -1 && mapval != data[iy*size+ix]) {
                    return false;
                }
            }
        }

        return true;
    }

    @override
    int get hashCode {
        if (_hash != null) { return _hash; }

        _hash = 0;

        for (int i=0; i<this.data.length; i++) {
            _hash += this.data[i] + 1;
            _hash *= i + 1;
        }

        return _hash;
    }

    @override
    bool operator ==(dynamic other) {
        if (!(other is WFCTile)) { return false; }
        if (this.hashCode != other.hashCode) {
            return false;
        }

        for (int i=0; i<this.data.length; i++) {
            if (this.data[i] != other.data[i] ) {
                return false;
            }
        }

        return true;
    }
}

class WFCNode {
    int x;
    int y;
    int id;

    int potential;
    WeightedList<WFCTile> tiles;

    WFCNode(int this.x, int this.y, int this.id, WeightedList<WFCTile> tiles) {
        this.tiles = new WeightedList<WFCTile>.from(tiles);
        this.potential = this.tiles.length;
    }

    WFCTile collapse(Random rand) {
        return rand.pickFrom(this.tiles);
    }
}

class WFC extends WFCBase<Set<WFCNode>> {
    WFC(Int32List input, int stride, int tileSize, {bool periodicInput = false, bool mirror = true, bool rotate = true}) :
        super(input, stride, tileSize, periodicInput: periodicInput, mirror: mirror, rotate: rotate);

    @override
    Set<WFCNode> createOpenSet() => <WFCNode>{};
    @override
    void addToOpenSet(Set<WFCNode> open, WFCNode node) => open.add(node);
    @override
    bool openIsEmpty(Set<WFCNode> open) => open.isEmpty;

    @override
    WFCNode getNextNode(Set<WFCNode> open) {
        int potential = this.tiles.length + 1;
        WFCNode best;

        for (final WFCNode node in open) {
            if (node.potential < potential) {
                potential = node.potential;
                best = node;
            }
        }

        open.remove(best);
        return best;
    }

    @override
    void updateListForNode(Set<WFCNode> open, WFCNode node) {
        // don't need to do anything here for the set version
    }
}