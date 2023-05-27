#!/bin/bash

terraform destroy -target=module.eks -auto-approve
terraform destroy -auto-approve
