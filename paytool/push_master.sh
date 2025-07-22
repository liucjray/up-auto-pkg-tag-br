#!/bin/bash

# 顯示目前的 tag 版本號
echo "Fetching tags..."
git fetch --tag
LATEST_TAG=$(git tag --sort=-v:refname | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found in the repository"
else
    echo "Current latest tag: $LATEST_TAG"
fi

# 提示輸入版本號
read -p "Enter the new version number: " VERSION
if [ -z "$VERSION" ]; then
    echo "Error: Version number cannot be empty"
    exit 1
fi

# 提示輸入開發分支名稱
read -p "Enter the development branch name: " DEV_BRANCH
if [ -z "$DEV_BRANCH" ]; then
    echo "Error: Development branch name cannot be empty"
    exit 1
fi

echo "Using version: $VERSION"
echo "Using development branch: $DEV_BRANCH"

# 更新 master 分支
git fetch origin
git checkout master
git pull origin master

# 合併開發分支
git merge "$DEV_BRANCH"
if [ $? -ne 0 ]; then
    echo "Error: Merge conflict detected"
    exit 1
fi

# 推送到遠端 master
git push origin master

# 創建新分支並使用版本號命名
git checkout -b "$VERSION"
git push origin "$VERSION"

# 創建並推送帶註解的 tag
git tag -a "v$VERSION" -m "$VERSION"
git push origin "v$VERSION"

echo "Release $VERSION created successfully"