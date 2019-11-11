import "dart:html";
import "dart:typed_data";

import "package:CommonLib/Workers.dart";

import "commands.dart";

class WaveFunctionCollapse {

    WorkerHandler worker;

    int width, height;

    WaveFunctionCollapse() {
        this.worker = createWebWorker("package:WFCLib/src/wfc.worker.dart");
    }

    Future<Int32List> generate(int seed, {int limit = 10}) async {
        final Map<String, dynamic> payload = <String,dynamic>{
            "seed": seed,
            "limit": limit
        };

        return worker.sendCommand(Commands.generate, payload: payload);
    }

    Future<ImageElement> generateImage(int seed, List<int> palette, {int limit = 10}) async {
        final Int32List data = await generate(seed, limit: limit);

        final CanvasElement bufferCanvas = new CanvasElement(width: width, height: height);
        final CanvasRenderingContext2D ctx = bufferCanvas.context2D;

        final ImageData imageData = new ImageData(width, height);
        final Uint32List pixels = imageData.data.buffer.asUint32List();

        for(int i=0; i<data.length; i++) {
            pixels[i] = palette[data[i]];
        }

        ctx.putImageData(imageData, 0, 0);

        final String url = bufferCanvas.toDataUrl();
        final ImageElement image = new ImageElement(src: url);
        await image.onLoad.first;

        return image;
    }

    Future<void> init(Int32List input, int stride, int N, int width, int height, {bool periodicInput = true, bool periodicOutput = false, int symmetry = 8, int ground = 0}) {
        final Map<String, dynamic> payload = <String,dynamic>{
            "type": Commands.overlappingModel,
            "input": input,
            "stride": stride,
            "N": N,
            "width": width,
            "height": height,
            "periodicInput": periodicInput,
            "periodicOutput": periodicOutput,
            "symmetry": symmetry,
            "ground": ground
        };

        this.width = width;
        this.height = height;

        return worker.sendCommand(Commands.init, payload: payload);
    }

    Future<List<int>> initWithImage(CanvasImageSource image, int N, int width, int height, {bool periodicInput = true, bool periodicOutput = false, int symmetry = 8, int ground = 0}) async {
        int w,h;

        if (image is ImageElement) {
            w = image.width;
            h = image.height;
        } else if (image is CanvasElement) {
            w = image.width;
            h = image.height;
        } else if (image is VideoElement) {
            w = image.width;
            h = image.height;
        }

        final CanvasElement bufferCanvas = new CanvasElement(width:w, height:h);
        final CanvasRenderingContext2D ctx = bufferCanvas.context2D;
        ctx.drawImage(image, 0, 0);

        final Uint32List pixels = ctx.getImageData(0, 0, w, h).data.buffer.asUint32List();
        final Int32List input = new Int32List(pixels.length);
        final Map<int,int> palette = <int,int>{};

        int pixel, id = 0;
        for (int i=0; i<pixels.length; i++) {
            pixel = pixels[i];
            if (!palette.containsKey(pixel)) {
                palette[pixel] = id;
                id++;
            }

            input[i] = palette[pixel];
        }

        await init(input, w, N, width, height, periodicInput: periodicInput, periodicOutput: periodicOutput, symmetry: symmetry, ground: ground);

        return palette.keys.toList();
    }

    void destroy() => this.worker.destroyWorker();
}