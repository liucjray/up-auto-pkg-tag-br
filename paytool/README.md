
### 執行 paytool push master
```
cd /home/user/codes/super/paytool;
bash /home/user/codes/me/mysh/paytool/push_master.sh;
```

### push_master.sh 會執行的 git 指令
```
# 獲取套件最大版號
git fetch --tag
git tag --sort=-v:refname | head -n 1

# 以版號 {版本號} 為例

git fetch origin
git co master
git pull origin master

git merge {你的開發分支}
git push origin master

git checkout -b {版本號}
git push origin {版本號}
git tag -a v{版本號} -m "{版本號}"
git push origin v{版本號}
```