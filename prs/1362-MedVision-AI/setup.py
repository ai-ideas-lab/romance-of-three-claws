"""
MedVision AI - AI辅助精准诊疗平台安装配置
"""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="medvision-ai",
    version="1.0.0",
    author="ava-agent",
    author_email="team@ava-agent.com",
    description="AI辅助精准诊疗平台 - 多模态医疗AI融合系统",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ava-agent/awesome-ai-ideas",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Healthcare Industry",
        "Topic :: Scientific/Engineering :: Medical Science Apps.",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
    python_requires=">=3.9",
    install_requires=requirements,
    extras_require={
        "dev": [
            "pytest>=7.4.0",
            "pytest-cov>=4.1.0",
            "black>=23.7.0",
            "flake8>=6.0.0",
            "mypy>=1.5.0",
        ],
        "gpu": [
            "torch[audio,vision]>=2.0.0",
        ],
        "docs": [
            "sphinx>=7.2.0",
            "sphinx-rtd-theme>=1.3.0",
            "mkdocs>=1.5.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "medvision-ai=medvision_ai.cli:main",
            "medvision-server=medvision_ai.server:main",
        ],
    },
    include_package_data=True,
    package_data={
        "medvision_ai": [
            "configs/*.yaml",
            "models/*.pth",
            "data/*.json",
        ],
    },
    project_urls={
        "Bug Reports": "https://github.com/ava-agent/awesome-ai-issues",
        "Source": "https://github.com/ava-agent/awesome-ai-ideas",
        "Documentation": "https://medvision-ai.readthedocs.io/",
    },
)