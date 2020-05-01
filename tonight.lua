--- tonight ~ a wandering and loose(/lost?) voice
-- output 1 control voltage 1
-- output 2 v/oct 1

-- original patch notes:
-- for mangrove
-- output 1 goes to mangrove's formant attenuated to taste (constant wave mode)
-- output 2 goes to mangrove' pitch
-- mangrove's out to delay and reverb for maximum vibes

-- update these to make new things appear
seq = { 0, 4, 5, 7, 9 }
switchRepeats = 2
level = 5
time = 1.3
varDivisor = 10

-- leave these be (probably)
step = 1
switch = 1
a = math.random(1,varDivisor)
b = math.random(1,varDivisor)
c = math.random(1,varDivisor)

function toby()
    output[2].volts = seq[step]/12
    output[2].slew = math.random(0,2)/100
    -- advances sequencer every 1 or 2 steps
    step = ((step + math.random(0, 1)) % #seq) + 1 
    if step == 1 then
        switch = (switch + 1) % switchRepeats
        if switch == 1 then
            -- these are updated to change the timing of the asl stages
            a = math.random(1,varDivisor)
            b = math.random(1,varDivisor)
            c = math.random(1,varDivisor)
        end
    end
end

function init()
    output[1]( loop
        { toby
        , to(function() return level/a end, function() return time/b end)
        , toby
        , to(function() return -level/c end, function() return time/a end)
        , toby
        , to(function() return level/b end, function() return time/c end)
        , toby
        , to(function() return -level/a end, function() return time/b end)
        }
    )
end
