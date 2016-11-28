stereo_mic = audiorecorder(44100, 16, 2);
record(stereo_mic);
pause(3);
stop(stereo_mic);
y1 = getaudiodata(stereo_mic);
plot(y1);