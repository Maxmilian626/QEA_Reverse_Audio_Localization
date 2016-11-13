%load/read signal data
load Data/snap135L %y1
load Data/snap135R%y2
[test_sound, fs] = audioread('PanamaWeddingUma.wav');

%initialize variables
soundL = y1;
soundR = y2;
signal_period = 1400000:1600000;
test_soundL = test_sound(signal_period,1);
test_soundR = test_sound(signal_period,2);

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
audiowrite('stereo_test_135.wav', stereo_sound, fs);
% info = audioinfo('stereo_test.wav')
% stereo_test_sound = [test_soundL, test_soundR];
% audiowrite('stereo_real.wav', stereo_test_sound, fs);

% plot(stereoL,'b')
% hold on
% plot(test_soundL,'r')
% figure
% plot(stereoR,'m')
% hold on
% plot(test_soundR,'g')
