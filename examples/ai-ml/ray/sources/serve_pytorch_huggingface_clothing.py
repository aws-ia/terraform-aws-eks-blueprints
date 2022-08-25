import ray
from ray import serve
import torch
from ray.train.torch import TorchPredictor, TorchCheckpoint
from transformers import AutoConfig, AutoModelForSequenceClassification, AutoTokenizer
import tempfile
import s3fs
import boto3


@serve.deployment(route_prefix="/predict", version="0.1.0")
class Predictor:

    def __init__(self):
        self.classes = [
            "Negative",
            "Neutral",
            "Positive",
        ]

        s3_file = s3fs.S3FileSystem()
        ssm = boto3.client("ssm")
        s3_path = ssm.get_parameter(Name="/ray-demo/model_checkpoint")["Parameter"]["Value"]
        model_path = tempfile.mkdtemp()
        s3_file.get(s3_path, model_path, recursive=True)
        print(model_path)
        num_labels = 3
        use_slow_tokenizer = False

        base_model_name_or_path = "roberta-base"

        self.config = AutoConfig.from_pretrained(
            base_model_name_or_path, num_labels=num_labels,
        )
        self.tokenizer = AutoTokenizer.from_pretrained(
            base_model_name_or_path, use_fast=not use_slow_tokenizer
        )
        self.base_model = AutoModelForSequenceClassification.from_pretrained(
            base_model_name_or_path,
            config=self.config,
        )

        self.model = TorchCheckpoint(local_path=model_path).get_model(self.base_model)
        print(self.model)


    def __call__(self, request):
        txt = request.query_params["txt"]
        self.model.eval()
        with torch.no_grad():
            tokenized_txt = self.tokenizer.encode_plus(
                txt,
                padding='max_length',
                max_length=64,
                truncation=True,
                return_tensors="pt"
            )
            input_ids = tokenized_txt["input_ids"]
            pred = self.model(input_ids)
            predicted_class = self.classes[pred[0].argmax()]
            return predicted_class

ray.shutdown()
ray.init(address="ray://raycluster-autoscaler-head-svc:10001", namespace="serve",
         runtime_env={"pip": [
                        "torch",
                        "scikit-learn",
                        "transformers",
                        "pandas",
                        "datasets",
                        "accelerate",
                        "scikit-learn",
                        "mlflow",
                        "tensorboard",
                        "s3fs"
                     ]
         })

serve.start(detached=True, http_options={"host": "0.0.0.0"})

Predictor.deploy()
