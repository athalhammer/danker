from setuptools import setup

with open("README_PR.md", "r") as f:
    long_description = f.read()

setup(
    name='danker',
    version='0.5.1',
    url='https://github.com/athalhammer/danker',
    author='Andreas Thalhammer',
    author_email='andreas@thalhammer.bayern',
    description='Compute PageRank on large graphs with ' +
                'off-the-shelf hardware.',
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=['danker'],
    classifiers=[
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'License :: OSI Approved :: GNU General Public License v3 (GPLv3)',
        'Operating System :: OS Independent',
        'Topic :: Scientific/Engineering :: Information Analysis',
    ],
    python_requires='>=3.5',
    install_requires=[]
)
