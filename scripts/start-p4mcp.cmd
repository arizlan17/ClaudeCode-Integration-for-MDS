@echo off
cd /d "%~dp0.."
where py >nul 2>&1
if %errorlevel%==0 (
  py -3 "%~dp0start_p4mcp.py"
) else (
  python "%~dp0start_p4mcp.py"
)
