#!/bin/bash

# 顯示目前的 tag 版本號
echo "Fetching tags..."
git fetch --tag

# 找出異常的 tags（不符合 vX.Y.Z 格式）
INVALID_TAGS=$(git tag | grep -vE '^v[0-9]+\.[0-9]+\.[0-9]+$')
if [ -n "$INVALID_TAGS" ]; then
    echo "Warning: Found invalid tags (not matching vX.Y.Z format):"
    echo "$INVALID_TAGS" | sed 's/^/  - /'
    echo ""
fi

# 只取正確格式的 tags
LATEST_TAG=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo "No tags found in the repository"
else
    echo "Current latest tag: $LATEST_TAG"
fi

# 提示輸入版本號
read -p "Enter the new version number (e.g., 1.0.0): " VERSION
if [ -z "$VERSION" ]; then
    echo "Error: Version number cannot be empty"
    exit 1
fi

# 檢查版本號格式（必須是 X.Y.Z 格式）
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format. Use MAJOR.MINOR.PATCH (e.g., 1.0.0)"
    exit 1
fi

# 如果有最新標籤，比較版本號
if [ -n "$LATEST_TAG" ]; then
    # 移除標籤前的 'v' 前綴（如果存在）
    LATEST_TAG_CLEAN=${LATEST_TAG#v}
    
    # 將版本號分解為數字部分
    IFS=$'.' read -r -a latest_parts <<< "$LATEST_TAG_CLEAN"
    IFS=$'.' read -r -a new_parts <<< "$VERSION"

    # 比較 MAJOR, MINOR, PATCH
    for ((i=0; i<3; i++)); do
        latest_num=${latest_parts[$i]:-0}
        new_num=${new_parts[$i]:-0}
        if [ "$new_num" -gt "$latest_num" ]; then
            break
        elif [ "$new_num" -lt "$latest_num" ]; then
            echo "Error: New version ($VERSION) must be higher than latest version ($LATEST_TAG)"
            exit 1
        elif [ $i -eq 2 ]; then
            echo "Error: New version ($VERSION) must be higher than latest version ($LATEST_TAG)"
            exit 1
        fi
    done
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