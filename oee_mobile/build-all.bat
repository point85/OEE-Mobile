call flutter clean
call flutter gen-l10n
rem android app
call flutter build appbundle
rem windows app
call flutter build windows
rem Edge and Chrome apps
call flutter build web