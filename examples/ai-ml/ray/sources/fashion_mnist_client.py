import requests
import os


review_text = (
    "This product is great!"
)

response = requests.get("https://ray-demo."+os.environ["TF_VAR_eks_cluster_domain"]+"/serve/predict?txt=" + review_text).text
print(response)
