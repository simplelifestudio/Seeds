echo on

rem compress jar package
del Seeds.war.bak
rename Seeds.war Seeds.war.bak

cd build\classes
"C:\Program Files\7-Zip\7z.exe" a -tzip Seeds.jar com\*
move Seeds.jar ..\..\WebContent\WEB-INF\lib

rem create war package
cd ..\..\WebContent
"C:\Program Files\7-Zip\7z.exe" a -tzip Seeds.war * WEB-INFO\* META-INF\*
move Seeds.war ..\

cd ..
pause