# to the ConTeXt directory, Robin!
    function condir {
        cd /opt/context/tex/texmf-context/tex/context/base/
    }

# Easy grepping of ConTeXt functions
# Yay synonyms
function com  { condir; grep -R $* * }
function crep { condir; grep -R $* * }

# Inspect a Lua table in ConTeXt's backend
# Requires showtable.lua in ~/tmp
# Call like so: `showtable figures.localpaths`
function showtable {
    # create the file that inspects the table
    cd ~/tmp;
    echo "require('showtable')
          userdata.showtable($1)" > show.lua
    # run the file, but suppress messages
    context show.lua &> -
    # get pertinent messages from the log
    grep '^showtable' show.log
}

# Answer to the ConTeXt Wiki's captcha question
alias hasselt='echo 8061'

# Update ConTeXt
function context-update {
    set lastdir=`pwd`
    cd /opt/context
    rsync -ptv rsync://contextgarden.net/minimals/setup/first-setup.sh .
    ./first-setup.sh --modules=all --keep
    cd $lastdir
    unset lastdir
}

# This is useful for paths of the form `$CONTEXTROOT/first-setup.sh`
export CONTEXTROOT=/opt/context

# Open mwe-$1.tex if it exists;
# If it doesn't exist, create mwe-$1.tex from clipboard and open it;
# If no argument was passed, simply change to the mwe directory.
function mwe {
    local OUTPUTDIR="proj/mwe"
    # First things first: can we write to the directory?
    if [[ -d ~/$OUTPUTDIR ]]; then
        cd ~/$OUTPUTDIR
    else
        echo "The intended output directory, '~/$OUTPUTDIR', does not exist."
        return 1
    fi

    # Open mwe-$1.tex if it exists;
    # If it doesn't exist, create mwe-$1.tex from clipboard and open it;
    # If no argument was passed, simply change to the mwe directory.
    if [[ -n $1 ]]; then;
        filename="mwe-$1.tex"
        if [[ -e "mwe-$1.tex" ]]; then
            vim "mwe-$1.tex"
        else
            echo $filename
            echo '%' `date --rfc-3339=date` > $filename
            # short form: `xsel -b -o`
            xsel --clipboard --output >> $filename
            vim $filename
        fi
    else
        echo "Changed to $OUTPUTDIR."
        echo "Invoke as \`mwe myexample\` to create 'mwe-myexample.tex'."
        return
    fi
}

function pdf2png {
    echo convert -density '$((72 * 4))' $1  -resize 25% ${1:r}.png
    convert -density $((72 * 4)) $1  -resize 25% ${1:r}.png
}
