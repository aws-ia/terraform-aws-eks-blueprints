import torch
from torch import nn

from ray.train.torch import TorchCheckpoint
import s3fs
import tempfile


ray.init(address="ray://example-cluster-ray-head:10001", namespace="serve")
serve.start(detached=True, http_options={"host": "0.0.0.0"})


@serve.deployment(route_prefix="/predict", version="0.1.0")
class Predictor:
    def __init__(self):
        self.model = model_loaded

    def __call__(self, request):
        txt = request.query_params["txt"]
        summary_list = self.summarize(txt)
        summary = summary_list[0]["summary_text"]
        return summary

Predictor.deploy()

def predict_from_model(model):
    classes = [
        "T-shirt/top",
        "Trouser",
        "Pullover",
        "Dress",
        "Coat",
        "Sandal",
        "Shirt",
        "Sneaker",
        "Bag",
        "Ankle boot",
    ]

    model.eval()
    x, y = test_data[0][0], test_data[0][1]
    with torch.no_grad():
        pred = model(x)
        predicted, actual = classes[pred[0].argmax(0)], classes[y]
        print(f'Predicted: "{predicted}", Actual: "{actual}"')
        
s3_file = s3fs.S3FileSystem()
s3_path = "ray-demo-models-20220729044638883100000001/model"
model_path = tempfile.mkdtemp()
s3_file.get(s3_path, tempfile.mkdtemp(), recursive=True)

model_loaded = TorchCheckpoint(local_path=model_path).get_model(NeuralNetwork())

predict_from_model(model_loaded)