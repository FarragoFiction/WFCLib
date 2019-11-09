import "dart:math" as Math;
import "dart:typed_data";

import "package:CommonLib/Random.dart";

import "util.dart";

abstract class Model {
    static const List<int> DX = <int>[ -1,0,1,0 ];
    static const List<int> DY = <int>[ 0,1,0,-1 ];
    static const List<int> opposite = <int>[ 2,3,0,1 ];

    List<List<bool>> wave;

    List<List<List<int>>> propagator;
    List<List<List<int>>> compatible;
    List<int> observed;

    List<Math.Point<int>> stack;
    int stackSize;

    Random random;
    int FMX, FMY, T;
    bool periodic;

    List<double> weights;
    List<double> weightLogWeights;

    List<int> sumsOfOnes;
    double sumOfWeights, sumOfWeightLogWeights, startingEntropy;
    List<double> sumsOfWeights, sumsOfWeightLogWeights, entropies;

    Model(int width, int height) : FMX = width, FMY = height;

    void init() {
        wave = new List<List<bool>>(FMX * FMY);
        compatible = new List<List<List<int>>>(wave.length);
        for (int i=0; i<wave.length; i++) {
            wave[i] = new List<bool>(T);
            compatible[i] = new List<List<int>>(T);
            for (int t=0; t<T; t++) {
                compatible[i][t] = new List<int>(4);
            }
        }

        weightLogWeights = new List<double>(T);
        sumOfWeights = 0;
        sumOfWeightLogWeights = 0;

        for (int t=0; t<T; t++) {
            weightLogWeights[t] = weights[t] * Math.log(weights[t]);
            sumOfWeights += weights[t];
            sumOfWeightLogWeights += weightLogWeights[t];
        }

        startingEntropy = Math.log(sumOfWeights) - sumOfWeightLogWeights / sumOfWeights;

        sumsOfOnes = new List<int>(FMX * FMY);
        sumsOfWeights = new List<double>(FMX * FMY);
        sumsOfWeightLogWeights = new List<double>(FMX * FMY);
        entropies = new List<double>(FMX * FMY);

        stack = new List<Math.Point<int>>(wave.length * T);
        stackSize = 0;
    }

    bool observe() {
        double min = 1E+3;
        int argmin = -1;

        for (int i=0; i<wave.length; i++) {
            if (onBoundary(i % FMX, i ~/ FMY)) { continue; }

            int amount = sumsOfOnes[i];
            if (amount == 0) { return false; }

            double entropy = entropies[i];
            if (amount > 1 && entropy <= min) {
                double noise = 1E-6 * random.nextDouble();
                if (entropy + noise < min) {
                    min = entropy + noise;
                    argmin = i;
                }
            }
        }

        if (argmin == -1) {
            observed = new List<int>(FMX * FMY);
            for (int i=0; i<wave.length; i++) {
                for (int t = 0; t<T; t++) {
                    if (wave[i][t]) {
                        observed[i] = t;
                        break;
                    }
                }
            }
            return true;
        }

        List<double> distribution = new List<double>(T);
        for (int t = 0; t<T; t++) {
            distribution[t] = wave[argmin][t] ? weights[t] : 0;
        }
        int r = Utils.doubleRandom(distribution, random.nextDouble());

        List<bool> w = wave[argmin];
        for (int t=0; t<T; t++) {
            if (w[t] != (t == r)) {
                ban(argmin, t);
            }
        }

        return null;
    }

    void propagate() {
        while (stackSize > 0) {
            Math.Point<int> e1 = stack[stackSize -1];
            stackSize--;

            int i1 = e1.x;
            int x1 = i1 % FMX, y1 = i1 ~/ FMY;

            for (int d=0; d<4; d++) {
                int dx = DX[d], dy = DY[d];
                int x2 = x1 + dx, y2 = y1 + dy;
                if (onBoundary(x2,y2)) { continue; }

                if (x2 < 0) { x2 += FMX; }
                else if (x2 >= FMX) { x2 -= FMX; }
                if (y2 < 0) { y2 += FMY; }
                else if (y2 >= FMY) { y2 -= FMY; }

                int i2 = x2 + y2 * FMX;
                List<int> p = propagator[d][e1.y];
                List<List<int>> compat = compatible[i2];

                for (int l=0; l<p.length; l++) {
                    int t2 = p[l];
                    List<int> comp = compat[t2];

                    comp[d]--;
                    if (comp[d] == 0) { ban(i2, t2); }
                }
            }
        }
    }

    bool run(int seed, int limit) {
        if (wave == null) { init(); }

        clear();
        random = new Random(seed);

        for (int l=0; l<limit || limit == 0; l++) {
            bool result = observe();
            if (result != null) { return result; }
            propagate();
        }

        return true;
    }

    void ban(int i, int t) {
        wave[i][t] = false;

        List<int> comp = compatible[i][t];
        for (int d = 0; d<4; d++) { comp[d] = 0; }
        stack[stackSize] = new Math.Point<int>(i, t);
        stackSize++;

        sumsOfOnes[i] -= 1;
        sumsOfWeights[i] -= weights[t];
        sumsOfWeightLogWeights[i] -= weightLogWeights[t];

        double sum = sumsOfWeights[i];
        entropies[i] = Math.log(sum) - sumsOfWeightLogWeights[i] / sum;
    }

    void clear() {
        for (int i=0; i<wave.length; i++) {
            for (int t=0; t<T; t++) {
                wave[i][t] = true;
                for (int d=0; d<4; d++) {
                    compatible[i][t][d] = propagator[opposite[d]][t].length;
                }
            }

            sumsOfOnes[i] = weights.length;
            sumsOfWeights[i] = sumOfWeights;
            sumsOfWeightLogWeights[i] = sumOfWeightLogWeights;
            entropies[i] = startingEntropy;
        }
    }

    bool onBoundary(int x, int y);

    Int32List getOutput();
}