FROM ubuntu:latest
WORKDIR /tmp
# We could consolidate these and improve provisioning performance
#   however for clarity if others try to find install commands I wrote distinct steps

# non root user info (created at end)

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Need to apt update and upgrade anything not up to date in base image
RUN apt update && apt upgrade -y

# Install AWS CLI
RUN apt install curl zip -y
RUN case $(uname -m) in \
  x86_64) architecture="x86_64" ;; \
  aarch64)    architecture="aarch64" ;; \
  *)      exit 1;; \
esac; \
export DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-${architecture}.zip"; \
echo AWS CLI:  ${DOWNLOAD_URL}; \
curl ${DOWNLOAD_URL} -o "awscliv2.zip"; \
unzip awscliv2.zip; \
./aws/install; \
rm /tmp/awscliv2.zip && rm -rf /tmp/aws

# Install kubectl
RUN case $(uname -m) in \
  x86_64) architecture="amd64" ;; \
  aarch64)    architecture="arm64" ;; \
  *)      exit 1;; \
esac; \
export DOWNLOAD_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${architecture}/kubectl"; \
curl -LO ${DOWNLOAD_URL}
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
kubectl version --client
RUN mkdir /etc/bash_completion.d; \
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null; \
chmod a+r /etc/bash_completion.d/kubectl; \
rm /tmp/kubectl

# Install terraform cli
RUN apt install -y gnupg software-properties-common wget
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update && apt install terraform -y

# EKS Blueprints for Terraform
RUN apt install -y jq gettext bash-completion moreutils

# Useful (pre-commit is required for PRs)
RUN apt install git python3-pip -y
RUN pip3 install pre-commit

# Make sure all is up to date
RUN apt update && apt upgrade -y

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Change the UID/GID to match vscode user
RUN groupmod --gid $USER_GID $USERNAME \
    && usermod --uid $USER_UID --gid $USER_GID $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME
SHELL ["/usr/bin/bash"]
