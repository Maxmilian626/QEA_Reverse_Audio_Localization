%one time thing -- convert from .wav to .mat and save in directory
% test_sound = audioread('proj_tone4.wav');
% save test_sound

% load test_sound
% load R0

output_fft = fftshift(fft(y2(1:length(test_sound))));
% plot(abs(output_fft),'r')
% xlabel('Frequency (Hz)')
% ylabel('Amplitude')
% title('FFT of Recorded Sound, Right Microphone')

input_fft = fftshift(fft(test_sound));
% figure
% plot(abs(input_fft),'b')
% xlabel('Frequency (Hz)')
% ylabel('Amplitude')
% title('FFT of Original Sound')

% frequency_response = output_fft/input_fft;
% plot(frequency_response)

w = logspace(1,2,200);
sys = [input_fft, output_fft];
[H, wout] = freqresp(sys);




