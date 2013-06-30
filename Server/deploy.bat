echo on

rem compress jar package
del seeds.war
rem rename seeds.war seeds.war.bak

cd build\classes
"C:\Program Files\7-Zip\7z.exe" a -tzip Seeds.jar com\*
copy Seeds.jar ..\..\
move Seeds.jar ..\..\WebContent\WEB-INF\lib

cd ..\..\
copy lib\hibernate\*.jar WebContent\WEB-INF\lib
copy lib\json\*.jar WebContent\WEB-INF\lib
copy lib\htmlparser\*.jar WebContent\WEB-INF\lib
copy lib\rss\*.jar WebContent\WEB-INF\lib

rem create war package
cd WebContent
"C:\Program Files\7-Zip\7z.exe" a -tzip seeds.war * WEB-INFO\* META-INF\*
move seeds.war ..\

cd ..
del WebContent\WEB-INF\lib\*.jar
pause