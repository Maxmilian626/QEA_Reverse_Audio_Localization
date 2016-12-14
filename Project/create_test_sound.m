%create test sound

seconds_long = 20;
fs = 10000;
tone = 40000; %higher # --> higher pitched sound
time_length = linspace(1, tone, fs*seconds_long); 
wave = sin(time_length);
audiowrite('test.wav', wave, fs);