import json
import glob
import re


def get_patterns():
    """
    Get all pattern root directories using their respective `main.tf`;
    returning a string formatted json array of the example directories minus those that are excluded
    """
    exclude = {
        'patterns/appmesh-mtls',  # excluded until Rout53 is setup
        'patterns/blue-green-upgrade/environment',
        'patterns/blue-green-upgrade/modules/eks_cluster',
        'patterns/istio-multi-cluster/1.cluster1', # relies on remote state
        'patterns/istio-multi-cluster/2.cluster2', # relies on remote state
        'patterns/privatelink-access',
    }

    projects = {
        x.replace('/main.tf', '')
        for x in glob.glob('patterns/**/main.tf', recursive=True)
        if not re.match(r'^.+/_', x)
    }

    print(json.dumps(list(projects.difference(exclude))))


if __name__ == '__main__':
    get_patterns()
