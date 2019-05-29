from setuptools import setup, find_packages

setup(
    name='danker',
    version='0.4.0',
    url='https://github.com/athalhammer/danker',
    author='Andreas Thalhammer',
    author_email='andreas@thalhammer.bayern',
    description='Compute PageRank on ~3 billion Wikipedia links on off-the-shelf hardware.',
    packages=find_packages(),
    install_requires=[]
)
