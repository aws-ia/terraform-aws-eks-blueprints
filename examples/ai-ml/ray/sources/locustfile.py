from locust import HttpUser, task


review_text = (
    "This product is sucks!"
)


class InferenceUser(HttpUser):
    @task
    def inference_test(self):
        self.client.get("/serve/predict?txt=" + review_text)