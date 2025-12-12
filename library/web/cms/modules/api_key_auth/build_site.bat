setlocal
set CWD=%cd%

echo [api_key_auth] Build css files from scss 
cd %~dp0site\files
call:scss2css style

cd %CWD%
goto:eof

:scss2css
	::sass --scss --sourcemap=none -t expanded scss\%~1.scss:css\%~1.css
	sass --no-source-map --style=expanded scss\%~1.scss:css\%~1.css
goto:eof
cd ..\..
endlocal

