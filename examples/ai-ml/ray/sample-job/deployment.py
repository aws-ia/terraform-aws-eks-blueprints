# File name: summarizer_on_ray_serve.py
from importlib_metadata import version
import ray
from ray import serve
from transformers import pipeline


ray.init(address="ray://example-cluster-ray-head:10001", namespace="serve")
serve.start(detached=True, http_options={"host": "0.0.0.0"})


@serve.deployment(route_prefix="/summarize", version="0.1.0")
class Summarizer:
    def __init__(self):
        self.summarize = pipeline("summarization", model="t5-small")

    def __call__(self, request):
        txt = request.query_params["txt"]
        summary_list = self.summarize(txt)
        summary = summary_list[0]["summary_text"]
        return summary

Summarizer.deploy()
