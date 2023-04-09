@echo off
rem This file was created by pub v2.17.1.
rem Package: dart_eval
rem Version: 0.5.6
rem Executable: dart_eval
rem Script: dart_eval
if exist "C:\Users\ARMA\AppData\Local\Pub\Cache\global_packages\dart_eval\bin\dart_eval.dart-2.17.1.snapshot" (
  call dart "C:\Users\ARMA\AppData\Local\Pub\Cache\global_packages\dart_eval\bin\dart_eval.dart-2.17.1.snapshot" %*
  rem The VM exits with code 253 if the snapshot version is out-of-date.
  rem If it is, we need to delete it and run "pub global" manually.
  if not errorlevel 253 (
    goto error
  )
  dart pub global run dart_eval:dart_eval %*
) else (
  dart pub global run dart_eval:dart_eval %*
)
goto eof
:error
exit /b %errorlevel%
:eof

