import "dart:typed_data";

import "package:CommonLib/Random.dart";
import "package:CommonLib/Workers.dart";

import "commands.dart";
import "model/model.dart";
import "model/overlappingmodel.dart";

class WFCWorker extends WorkerBase {

    Model model;

    WFCWorker() {
        print("WFC worker started");
    }

    @override
    Future<dynamic> handleCommand(String command, dynamic payload) async {

        switch(command) {
            case Commands.init:
                return initialise(payload);
            case Commands.generate:
                return generate(payload);
        }
    }

    Future<void> initialise(dynamic payload) async {
        if (model != null) { throw new WorkerException("WFC already initialised!"); }

        final Map<dynamic,dynamic> data = payload;

        if (data["type"] == Commands.overlappingModel) {
            model = new OverlappingModel(data["input"], data["stride"], data["N"], data["width"], data["height"],
                data["periodicInput"], data["periodicOutput"], data["symmetry"], data["ground"]);
        }
    }

    Future<Int32List> generate(dynamic payload) async {
        if (model == null) { throw new WorkerException("WFC not initialised"); }

        final Map<dynamic, dynamic> data = payload;

        final Random rand = new Random(data["seed"]);

        bool solved = false;
        final int limit = data["limit"];
        int iteration = 0;

        while (iteration < limit && !solved) {
            iteration++;
            print("WFC attempt $iteration");
            solved = model.run(rand.nextInt(), 0);
        }

        if (solved) {
            return model.getOutput();
        }
        throw new WorkerException("WFC exceeded attempt limit of $limit");
    }
}

void main() {
    new WFCWorker();
}