@echo off
cd /d "C:\Users\rinsh\OneDrive\Desktop\vscode\GitAutoLogger\newRepoServices\Implementations"
echo Auto commit at %date% %time% >> TechnicianServices.txt
git add .
git commit -m "Technician Service Updated on %date% %time%"
git push origin main
exit
