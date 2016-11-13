%load/read signal data
load Data/snap270L %y1
load Data/snap270R%y2
% [test_sound, fs] = audioread('PanamaWeddingUma.wav');

%initialize variables
signal_period = 1400000:1600000;
test_soundL = test_sound(signal_period,1);
test_soundR = test_sound(signal_period,2);

%line up start of impulses (for 0 and 180, or calibration)
[max_soundL, indexL] = max(soundL);
[max_soundR, indexR] = max(soundR);
time_before_index = 500; %so we don't miss any values
length_of_sound = 7000; %so they're equal length

soundR = soundR(indexR - time_before_index:indexR + length_of_sound);
soundL = soundL(indexL - time_before_index:indexL + length_of_sound);

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

%write signals to a two-channel wav file
stereo_sound = [stereoL, stereoR];
% audiowrite('stereo_cleaned_270.wav', stereo_sound, fs);
% info = audioinfo('stereo_test.wav')
% stereo_test_sound = [test_soundL, test_soundR];
% audiowrite('stereo_real.wav', stereo_test_sound, fs);

figure
plot(test_soundL,'r')
% plot(test_soundR,'g')


