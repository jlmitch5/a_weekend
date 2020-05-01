--- another_evening ~ a braided environment
-- output 1 a slow, time-synced lfo
-- output 2 v/oct 1
-- output 3 a fast, time-synced lfo
-- output 4 v/oct 2
-- JF is connected via ii to crow

-- original patch notes:
-- for mangrove, warps and just friends to exist in
-- output 1 modulates mangrove and 3 sis for some flow
-- output 2 goes to warps pitch
-- output 3 modulates warps timbre to get some "plucks" coming through
-- output 4 goes to mangrove pitch
-- warps is a self-patched complex oscillator (channel 1 is on-board osc, aux out to in 2)
-- parallel process sound out through 3 sis -> delay -> reverb, and a more raw sound for the
-- bass to push through
-- delay and reverb for maximum vibes

-- update these to make new things appear
seq = { 0, 2, 7, 12, 16}
seq1mod = -7/12 
switch1Repeats = 4
seq2 = { 12, 9, 7, 5, 4, 0 }
seq2mod = 5/12
seq3 = { 2, 5, 9, 10 }
bassTimeMod = 5.465
jfMasterDetune = -5/24
level = 5
time = .625
a = .5
b = .5
c = .5
d = 3
e = 3
f = 3

-- leave these be (probably)
seq1modon = 0
step = 1
switch = 1
seq2modon = 0
step2 = 1
step3 = 1
bassStarted = 0

function sammie()
    if seq1modon == 1 then
        output[2].volts = seq[step]/12 + math.random(2, 3) + seq1mod
    else
        output[2].volts = seq[step]/12 + math.random(2)
    end
    
    step = ((step + math.random(0, 1)) % #seq) + 1
    if step == 1 then
        if bassStarted == 0 then
            metro[1]:start()
            bassStarted = bassStarted + 1
        end
        switch = (switch + 1) % switch1Repeats
        if switch == 1 then
            -- every 4 (or whatever switch1Repeats is) # of sequence repeats
            -- possibly turn on/off the +5 / -7 (or whatever) sequence
            -- transposition to keep things interesting
            seq1modon = math.random(0,1)
            seq2modon = math.random(0,1)
        end
    end
end

function monkey()
    if seq2modon == 1 then
        output[4].volts = seq2[step2]/12 + math.random(0,2) + seq2mod
    else
        output[4].volts = seq2[step2]/12 + math.random(0,3)
    end
    step2 = ((step2 + math.random(0, 1)) % #seq2) + 1
end

function albert()
    ii.jf.play_note( jfMasterDetune - 2 + seq3[step3 + 1]/12, 5)
    step3 = ((step3 + 1) % #seq3)
end

function init()
    output[1]( loop 
        { sammie
        , to(function() return level/a end, function() return time/b end)
        , monkey
        , to(function() return -level/c end, function() return time/a end)
        , sammie
        , to(function() return level/b end, function() return time/c end)
        , monkey
        , to(function() return -level/a end, function() return time/b end)
        , sammie
        , to(function() return level/c end, function() return time/a end)
        , monkey
        , to(function() return -level/b end, function() return time/c end)
        }
    )

    output[2].slew = 0

    output[3]( loop
        { monkey
        , to(function() return level/d end, function() return time/e end)
        , sammie
        , to(function() return -level/f end, function() return time/d end)
        , monkey
        , to(function() return level/e end, function() return time/f end)
        , sammie
        , to(function() return -level/d end, function() return time/e end)
        , monkey
        , to(function() return level/f end, function() return time/d end)
        , sammie
        , to(function() return -level/e end, function() return time/f end)
        }
    )

    output[4].slew = 0

    metro[1].event = albert
    metro[1].time  = time * bassTimeMod

    ii.pullup(true)
    ii.jf.mode(1)
end
