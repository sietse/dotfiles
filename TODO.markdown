## copy oh-my-zsh theme over

Good themes:
* "robbyrussell"
* "smt"
* "clean"
* "dieter"
* "nicoulaj"

Decent themes:
* "candy"

## autocomplete for the cheat program

    # Autocomplete for the cheat program
    function complete_cheat {
      COMPREPLY=()
      if [ $COMP_CWORD = 1 ]; then
        local sheets=`cheat sheets | grep '^  '`
        COMPREPLY=(`compgen -W "$sheets" -- $2`)
      fi
    }
    # complete -F complete_cheat cheat
