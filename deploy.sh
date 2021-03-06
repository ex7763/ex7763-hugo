#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Clean emacs backup
rm *~

# add source
git add -A
git commit -m "Auto hugo"
git push origin master

# Build the project.
hugo -t hugo-lithium-theme

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..
