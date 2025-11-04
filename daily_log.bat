@echo off
cd /d "C:\Users\rinsh\OneDrive\Desktop\vscode\GitAutoLogger\newRepoServices\Implementations"
echo Auto commit at %date% %time% >> DatabaseUpdates.txt
git add .
git commit -m "DataBase Updated on %date% %time%"
git push origin main
exit
