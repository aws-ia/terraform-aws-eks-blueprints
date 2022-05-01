import json
import glob
import re
import os


def get_tfplan_examples():
    """
    Get all Terraform example root directories using their respective `versions.tf`;
    returning a string formatted json array of the example directories minus those that are excluded
    """
    exclude = set(os.environ.get('EXCLUDE_EXAMPLES', '').split(','))

    projects = {
        x.replace('/versions.tf', '')
        for x in glob.glob('examples/**/versions.tf', recursive=True)
        if not re.match(r'^.+/_', x)
    }

    print(json.dumps(list(projects.difference(exclude))))


if __name__ == '__main__':
    get_tfplan_examples()
