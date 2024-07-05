@echo off
setlocal enabledelayedexpansion

:: 保存当前代码页
for /f "tokens=2 delims==" %%a in ('chcp') do set "current_codepage=%%a"

:: 设置控制台编码为UTF-8
chcp 65001 >nul

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
>nul 2>&1 echo.>"log.log"

:: 执行Git命令
echo Executing git commands...
(
    git add --all .
    IF %ERRORLEVEL% NEQ 0 (
        echo Git add failed. >> log.log
        goto :end
    )
    git commit -m "!commitMessage!"
    IF %ERRORLEVEL% NEQ 0 (
        echo Git commit failed. >> log.log
        goto :end
    )
    git push origin main
    IF %ERRORLEVEL% NEQ 0 (
        echo Git push failed. >> log.log
        goto :end
    )
) >> log.log 2>&1

:: 执行Hexo命令
echo Executing Hexo commands...
(
    hexo clean
    IF %ERRORLEVEL% NEQ 0 (
        echo Hexo clean failed. >> log.log
        goto :end
    )
    hexo deploy
    IF %ERRORLEVEL% NEQ 0 (
        echo Hexo deploy failed. >> log.log
        goto :end
    )
) >> log.log 2>&1

:: 成功信息
echo All commands executed successfully! >> log.log

:end
echo Execution complete. Check 'log.log' for detailed results.

:: 还原控制台编码
chcp !current_codepage! >nul

pause >nul
exit /b