import "dart:math" as Math;
import "dart:typed_data";

import "model.dart";
import "util.dart";

class OverlappingModel extends Model {
    int N;
    List<Uint8List> patterns;
    int ground;

    OverlappingModel(Int32List input, int stride, int this.N, int width, int height, bool periodicInput, bool periodicOutput, int symmetry, int ground) : super(width, height) {
        periodic = periodicOutput;

        final int SMX = stride;
        final int SMY = input.length ~/ stride;
        int C = 0;

        for (int i=0; i<input.length; i++) {
            C = Math.max(C, input[i]+1);
        }

        final int W = Utils.toPower(C, N*N);

        Uint8List pattern(int Function(int x, int y) f) {
            final Uint8List result = new Uint8List(N * N);
            for (int y=0; y<N; y++) {
                for (int x=0; x<N; x++) {
                    result[x + y * N] = f(x,y);
                }
            }
            return result;
        }

        Uint8List patternFromSample(int x, int y) => pattern((int dx, int dy) => input[((y + dy) % SMY) * stride + ((x + dx) % SMX)]);
        Uint8List rotate(Uint8List p) => pattern((int x, int y) => p[N - 1 - y + x * N]);
        Uint8List reflect(Uint8List p) => pattern((int x, int y) => p[N - 1 - x + y * N]);

        int index(Uint8List p) {
            int result = 0, power = 1;
            for (int i=0; i<p.length; i++) {
                result += p[p.length - 1 - i] * power;
                power *= C;
            }
            return result;
        }

        Uint8List patternFromIndex(int ind) {
            int residue = ind, power = W;
            final Uint8List result = new Uint8List(N*N);

            for (int i=0; i<result.length; i++) {
                power ~/= C;
                int count = 0;

                while (residue >= power) {
                    residue -= power;
                    count++;
                }

                result[i] = count;
            }

            return result;
        }

        final Map<int,int> weights = <int,int>{};
        final List<int> ordering = <int>[];

        for (int y=0; y<(periodicInput ? SMY : SMY - N + 1); y++) {
            for (int x=0; x<(periodicInput ? SMX : SMX - N + 1); x++) {
                final List<Uint8List> ps = new List<Uint8List>(8);

                ps[0] = patternFromSample(x, y);
                ps[1] = reflect(ps[0]);
                ps[2] = rotate(ps[0]);
                ps[3] = reflect(ps[2]);
                ps[4] = rotate(ps[2]);
                ps[5] = reflect(ps[4]);
                ps[6] = rotate(ps[4]);
                ps[7] = reflect(ps[6]);

                for (int k=0; k<symmetry; k++) {
                    final int ind = index(ps[k]);
                    if (weights.containsKey(ind)) {
                        weights[ind]++;
                    } else {
                        weights[ind] = 1;
                        ordering.add(ind);
                    }
                }
            }
        }

        T = weights.length;
        this.ground = (ground + T) % T;
        patterns = new List<Uint8List>(T);
        this.weights = new List<double>(T);

        int counter = 0;
        for(final int w in ordering) {
            patterns[counter] = patternFromIndex(w);
            this.weights[counter] = weights[w].toDouble();
            counter++;
        }

        bool agrees(Uint8List p1, Uint8List p2, int dx, int dy) {
            final int xmin = dx < 0 ? 0 : dx, xmax = dx < 0 ? dx + N : N, ymin = dy < 0 ? 0 : dy, ymax = dy < 0 ? dy + N : N;
            for (int y=ymin; y<ymax; y++) {
                for (int x=xmin; x<xmax; x++) {
                    if (p1[x + N * y] != p2[x - dx + N * (y-dy)]) {
                        return false;
                    }
                }
            }
            return true;
        }

        propagator = new List<List<List<int>>>(4);
        for (int d=0; d<4; d++) {
            propagator[d] = new List<List<int>>(T);
            for (int t=0; t<T; t++) {
                final List<int> list = <int>[];
                for (int t2=0; t2<T; t2++) {
                    if (agrees(patterns[t], patterns[t2], Model.dirX[d], Model.dirY[d])) {
                        list.add(t2);
                    }
                }
                propagator[d][t] = list;
            }
        }
    }

    @override
    bool onBoundary(int x, int y) => !periodic && (x + N > width || y + N > height || x < 0 || y < 0);

    @override
    void clear() {
        super.clear();

        if (ground != 0) {
            for (int x=0; x<width; x++) {
                for (int t=0; t<T; t++) {
                    if (t != ground) {
                        ban(x + (height-1) * width, t);
                    }
                }
                for (int y=0; y<height - 1; y++) {
                    ban(x + y * width, ground);
                }
            }

            propagate();
        }
    }

    @override
    Int32List getOutput() {
        if (observed == null) {
            print("observed is null");
            return null;
        }

        final Int32List output = new Int32List(width * height);

        for (int y=0; y<height; y++) {
            final int dy = y < height - N + 1 ? 0 : N-1;
            for (int x=0; x<width; x++) {
                final int dx = x < width - N + 1 ? 0 : N-1;

                output[x + y * width] = patterns[observed[x-dx + (y-dy) * width]][dx + dy*N];
            }
        }

        return output;
    }
}