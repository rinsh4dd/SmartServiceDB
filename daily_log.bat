@echo off
cd /d "C:\Users\rinsh\OneDrive\Documents\SQL Server Management Studio\SmartServeDB"
echo Database Updated at %date% %time% >> DatabaseUpdates.txt
git add .
git commit -m "DataBase Updated on %date% %time%"
git push origin main
exit
