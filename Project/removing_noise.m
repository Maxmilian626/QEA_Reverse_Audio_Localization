%load/read signal data
load Data/snap270L %y1
load Data/snap270R%y2
% [test_sound, fs] = audioread('PanamaWeddingUma.wav');

%initialize variables
signal_period = 1400000:1600000; %grab arbitrary sound bite
test_soundL = test_sound(signal_period,1);
test_soundR = test_sound(signal_period,2);
impulseL = y1;
impulseR = y2;

%line up start of impulses (for 0 and 180, or calibration)
[max_soundL, indexL] = max(impulseL);
[max_soundR, indexR] = max(impulseR);
% diff = indexL - indexR
% diff = max_soundR - max_soundL
time_before_index = 500; %so we don't miss any values
length_of_sound = 7000; %so they're equal length

%want to keep any relative delay between the impulses
%so we'll take the earlier max index and use that for both
if indexL < indexR
    start_index = indexL - time_before_index;
else % covers indexR =< indexL conditions
    start_index = indexR - time_before_index;
end

%trim signal to isolate impulses
soundR = impulseR(start_index:start_index + length_of_sound);
soundL = impulseL(start_index:start_index + length_of_sound);

%convolute input signal with impulse responses
convL = conv(test_soundL, soundL);
convR = conv(test_soundR, soundR);

%trim longer signal to length of shorter signal
if length(convL) < length(convR)
    stereoR = convR(1:length(convL));
    stereoL = convL;
else
    stereoR = convR;
    stereoL = convL(1:length(convR));
end

diff = mean(abs(stereoR)) - mean(abs(stereoL))

%write signals to a two-channel wav file
stereo_sound = [stereoL, stereoR];
% audiowrite('stereo_test0.wav', stereo_sound, fs);

% figure
% plot(soundR,'r')
% hold on
% plot(soundL,'b')

