import requests
import os
import json

from e2e.utils.utils import load_json_file

# common vars
KUBEFLOW_DOMAIN = os.environ.get("KUBEFLOW_DOMAIN", "kubeflow.example.com")
PROFILE_NAMESPACE = os.environ.get("PROFILE_NAMESPACE", "staging")
MODEL_NAME = os.environ.get("MODEL_NAME", "sklearn-irisv2")
AUTH_PROVIDER = os.environ.get("AUTH_PROVIDER", "dex")

URL = f"https://{MODEL_NAME}.{PROFILE_NAMESPACE}.{KUBEFLOW_DOMAIN}/v2/models/{MODEL_NAME}/infer"
HEADERS = {"Host": f"{MODEL_NAME}.{PROFILE_NAMESPACE}.{KUBEFLOW_DOMAIN}"}
DASHBOARD_URL = f"https://kubeflow.{KUBEFLOW_DOMAIN}"

data = load_json_file("./utils/kserve/iris-input.json")

response = None
if AUTH_PROVIDER != "cognito":
    USERNAME = os.environ.get("USERNAME", "user@example.com")
    PASSWORD = os.environ.get("PASSWORD", "12341234")
    
    def session_cookie(host, login, password):
        session = requests.Session()
        response = session.get(host)
        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
        }
        data = {"login": login, "password": password}
        session.post(response.url, headers=headers, data=data)
        session_cookie = session.cookies.get_dict()["authservice_session"]
        return session_cookie

    cookie = {"authservice_session": session_cookie(DASHBOARD_URL, USERNAME, PASSWORD)}
    response = requests.post(URL, headers=HEADERS, json=data, cookies=cookie)
else:
    HTTP_HEADER_NAME = os.environ.get("HTTP_HEADER_NAME", "x-api-key")
    HTTP_HEADER_VALUE = os.environ.get("HTTP_HEADER_VALUE", "token1")
    HEADERS[HTTP_HEADER_NAME] = HTTP_HEADER_VALUE

    response = requests.post(URL, headers=HEADERS, json=data)

status_code = response.status_code
print("Status Code", status_code)
if status_code == 200:
    print("JSON Response ", json.dumps(response.json(), indent=2))
