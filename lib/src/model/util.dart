
abstract class Utils {
    static int doubleRandom(List<double> a, double r) {
        double sum = 0;
        for (int i=0; i<a.length; i++) {
            sum += a[i];
        }
        for (int i=0; i<a.length; i++) {
            a[i] /= sum;
        }

        int i = 0;
        double x = 0;

        while (i < a.length) {
            x += a[i];
            if (r <= x) return i;
            i++;
        }

        return 0;
    }

    static int toPower(int a, int n) {
        int product = 1;
        for (int i=0; i<n; i++) {
            product *= a;
        }
        return product;
    }
}