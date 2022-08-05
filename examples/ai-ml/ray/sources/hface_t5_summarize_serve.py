# source: https://github.com/ray-project/ray/blob/master/python/ray/serve/examples/doc/e2e_class_deployment.py
from importlib_metadata import version
import ray
from ray import serve
from transformers import pipeline


ray.init(address="ray://raycluster-autoscaler-head-svc:10001", namespace="serve")
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
