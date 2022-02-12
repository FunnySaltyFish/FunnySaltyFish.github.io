@echo off
git add *
git commit -m "auto deploy"
git push -u github main 
echo "git comit&push success"