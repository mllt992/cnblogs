@echo off
setlocal enabledelayedexpansion

:: 获取当前时间
for /f "tokens=2-4 delims=/." %%a in ('date /T') do (
    set year=%%c
    set month=%%a
    set day=%%b
)
for /f "tokens=1-2 delims=:." %%a in ('time /T') do (
    set hour=%%a
    set min=%%b
)
set commitMessage=bat%run% %year%-%month%-%day% %hour%:%min%

:: 初始化日志文件
powershell -Command "Add-Content -Path 'log.log' -Value ''" >nul 2>&1

:: 执行Git命令
echo Executing git commands...
powershell -Command "&{git add --all .; if ($LASTEXITCODE -ne 0) { Add-Content -Path 'log.log' -Value 'Git add failed.' } else { git commit -m '!commitMessage!'; if ($LASTEXITCODE -ne 0) { Add-Content -Path 'log.log' -Value 'Git commit failed.' } else { git push origin main; if ($LASTEXITCODE -ne 0) { Add-Content -Path 'log.log' -Value 'Git push failed.' } } } }"

:: 执行Hexo命令
echo Executing Hexo commands...
powershell -Command "&{hexo clean; if ($LASTEXITCODE -ne 0) { Add-Content -Path 'log.log' -Value 'Hexo clean failed.' } else { hexo deploy; if ($LASTEXITCODE -ne 0) { Add-Content -Path 'log.log' -Value 'Hexo deploy failed.' } } }"

:: 成功信息
powershell -Command "Add-Content -Path 'log.log' -Value 'All commands executed successfully!'"

:end
echo Execution complete. Check 'log.log' for detailed results.
pause >nul
exit /b