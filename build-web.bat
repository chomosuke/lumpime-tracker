CALL CD frontend
CALL flutter build web --web-renderer canvaskit
CALL CD ..
CALL RD /S /Q "web_build"
CALL MD "web_build"
CALL Robocopy "frontend\build\web" "web_build" /E /NFL /NDL /NJH /NJS /nc /ns /np
