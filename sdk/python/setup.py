#
#  setup.py
#  macos-computer-use Python SDK
#
#  Created by macos-computer-use authors on 2026.
#  Copyright (c) 2026 macos-computer-use authors. All rights reserved.
#  Licensed under the MIT License.
#

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="macos-computer-use",
    version="3.3.0",
    author="macos-computer-use authors",
    description="Official Python SDK for macos-computer-use - macOS computer control for AI Agents",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/macos-computer-use/macos-computer-use",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: MacOS",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: System :: Systems Administration",
    ],
    python_requires=">=3.8",
    keywords="macos automation ai agent computer-use mcp",
    project_urls={
        "Bug Reports": "https://github.com/macos-computer-use/macos-computer-use/issues",
        "Source": "https://github.com/macos-computer-use/macos-computer-use",
        "Documentation": "https://github.com/macos-computer-use/macos-computer-use/blob/main/docs/智能体实战指南.md",
    },
)
