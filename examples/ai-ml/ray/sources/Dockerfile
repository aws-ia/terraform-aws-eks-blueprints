FROM rayproject/ray:nightly

RUN sudo apt-get update -y && \
   pip install s3fs torch torchvision transformers pandas datasets accelerate scikit-learn mlflow tensorboard https://s3-us-west-2.amazonaws.com/ray-wheels/latest/ray-3.0.0.dev0-cp37-cp37m-manylinux2014_x86_64.whl

COPY *.py /opt/
