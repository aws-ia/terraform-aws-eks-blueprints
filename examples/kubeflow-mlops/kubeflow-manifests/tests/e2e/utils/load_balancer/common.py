# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

import yaml
import logging

logger = logging.getLogger(__name__)

CONFIG_FILE = "./utils/load_balancer/config.yaml"

LB_KUSTOMIZE_PATH = "../../deployments/add-ons/load-balancer/"
