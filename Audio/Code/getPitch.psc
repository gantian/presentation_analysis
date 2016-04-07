form Get Pitch
    sentence directory .
    real nInterv 100
    real interv 0.01   
    real isMale = 1
endform
# F:\Code\praat5404_win64

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
    outfile$ = name$ + "_pitch_intensity.txt"    

    #If the output file already exists, delete it
    filedelete 'directory$'\'outfile$'

    fileappend 'directory$'\'outfile$' 'timestamp' 'tab$' 'V_Pitch' 'tab$' 'V_Intensity' 'newline$'
    fileappend 'directory$'\'outfile$' 'numInterv' 'tab$' 'nInterv' 'newline$'

    Read from file... 'directory$'\'name$'
        
    soundid = selected("Sound")
    
    select 'soundid'  
    if isMale > 0.5  
        To Pitch: 0.01, 60, 400
    else
        To Pitch: 0.01, 120, 500
    endif
    Rename: "pitch"
    
    selectObject: soundid
    To Intensity: 75, 0.001
    Rename: "intensity"

    for j from 1 to 'nInterv'

        beg = (j-1)*interv
        end = j*interv
        dur = end - beg
        mid = (dur/2)+beg

        selectObject: "Pitch pitch"
        pitch = Get value at time: end, "Hertz", "Linear"        
        selectObject: "Intensity intensity"
        intensity = Get value at time: end, "Cubic"        
        
        fileappend 'directory$'\'outfile$' 'end:2' 'tab$' 'pitch:3' 'tab$' 'intensity:3' 'newline$'
        
    endfor
    
endfor

select all
Remove