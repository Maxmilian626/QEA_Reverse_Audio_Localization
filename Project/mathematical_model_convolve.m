[y, Fs] = audioread('PanamaWeddingUma.wav')
RATE = Fs %typically 44100

angle = 0;
distance = 1;
mic_distance = .15;

right_distance = sqrt(distance^2 + (mic_distance/2)^2 - 2*distance*(mic_distance/2)*cosd(angle));
left_distance = sqrt(distance^2 + (mic_distance/2)^2 - 2*distance*(mic_distance/2)*cosd(180-angle));

%Amplitude and delay calculations
if right_distance < left_distance
    left_amplitude = right_distance/left_distance;
    left_delay = (right_distance - left_distance)/343;
    delay_shift = int64(RATE * left_delay);
    
    leftY = circshift(y * left_amplitude, delay_shift);
    leftY(1:delay_shift, 1:2) = 0;
    rightY = y;
elseif right_distance > left_distance
    right_amplitude = left_distance/right_distance;
    right_delay = (left_distance - right_distance)/343;
    delay_shift = int64(RATE * right_delay);
    
    rightY = circshift(y * right_amplitude, delay_shift);
    rightY(1:delay_shift, 1:2) = 0;
    leftY = y;
else
    delay_shift = 0
end

stereo_sound = [leftY, rightY];
audiowrite('mathematical_model.wav', stereo_sound, RATE) 
    