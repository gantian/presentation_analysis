form Get Formant
    sentence directory .
    real nInterv 100
    real interv 0.01
endform

#directory$ =  ""

# read files
Create Strings as file list... list 'directory$'/*.wav
numberOfFiles = Get number of strings

for ifile to numberOfFiles
    
    select Strings list
    name$ = Get string... ifile
    Read from file... 'directory$'/'name$'

    intdur = Get total duration
    nInterv = floor(intdur/interv)
    
    #Specify the name of the output file
    outfile$ = name$ + "_formant.txt"
    #"formant_" + name$ + ".txt"

    #If the output file already exists, delete it
    filedelete 'directory$'\'outfile$'

    #In output file, add a line with name, duration, F1, F2 values
    fileappend 'directory$'\'outfile$' 'timestamp' 'tab$' 'F1Value' 'tab$' 'F2Value' 'newline$'
    fileappend 'directory$'\'outfile$' 'numInterv' 'tab$' 'nInterv' 'newline$'

    Read from file... 'directory$'\'name$'
    
    #soundname$ = selected$("Sound")
    soundid = selected("Sound")
    
    select 'soundid'
    To Formant (burg)... 0.01 5 5500 0.025 50

    for j from 1 to 'nInterv'

        beg = (j-1)*interv
        end = j*interv
        dur = end - beg
        mid = (dur/2)+beg

        formantId = selected("Formant")
        select 'formantId'

        #Formant 'name$'
        f1 = Get value at time... 1 'mid' Hertz Linear
        f2 = Get value at time... 2 'mid' Hertz Linear
        fileappend 'directory$'\'outfile$' 'mid:3' 'tab$' 'f1:1' 'tab$' 'f2:1' 'newline$'
        
    endfor
    
endfor

select all
Remove