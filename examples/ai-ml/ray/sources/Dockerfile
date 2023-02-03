FROM rayproject/ray:nightly

RUN sudo apt-get update -y && \
    pip install torch torchvision transformers pandas datasets accelerate \
        scikit-learn mlflow tensorboard s3fs ray[all]==2.0.0rc0 boto3

COPY *.py /opt/
