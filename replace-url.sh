#!/usr/bin/env bash
find argocd -name '*.yaml' -exec sed -i \
  's#<YOUR_GIT_REPO_URL>#https://github.com/tayyab-java/assignment.git#g' {} +
