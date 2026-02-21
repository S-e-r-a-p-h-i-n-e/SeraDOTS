#!/bin/bash

cava -p ~/.config/cava/config | awk -F';' '
BEGIN {
    blocks[0]=" "; blocks[1]=" "; blocks[2]=" "; blocks[3]=" "; blocks[4]=" "
    blocks[5]="▂"; blocks[6]="▂"; blocks[7]="▂"; blocks[8]="▂"
    blocks[9]="▃"; blocks[10]="▃"; blocks[11]="▃"; blocks[12]="▃"
    blocks[13]="▄"; blocks[14]="▄"; blocks[15]="▄"; blocks[16]="▄"
    blocks[17]="▅"; blocks[18]="▅"; blocks[19]="▅"; blocks[20]="▅"
    blocks[21]="▆"; blocks[22]="▆"; blocks[23]="▆"; blocks[24]="▆"
    blocks[25]="▇"; blocks[26]="▇"; blocks[27]="▇"; blocks[28]="▇"
    blocks[29]="█"; blocks[30]="█"; blocks[31]="█"; blocks[32]="█"
}
{
    output=""
    for (i=1; i<=NF; i++)
        output = output blocks[$i+0]
    print output
    fflush()
}'
