import json
import glob
import re


def get_examples():
    """
    Get all Terraform example root directories using their respective `versions.tf`;
    returning a string formatted json array of the example directories minus those that are excluded
    """
    exclude = {
        'examples/appmesh-mtls',  # excluded until Rout53 is setup
        'examples/blue-green-upgrade/environment',
        'examples/blue-green-upgrade/modules/eks_cluster',
        'examples/istio-multi-cluster/1.cluster1', # relies on remote state
        'examples/istio-multi-cluster/2.cluster2', # relies on remote state
        'examples/privatelink-access',
    }

    projects = {
        x.replace('/versions.tf', '')
        for x in glob.glob('patterns/**/versions.tf', recursive=True)
        if not re.match(r'^.+/_', x)
    }

    print(json.dumps(list(projects.difference(exclude))))


if __name__ == '__main__':
    get_examples()
