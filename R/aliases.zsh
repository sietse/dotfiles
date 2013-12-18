alias R='R --no-save --quiet'

# Wine launchers for Winbugs and R
if [[ `hostname -s` = 'plums' ]]; then
    function wineobugs {
        wine /home/sietse/.wine/drive_c/bin/OpenBUGS321/OpenBUGS.exe
    }

    function winewbugs {
        wine /home/sietse/.wine/drive_c/bin/WinBUGS14/WinBUGS14.exe
    }

    function winer {
        wineconsole /home/sietse/.wine/drive_c/bin/R/R-2.11.1/bin/R.exe &
    }
fi
