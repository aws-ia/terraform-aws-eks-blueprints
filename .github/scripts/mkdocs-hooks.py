import os
from  mkdocs.structure.files import File
from pprint import pprint

def on_page_markdown(markdown, **kwargs):
    markdown.replace('../../patterns/targeted-odcr/', './')
    markdown.replace('../../patterns/kubecost/', './')

    return markdown

def on_files(files, config, **kwargs):
    # Add targeted-odcr screenshots to the generated build
    for odcr_file in [1, 2]:
        files.append(
            File(
                src_dir='./patterns/targeted-odcr/assets/',
                dest_dir=os.path.join(config.site_dir, 'patterns/targeted-odcr/assets/'),
                path=f'odcr-screenshot{odcr_file}.png',
                use_directory_urls=True
            )
        )

    files.append(
        File(
            src_dir='./patterns/kubecost/assets/',
            dest_dir=os.path.join(config.site_dir, 'patterns/kubecost/assets/'),
            path='screenshot.png',
            use_directory_urls=True
        )
    )

    return files
