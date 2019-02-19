        #!/bin/ksh
        integer j i=31
        while [[ $i -le 256 ]]
        do
          [[ $i -eq 127 ]] && i=160
          j=$(printf "%o" $i)
          print -n $j'\t'\\0$j'\t'
          [[ $i%5 -eq 0 ]] && print
          i=$i+1
        done
        echo
#
# you may need to execute  
# stty -istrip cs8
# first
