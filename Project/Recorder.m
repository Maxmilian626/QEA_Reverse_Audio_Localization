stereo_mic = audiorecorder(44100, 16, 2);
record(stereo_mic);
pause(2);
stop(stereo_mic);
y1 = getaudiodata(stereo_mic);
audiowrite('gwyn_0.wav', y1, 44100)
plot(y1);