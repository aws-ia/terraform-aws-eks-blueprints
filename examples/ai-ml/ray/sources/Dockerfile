FROM rayproject/ray:latest

RUN sudo apt-get update -y && \
    pip install -U transformers torch torchvision 

COPY *.py /opt/
