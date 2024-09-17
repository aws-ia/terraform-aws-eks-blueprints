import os
from  mkdocs.structure.files import File
from pprint import pprint

def on_page_markdown(markdown, **kwargs):
    markdown.replace('../../patterns/targeted-odcr/', './')
    markdown.replace('../../patterns/kubecost/', './')

    return markdown

def on_files(files, config, **kwargs):
    # Add targeted-odcr screenshots to the generated build
    path = 'patterns/targeted-odcr/assets/'
    for odcr_file in [1, 2]:
        files.append(
            File(
                src_dir=f'./{path}',
                dest_dir=os.path.join(config.site_dir, path),
                path=f'odcr-screenshot{odcr_file}.png',
                use_directory_urls=True
            )
        )

    path = 'patterns/kubecost/assets/'
    files.append(
        File(
            src_dir=f'./{path}',
            dest_dir=os.path.join(config.site_dir, path),
            path='screenshot.png',
            use_directory_urls=True
        )
    )

    for svg in ['cached.svg', 'uncached.svg', 'state-machine.png']:
        files.append(
            File(
                src_dir=f'./patterns/ml-container-cache/assets/',
                dest_dir=os.path.join(config.site_dir, 'patterns/machine-learning/ml-container-cache/assets/'),
                path=svg,
                use_directory_urls=True
            )
        )


    return files
