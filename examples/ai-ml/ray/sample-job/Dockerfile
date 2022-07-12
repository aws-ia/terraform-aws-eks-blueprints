FROM rayproject/ray:latest

RUN sudo apt-get update -y && \
    pip install transformers torch torchvision

COPY deployment.py /opt/deployment.py
