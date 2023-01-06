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
        'examples/eks-cluster-with-external-dns',  # excluded until Rout53 is setup
        'examples/fully-private-eks-cluster/vpc',  # skipping until issue #711 is addressed
        'examples/fully-private-eks-cluster/eks',
        'examples/fully-private-eks-cluster/add-ons',
        'examples/ai-ml/ray',  # excluded until #887 is fixed,
        'examples/crossplane' #example removed
        'examples/upgrade/blue-green-route53'
    }

    projects = {
        x.replace('/versions.tf', '')
        for x in glob.glob('examples/**/versions.tf', recursive=True)
        if not re.match(r'^.+/_', x)
    }

    print(json.dumps(list(projects.difference(exclude))))


if __name__ == '__main__':
    get_examples()
