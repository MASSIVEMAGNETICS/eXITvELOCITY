#!/bin/bash

# Check for required tools
REQUIRED_TOOLS=(gh git git-lfs unzip)

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is not installed. Please install it before running this script."
        exit 1
    fi
done

# Authenticate gh if needed
if ! gh auth status &> /dev/null; then
    echo "Authenticating GitHub CLI..."
    gh auth login
fi

# Create downloads directory
mkdir -p downloads

# Download the GitHub Actions artifact
echo "Downloading the GitHub Actions artifact..."
gh run download --id 24489198704 --dir downloads/

# Unzip the wav file
mkdir -p wav
unzip downloads/wav_24b_48k.zip -d wav/

# Set up Git LFS tracking for *.wav files
git lfs track '*.wav'

# Ensure .gitattributes is added
if [ ! -f .gitattributes ]; then
    echo ".gitattributes file not found, creating one..."
    touch .gitattributes
fi

# Add changes to git
git add wav/ .gitattributes

# Commit and push changes
git commit -m 'Add WAVs via Git LFS'
git push origin $(git rev-parse --abbrev-ref HEAD)
