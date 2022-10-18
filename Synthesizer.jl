using Gtk
using Sound
using FFTW
using WAV
using LinearAlgebra
using Gtk.ShortNames, GtkReactive
using StatsBase

g = GtkGrid() # initialize a grid to hold buttons
set_gtk_property!(g, :row_spacing, 5) # gaps between buttons
set_gtk_property!(g, :column_spacing, 5)
set_gtk_property!(g, :margin_left, 5)
set_gtk_property!(g, :margin_right, 5)
set_gtk_property!(g, :margin_top, 5)
set_gtk_property!(g, :margin_bottom, 5)
set_gtk_property!(g, :row_homogeneous, true) # stretch with window resize
set_gtk_property!(g, :column_homogeneous, true)

startingKey = "A"
chosenClef = "One Clef"
chosenKey = "A"
startingMode = "Major"
instrument = "Trumpet"
file = ""
keyMode = "Major"
noteLength = "Whole"
song = Float64[]
tempo = 60
octave = 0
notePercent = Float64[]
possibleKeyNotes = Float64[]
notePercentages = [22.66 0. 19.01 0. 7.94 3.52 1.56 25. 0. 17.06 0. 3.26]
finalPercentError = 100
startingKeyIndex = 0
chosenKeyIndex = 0
uniqueDurations = Float64[]

database = ["G" "Major" 26.77 8.74 3.01 0.82 2.73 22.68 0.00 12.57 10.93 0.00 4.37 0.00;
"C" "Major" 6.64 0.00 5.81 29.05 0.00 6.64 0.00 14.52 10.37 1.66 23.65 0.00;
"D" "Major" 15.28 0.00 30.4 0.00 7.51 4.69 0.00 11.26 0.00 3.75 27.08 0.00;
"A" "Minor" 16.71 0.00 2.00 14.21 0.00 27.14 0.00 8.86 14.64 0.5 15.5 0.00;
"A#/Bb" "Major" 4.21 26.05 0.00 27.63 0.00 11.58 2.63 0.00 8.95 0.00 20.53 0.00;
"C#/Db" "Major" 0.00 2.82 0.00 3.04 51.12 0.00 9.46 0.00 3.53 16.53 0.00 13.49;
"D#/Eb" "Minor" 0.41 15.55 4.63 0.72 19.46 0.00 37.69 0.00 1.54 14.32 0.00 5.66;
"G#/Ab" "Minor" 0.00 1.8 22.14 0.00 21.17 0.00 13.96 6.74 0.00 16.36 0.00 17.81;
"A" "Major" 22.66 0. 19.01 0. 7.94 3.52 1.56 25. 0. 17.06 0. 3.26;
"F" "Major" 17.03 8.51 0. 21.22 0. 12.7 0. 2.57 28.38 0. 9.59 0.;
"G#/Ab" "Major" 0. 13.59 0.7 15.85 10.1 1.57 18.64 0. 10.45 0. 5.57 23.87;
"E" "Minor" 2.87 0.38 15.11 0.76 3.63 19.5 0. 24.09 0. 2.1 28.3 3.25;
"B" "Minor" 16.3 0. 27.59 0. 6.67 14.07 0. 8.33 0. 17.96 9.07 0.;
"E" "Major" 11.02 0. 22.68 0. 8.42 0. 7.99 29.16 0. 13.39 0. 7.34;
"A#/Bb" "Minor" 1.03 36.69 2.84 1.03 3.62 0.52 24.03 1.55 0.52 21.19 0.52 6.46;
"F" "Minor" 0.97 2.13 0. 30.62 7.56 0. 8.91 3.88 16.28 0. 18.8 10.66;
"F#/Gb" "Major" 0. 46.08 0.25 0. 14.32 0. 5.85 0. 12.95 15.32 0. 5.23
"B" "Major" 0. 7.61 20.38 0. 11.96 0. 8.97 2.99 13.59 2.99 0. 31.52;
"G" "Minor" 3.59 22.84 0. 8.79 0. 12.77 11.94 0. 23.71 0. 17.29 0.;
"D" "Minor" 8.63 17.56 0. 21.43 0. 14.58 0. 4.46 21.73 0. 11.31 0.;
"F#/Gb" "Minor" 42.17 0. 7. 1.1 5.89 3.87 0. 14.36 0. 16.02 0.74 8.84;
"D#/Eb" "Major" 0. 16.52 0. 14.14 0. 5.51 12.2 0. 19.05 0. 20.68 11.90;
"C" "Minor" 0. 7.42 1.2 26.08 0. 0.72 0.24 26.32 0. 6.94 2.15 8.61;
"C#/Db" "Minor" 5.87 0. 8.7 0. 23.04 0. 0.43 18.7 0. 26.30 0. 16.96;]

buttonStyleOne = GtkCssProvider(data = "#wg {color:white; background:purple;}")
buttonStyleTwo = GtkCssProvider(data = "#wa {color:black; background:orchid;}")
buttonStyleThree = GtkCssProvider(data = "#bw {color:black; background:white;}")
buttonStyleFour = GtkCssProvider(data = "#black {color:white; background:black;}")
buttonStyleFive = GtkCssProvider(data = "#white {color: black; background:white;}")
labelStyleOne = GtkCssProvider(data = "#menuLabels {color:purple; font: bold 16px Arial;}")
backgroundStyle = GtkCssProvider(data = "#p {background:lightgray;}")


# Make major mode button
majorButton = GtkButton("Major")
majorKeyType = "Major"
push!(GAccessor.style_context(majorButton),GtkStyleProvider(buttonStyleTwo),600)
set_gtk_property!(majorButton, :name, "wa")
signal_connect((w) -> keyTypes(majorKeyType), majorButton, "clicked")
g[5:6,5] = majorButton

# Make minor mode button
minorButton = GtkButton("Minor")
minorKeyType = "Minor"
push!(GAccessor.style_context(minorButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(minorButton, :name, "bw")
signal_connect((w) -> keyTypes(minorKeyType), minorButton, "clicked")
g[5:6,6] = minorButton

finalMajorButton = GtkButton("Major")
finalKeyModeMajor = "Major"
push!(GAccessor.style_context(finalMajorButton),GtkStyleProvider(buttonStyleTwo),600)
set_gtk_property!(finalMajorButton, :name, "wa")
signal_connect((w) -> keyFunc(finalKeyModeMajor), finalMajorButton, "clicked")
g[5:6,8] = finalMajorButton

finalMinorButton = GtkButton("Minor")
finalKeyModeMinor = "Minor"
push!(GAccessor.style_context(finalMinorButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(finalMinorButton, :name, "bw")
signal_connect((w) -> keyFunc(finalKeyModeMinor), finalMinorButton, "clicked")
g[5:6,9] = finalMinorButton

# Make one clef button
oneClefButton = GtkButton("One Clef")
oneClefType = "One Clef"
push!(GAccessor.style_context(oneClefButton),GtkStyleProvider(buttonStyleTwo),600)
set_gtk_property!(oneClefButton, :name, "wa")
signal_connect((w) -> clefFunc(oneClefType), oneClefButton, "clicked")
g[1:3,8] = oneClefButton

# Make multiple clefs button
multiClefButton = GtkButton("Multiple Clefs")
multiClefType = "Multiple Clefs"
push!(GAccessor.style_context(multiClefButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(multiClefButton, :name, "bw")
signal_connect((w) -> clefFunc(multiClefType), multiClefButton, "clicked")
g[1:3,9] = multiClefButton

# Make playback button
playbackButton = GtkButton("Playback")
push!(GAccessor.style_context(playbackButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(playbackButton, :name, "bw")
signal_connect((w) -> playbackFunc(song,44100),playbackButton,"clicked")
g[7:9,4:6] = playbackButton

# Make transcribe button
transcribeButton = GtkButton("Transcribe")
push!(GAccessor.style_context(transcribeButton), GtkStyleProvider(buttonStyleOne), 600)
set_gtk_property!(transcribeButton, :name, "wg")
signal_connect((w) -> transcribeFunc(chosenClef,startingKey,startingMode,uniqueDurations,uniqueMidis,chosenKey,keyMode), transcribeButton, "clicked")
g[7:9,7:9] = transcribeButton

# Make instrument drop down menu
instrumentDropDown = GtkComboBoxText()
instrumentChoices = ["Trumpet","Guitar","Violin","Cello","Flute"]
push!(GAccessor.style_context(instrumentDropDown),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(instrumentDropDown, :name, "bw")
for i in instrumentChoices
    push!(instrumentDropDown,i)
end
set_gtk_property!(instrumentDropDown, :active, 0)
signal_connect(instrumentDropDown, "changed") do widget
    global instrument = Gtk.bytestring(GAccessor.active_text(instrumentDropDown))
end
g[1:3,6:7] = instrumentDropDown

# Make key drop down menu 
keyDropDown = GtkComboBoxText()
keyChoices = ["A","A#/Bb","B","C","C#/Db","D","D#/Eb","E","F","F#/Gb","G","G#/Ab"]
push!(GAccessor.style_context(keyDropDown),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(keyDropDown, :name, "bw")
for i in keyChoices
    push!(keyDropDown,i)
end
set_gtk_property!(keyDropDown, :active, 0)
signal_connect(keyDropDown, "changed") do widget
    global startingKey = Gtk.bytestring(GAccessor.active_text(keyDropDown))
end
g[4,5:6] = keyDropDown

finalKeyDropDown = GtkComboBoxText()
finalKeyChoices = ["A","A#/Bb","B","C","C#/Db","D","D#/Eb","E","F","F#/Gb","G","G#/Ab"]
push!(GAccessor.style_context(finalKeyDropDown),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(finalKeyDropDown, :name, "bw")
for i in finalKeyChoices
    push!(finalKeyDropDown,i)
end
set_gtk_property!(finalKeyDropDown, :active, 0)
signal_connect(finalKeyDropDown, "changed") do widget
    global chosenKey = Gtk.bytestring(GAccessor.active_text(finalKeyDropDown))
end
g[4,8:9] = finalKeyDropDown

# Make synthesizer button
synthButton = GtkButton("Synthesizer")
push!(GAccessor.style_context(synthButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(synthButton, :name, "bw")
signal_connect((w) -> synthFunc(), synthButton, "clicked")
g[7:9,1:2] = synthButton

# Make file chooser button
fileSelectionButton = GtkButton("Choose File")
push!(GAccessor.style_context(fileSelectionButton),GtkStyleProvider(buttonStyleThree),600)
set_gtk_property!(fileSelectionButton, :name, "bw")
signal_connect((w) -> fileFunc(file), fileSelectionButton, "clicked")
g[4:6,1:2] = fileSelectionButton

# Make all labels
instrumentLabel = GtkLabel("Instrument")
push!(GAccessor.style_context(instrumentLabel), GtkStyleProvider(labelStyleOne), 600)
set_gtk_property!(instrumentLabel, :name, "menuLabels")
g[1:3,4:5] = instrumentLabel
keyLabel = GtkLabel("Starting Key:")
push!(GAccessor.style_context(keyLabel), GtkStyleProvider(labelStyleOne), 600)
set_gtk_property!(keyLabel, :name, "menuLabels")
g[4:6,4] = keyLabel
finalKeyLabel = GtkLabel("Desired Key:")
push!(GAccessor.style_context(finalKeyLabel), GtkStyleProvider(labelStyleOne), 600)
set_gtk_property!(finalKeyLabel, :name, "menuLabels")
g[4:6,7] = finalKeyLabel
fileLabel = GtkLabel("File Import:")
push!(GAccessor.style_context(fileLabel), GtkStyleProvider(labelStyleOne), 600)
set_gtk_property!(fileLabel, :name, "menuLabels")
g[1:3,1:2] = fileLabel
spaceLabel = GtkLabel("__________________________________________________________________________________________________________________________________________________")
g[1:9,3] = spaceLabel

win = GtkWindow("Transcriber Menu", 900, 390) # 800x304 pixel window for all the buttons
push!(GAccessor.style_context(win),GtkStyleProvider(backgroundStyle),600)
set_gtk_property!(win, :name, "p")
push!(win, g) # put button grid into the window
showall(win); # display the window full of buttons

# Function to determine the mode of the key
function keyTypes(keyType)
    global startingMode = keyType
    if keyType == "Minor"
        push!(GAccessor.style_context(minorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(minorButton, :name, "wa")
        push!(GAccessor.style_context(majorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(majorButton, :name, "bw")
    else
        push!(GAccessor.style_context(majorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(majorButton, :name, "wa")
        push!(GAccessor.style_context(minorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(minorButton, :name, "bw")
    end
end

function keyFunc(keyType)
    global keyMode = keyType
    if keyType == "Minor"
        push!(GAccessor.style_context(finalMinorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(finalMinorButton, :name, "wa")
        push!(GAccessor.style_context(finalMajorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(finalMajorButton, :name, "bw")
    else
        push!(GAccessor.style_context(finalMajorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(finalMajorButton, :name, "wa")
        push!(GAccessor.style_context(finalMinorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(finalMinorButton, :name, "bw")
    end
end

# Function that plays back the song
function playbackFunc(song,S)
    soundsc(song,S)
end

function transcribeFunc(chosenClef,startingKey,startingMode,uniqueDurations,uniqueMidis,chosenKey,keyMode)
    #=for i in 1:length(keyChoices)
        if keyChoices[i] == startingKey
            global startingKeyIndex = i
        end
    end
    for i in 1:length(keyChoices)
        if keyChoices[i] == chosenKey
            global chosenKeyIndex = i
        end
    end
    keyDifference = chosenKeyIndex - startingKeyIndex
    for i in 1:length(uniqueMidis)
        uniqueMidis[i] -= keyDifference
    end
    possibleDurations = [16 8 4 2 1]

    finalMidis = Float64[]
    finalDurations = Float64[]
    finalColors = []
    plotPitches = Float64[]

    function convertDurations(uniqueDurations, possibleDurations, uniqueMidis)
        for i in 1:length(uniqueMidis)
            duration = uniqueDurations[i]
            possibleDurationIndex = 1
            while duration > 0
                if duration >= possibleDurations[possibleDurationIndex]
                    push!(finalMidis,uniqueMidis[i])
                    push!(finalDurations,possibleDurations[possibleDurationIndex])
                    duration -= possibleDurations[possibleDurationIndex]
                else
                    possibleDurationIndex += 1
                end
            end
        end
    end

    convertDurations(uniqueDurations,possibleDurations,uniqueMidis)=#


    plotPitches = [1.; 1.5; 2.75; 1.25; 1.5; 1.25; 3.5; 3.5; 2.75; 3.; 4.; 4.5; 2.5; 2.5; 2.0;]
    #=for i in 1:length(finalMidis)
        push!(plotPitches, finalMidis[i] - 63)
    end=#
    default(markerstrokecolor = :auto, label = "")
    p1 = plot(plotPitches, line = :stem, marker = :circle, markersize = 10, color = :black)
    plot!(size = (800, 200)) # size of plot
    plot!(widen = true) # try not to cut off the markers
    plot!(xticks = [], ylims = (-0.7, 4.7)) # for staff
    yticks!(0:4, ["E", "G", "B", "D", "F"]) # helpful labels for staff lines
    plot!(yforeground_color_grid = :blue) # blue staff, just for fun
    plot!(foreground_color_border = :white) # make border "invisible"
    plot!(gridlinewidth = 1.5) # try commenting out each of these to see what they do!!!!
    plot!(gridalpha = 0.9) # make grid lines more visible
    savefig(p1,"music.png")
end

# Function that determines the clef 
function clefFunc(clefChoice)
    global chosenClef = clefChoice
    if clefChoice == "Multiple Clefs"
        push!(GAccessor.style_context(multiClefButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(multiClefButton, :name, "wa")
        push!(GAccessor.style_context(oneClefButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(oneClefButton, :name, "bw")
    else
        push!(GAccessor.style_context(oneClefButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(oneClefButton, :name, "wa")
        push!(GAccessor.style_context(multiClefButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(multiClefButton, :name, "bw")
    end
end

# Function that chooses the file
function fileFunc(file)
    global file = open_dialog("Choose File", GtkNullContainer(), ("*.wav",))
    push!(GAccessor.style_context(fileSelectionButton),GtkStyleProvider(buttonStyleTwo),600)
    set_gtk_property!(fileSelectionButton, :name, "wa")

    #=function autocorrelate(a)
        autocorr = real(ifft(abs2.(fft([a; zeros(length(a))])))) / sum(abs2, a) # Formula for autocorrelation
        halfwayPoint = convert(Int64, floor(size(autocorr)[1] / 2)) # Finds the halfway point of autocorr
        autocorr = autocorr[1:halfwayPoint] # Removes mirror image
        return autocorr
    end
    
    function createsnippet(entirewav, sampleNum)
        songsize = size(entirewav)[1]
        if(sampleNum < windowSize && songsize - sampleNum < windowSize)
            return entirewav
        end
        if (sampleNum < windowSize)
            return entirewav[1:(sampleNum+windowSize)]
        end
        if (songsize - sampleNum < windowSize)
            return entirewav[(sampleNum-windowSize):end]
        end
        return entirewav[(sampleNum-windowSize+1):(sampleNum+windowSize)]
    end
    
    function findPeak(autocorrelated)
        negativeVec = autocorrelated .< 0
        #print(negativeVec)
        zeroIndex = findnext(==(true), negativeVec, 1)
        #zeroIndex = 1
        foundIndex = false
        threshold = 0.99
        nextIndex = 1
        while(!foundIndex)
            threshVec = autocorrelated .> threshold
            #print(zeroIndex)
            nextIndex = findnext(==(true), threshVec, zeroIndex)
            if(isnothing(nextIndex))
                threshold = threshold - 0.05
            else
                foundIndex = true
            end
        end
        value = autocorrelated[nextIndex]
        lessVec = autocorrelated .< value
        farNextIndex = findnext(==(true), lessVec, nextIndex)
        if(isnothing(farNextIndex))
            farNextIndex = nextIndex
        end
        #print(nextIndex)
        #print(farNextIndex)
        #print("Stop")
        #peakValue = autocorrelated[convert(Int64, round(0.5 * (nextIndex + farNextIndex)))]
        #return peakValue
        return convert(Int64, round(0.5 * (nextIndex + farNextIndex))) - 1
    end
    
    function convert2Freq(peakVal, S)
        freq = S / peakVal
        freq = round(freq, digits=2)
        #print(freq)
        #print(peakVal)
        return freq
    end
    
    function convert2midi(freq)
        midi = 12 * log2(freq / 440) + 69
        midi = convert(Int64,round(midi))
        #print(midi)
        return midi
    end
    
    function logNoteOccurences(midiVec)
        for i in 1:size(midiVec)[1]
            if(convert(Int64, trunc(midiVec[i])) == 202 || convert(Int64, trunc(midiVec[i])) == 203)
                midiVec[i] = -1
                continue
            end
            index = mod((midiVec[i] - 69), 14) + 1
            noteOccurences[index] += 1
        end
        for i in 1:14
            notePercentages[i] = noteOccurences[i] / size(midiVec)[1]
        end
    end
        
    function initializeVariables()
        global x, S = wavread(file);
        global x = vec(x)
    
        global windowSize = convert(Int64, 2 * floor(150 * S / 8192))
        global freqVec = []
        global midiVec = []
        global noteOccurences = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        global notePercentages = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    end
    
    function runTranscription()
        initializeVariables()
        createEnvelope()
        getFrequencies()
        returnMidis()
        #print(notePercentages)
        #print(freqVec)
        #return plot(midiVec, marker=:circle, legend=:topleft)
        fixDurations()
    end
    
    function getFrequencies()
        for i in 1:size(x)[1]
            if(i % windowSize != 0)
                continue
            end
            if(i < windowSize+1)
                continue
            end
            global a = createsnippet(x, i)
            global autocorr = autocorrelate(a)
            #print(autocorr)
            if(!checkRest(i))
                peakVal = findPeak(autocorr)
                freq = convert2Freq(peakVal, S)
                push!(freqVec, freq)
            else
                push!(freqVec, 1000000)
            end
        end
    end
    
    #autocorr = autocorr[1:150]
    #print(size(a))
    #plot(autocorr, marker=:circle)
    #print(autocorr)
    
    #plot(freqVec, marker=:circle)
    
    function returnMidis()   
        for   i in 1:size(freqVec)[1]
             push!(midiVec, convert2midi(freqVec[i]))
        end
        removeBorderMidis()
        midiVec[size(midiVec)[1]] = midiVec[size(midiVec)[1]-1]
        logNoteOccurences(midiVec)
    end
    
    function removeBorderMidis()
        for i in 1:size(midiVec)[1]
            if(i == 1 || i == size(midiVec)[1])
                continue
            end
            if(midiVec[i] != midiVec[i-1] && midiVec[i]!= midiVec[i+1])
                midiVec[i] = midiVec[i-1]
            end
        end
    end
    
    function createEnvelope(h::Int = convert(Int64, round(windowSize * 0.5)))
        z = abs.(x)
        global envelope = [zeros(h); [sum(z[(n-h):(n+h)]) / (2h+1) for n in (h+1):(length(z)-h)]; zeros(h)]
    end
    
    function checkRest(i) 
        if(envelope[i] < 0.005)
            return true
        else
            return false
        end
    end
    
    function fixDurations()
        getRawDurations()
        convertDurations()
    end
    
    function getRawDurations()
        uniqueMidis = []
        uniqueDurations = []
        global currentCount = 1
        for i in 1:size(midiVec)[1]
            if(i == 1)
                continue
            end
            if(midiVec[i] == midiVec[i-1])
                global currentCount += 1
                continue
            else
                push!(uniqueMidis, midiVec[i-1])
                push!(uniqueDurations, currentCount)
                global currentCount = 1
            end
        end
    end
    
    function convertDurations()
        minDur = minimum(uniqueDurations)
        uniqueDurations ./ minDur
        for i in 1:size(uniqueDurations)[1]
            convert(Int64, uniqueDurations[i])
            #COMMENT OUT LATER, HARD CODE FIX FOR BUG
            if(uniqueMidis[i] < 70)
                uniqueMidis[i] = 0
            end
        end
    end
    
    runTranscription() =#

    notePercentages = [0. 13.59 0.7 15.85 10.1 1.57 18.64 0. 10.45 0. 5.57 23.87]

    for i in 1:size(database)[1]
        sum = 0.
        notePercent = Float64[]
        possibleKeyNotes = Float64[]
        possibleKey,mode = database[i,1:2]
        for j in 1:12
            note = database[i,j+2]
            append!(notePercent, note)
        end
        for k in 1:length(notePercent)
            if notePercent[k] == 0
                append!(possibleKeyNotes, 0.00)
            else
                percentError = abs(notePercent[k] - notePercentages[k]) / notePercent[k]
                append!(possibleKeyNotes, percentError)
            end
        end
        for l in 1:length(possibleKeyNotes)
            sum += possibleKeyNotes[l]
        end
        possiblePercentError = sum / length(possibleKeyNotes)
        if possiblePercentError < finalPercentError
            global startingKey = possibleKey
            global startingMode = mode
            global finalPercentError = possiblePercentError
        end
    end
    for m in 1:length(keyChoices)
        if startingKey == keyChoices[m]
            Gtk.@sigatom begin
                set_gtk_property!(keyDropDown, :active, m-1)
            end
        end
    end
    if startingMode == "Major"
        push!(GAccessor.style_context(majorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(majorButton, :name, "wa")
        push!(GAccessor.style_context(minorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(minorButton, :name, "bw")
    else
        push!(GAccessor.style_context(minorButton),GtkStyleProvider(buttonStyleTwo),600)
        set_gtk_property!(minorButton, :name, "wa")
        push!(GAccessor.style_context(majorButton),GtkStyleProvider(buttonStyleThree),600)
        set_gtk_property!(majorButton, :name, "bw")
    end
end

function synthFunc()
    
    G = GtkGrid() # initialize a grid to hold buttons
    set_gtk_property!(G, :row_spacing, 5) # gaps between buttons
    set_gtk_property!(G, :column_spacing, 5)
    set_gtk_property!(G, :margin_left, 5)
    set_gtk_property!(G, :margin_right, 5)
    set_gtk_property!(G, :margin_top, 5)
    set_gtk_property!(G, :margin_bottom, 5)
    set_gtk_property!(G, :row_homogeneous, true) # stretch with window resize
    set_gtk_property!(G, :column_homogeneous, true)

    white = ["G" 67; "A" 69; "B" 71; "C" 72; "D" 74; "E" 76; "F" 77; "G" 79]
    black = ["Ab/G#" 68 3; "Bb/A#" 70 6; "Db/C#" 73 12; "Eb/D#" 75 15; "Gb/F#" 78 21]
    
    for i in 1:5
        key, midi, placement = black[i,1:3]
        accidentalKey = GtkButton(key)
        push!(GAccessor.style_context(accidentalKey),GtkStyleProvider(buttonStyleFour),600)
        set_gtk_property!(accidentalKey, :name, "black")
        signal_connect((w) -> playNote(midi, song, noteLength, octave, tempo), accidentalKey, "clicked")
        G[placement:placement+1,3:6] = accidentalKey
    end

    for i in 1:8
        key, midi = white[i,1:2]
        naturalKey = GtkButton(key)
        push!(GAccessor.style_context(naturalKey),GtkStyleProvider(buttonStyleFive),600)
        set_gtk_property!(naturalKey, :name, "white")
        signal_connect((w) -> playNote(midi, song, noteLength, octave, tempo), naturalKey, "clicked")
        G[(1:3).+3*(i-1),3:9] = naturalKey
    end

    octaveUp = GtkButton("Octave Up")
    push!(GAccessor.style_context(octaveUp),GtkStyleProvider(buttonStyleTwo),600)
    set_gtk_property!(octaveUp, :name, "wa")
    signal_connect((w) -> octaveUpFunc(octave), octaveUp, "clicked")
    G[1:3,1:2] = octaveUp

    octaveDown = GtkButton("Octave Down")
    push!(GAccessor.style_context(octaveDown),GtkStyleProvider(buttonStyleTwo),600)
    set_gtk_property!(octaveDown, :name, "wa")
    signal_connect((w) -> octaveDownFunc(octave), octaveDown, "clicked")
    G[4:6,1:2] = octaveDown

    restButton = GtkButton("Rest")
    push!(GAccessor.style_context(restButton),GtkStyleProvider(buttonStyleThree),600)
    set_gtk_property!(restButton, :name, "bw")
    signal_connect((w) -> restFunc(tempo, song, noteLength), restButton, "clicked")
    G[7:12,1:2] = restButton

    noteLengthDropDown = GtkComboBoxText()
    noteLengthOptions = ["Whole", "Half", "Quarter", "Eighth", "Sixteenth"]
    push!(GAccessor.style_context(noteLengthDropDown),GtkStyleProvider(buttonStyleThree),600)
    set_gtk_property!(noteLengthDropDown, :name, "bw")
    for i in 1:length(noteLengthOptions)
        push!(noteLengthDropDown, noteLengthOptions[i])
    end
    set_gtk_property!(noteLengthDropDown, :active, 0)
    signal_connect(noteLengthDropDown,"changed") do widget
        global noteLength = Gtk.bytestring(GAccessor.active_text(noteLengthDropDown))
    end
    G[13:18,1:2] = noteLengthDropDown

    tempoSlider = GtkScale(false,60:200)
    signal_connect(tempoSlider,"value_changed") do widget
        global tempo = GAccessor.value(tempoSlider)
    end
    G[19:24,1:2] = tempoSlider

    undoButton = GtkButton("Undo")
    push!(GAccessor.style_context(undoButton),GtkStyleProvider(buttonStyleTwo),600)
    set_gtk_property!(undoButton, :name, "wa")
    signal_connect((w) -> undoFunc(tempo, song, noteLength), undoButton, "clicked")
    G[1:3,10:11] = undoButton

    clearButton = GtkButton("Clear")
    push!(GAccessor.style_context(clearButton),GtkStyleProvider(buttonStyleTwo),600)
    set_gtk_property!(clearButton, :name, "wa")
    signal_connect((w) -> clearFunc(song), clearButton, "clicked")
    G[4:6,10:11] = clearButton

    hearButton = GtkButton("Playback")
    push!(GAccessor.style_context(hearButton),GtkStyleProvider(buttonStyleThree),600)
    set_gtk_property!(hearButton, :name, "bw")
    signal_connect((w) -> hearFunc(song), hearButton, "clicked")
    G[7:9,10:11] = hearButton

    exportButton = GtkButton("Export")
    push!(GAccessor.style_context(exportButton),GtkStyleProvider(buttonStyleOne),600)
    set_gtk_property!(exportButton, :name, "wg")
    signal_connect((w) -> exportFunc(song), exportButton, "clicked")
    G[10:24, 10:11] = exportButton

    window = GtkWindow("Synthesizer Menu", 600, 600) # 600x600 pixel window for all the buttons
    push!(GAccessor.style_context(win),GtkStyleProvider(backgroundStyle),600)
    set_gtk_property!(win, :name, "p")
    push!(window, G) # put button grid into the window
    showall(window); # display the window full of buttons

    function octaveUpFunc(octave)
        if octave < 3
            global octave += 1
        end
    end

    function octaveDownFunc(octave)
        if octave > -2    
            global octave -= 1
        end
    end

    function playNote(midi, song, noteLength, octave, tempo)
        midi = midi + (12 * octave)
        freq = 440 * 2^((midi - 69) / 12)
        x = cos.(2pi * (1:11025) * freq / 44100)
        soundsc(x, 44100)

        if noteLength == "Whole"
            n = ((60 / tempo) * 4) * 44100
            y = cos.(2pi * (1:floor(n)) * freq / 44100)
            zeroes = zeros(1,100)
            global song = append!(song,y)
            global song = append!(song,zeroes)
        elseif noteLength == "Half"
            n = ((60 / tempo) * 2) * 44100
            y = cos.(2pi * (1:floor(n)) * freq / 44100)
            zeroes = zeros(1,100)
            global song = append!(song,y)
            global song = append!(song,zeroes)
        elseif noteLength == "Quarter"
            n = (60 / tempo) * 44100
            y = cos.(2pi * (1:floor(n)) * freq / 44100)
            zeroes = zeros(1,100)
            global song = append!(song,y)
            global song = append!(song,zeroes)
        elseif noteLength == "Eighth"
            n = ((60 / tempo) / 2) * 44100
            y = cos.(2pi * (1:floor(n)) * freq / 44100)
            zeroes = zeros(1,100)
            global song = append!(song,y)
            global song = append!(song,zeroes)
        elseif noteLength == "Sixteenth"
            n = ((60 / tempo) / 4) * 44100
            y = cos.(2pi * (1:floor(n)) * freq / 44100)
            zeroes = zeros(1,100)
            global song = append!(song,y)
            global song = append!(song,zeroes)
        end
    end

    function restFunc(tempo, song, noteLength)
        if noteLength == "Whole"
            n = (((60 / tempo) * 4) * 44100) + 100
            y = zeros(Int64(floor(n)))
            global song = append!(song,y)
        elseif noteLength == "Half"
            n = (((60 / tempo) * 2) * 44100) + 100
            y = zeros(Int64(floor(n)))
            global song = append!(song,y)
        elseif noteLength == "Quarter"
            n = ((60 / tempo) * 44100) + 100
            y = zeros(Int64(floor(n)))
            global song = append!(song,y)
        elseif noteLength == "Eighth"
            n = (((60 / tempo) / 2) * 44100) + 100
            y = zeros(Int64(floor(n)))
            global song = append!(song,y)
        elseif noteLength == "Sixteenth"
            n = (((60 / tempo) / 4) * 44100) + 100
            y = zeros(Int64(floor(n)))
            global song = append!(song,y)
        end
    end

    function clearFunc(song)
        global song = Float64[]
    end

    function undoFunc(tempo, song, noteLength)
        if noteLength == "Whole"
            n = (((60 / tempo) * 4) * 44100) + 100
            global song = song[1:end-Int64(floor(n))]
        elseif noteLength == "Half"
            n = (((60 / tempo) * 2) * 44100) + 100
            global song = song[1:end-Int64(floor(n))]
        elseif noteLength == "Quarter"
            n = ((60 / tempo) * 44100) + 100
            global song = song[1:end-Int64(floor(n))]
        elseif noteLength == "Eighth"
            n = (((60 / tempo) / 2) * 44100) + 100
            global song = song[1:end-Int64(floor(n))]
        elseif noteLength == "Sixteenth"
            n = (((60 / tempo) / 4) * 44100) + 100
            global song = song[1:end-Int64(floor(n))]
        end
    end

    function hearFunc(song)
        soundsc(song,44100)
    end

    function exportFunc(song)
        wavwrite(song,"song.wav", Fs = 44100)
    end
end
