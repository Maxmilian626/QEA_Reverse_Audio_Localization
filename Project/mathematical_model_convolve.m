[y, Fs] = audioread('PanamaWeddingUma.wav');
y = y(1400000:1600000);
RATE = Fs %typically 44100

angle = 90;
distance = 1;
mic_distance = .20; %Average human head is around 20 cm across.  

right_distance = sqrt(distance^2 + (mic_distance/2)^2 - 2*distance*(mic_distance/2)*cosd(angle));
left_distance = sqrt(distance^2 + (mic_distance/2)^2 - 2*distance*(mic_distance/2)*cosd(180-angle));

%Amplitude and delay calculations
if right_distance < left_distance
    left_amplitude = right_distance/left_distance;
    left_delay = (left_distance - right_distance)/343;
    delay_shift = int64(RATE * left_delay);
    
    leftY = circshift(y * left_amplitude, delay_shift);
    leftY(1:delay_shift) = 0;
    rightY = y;
elseif right_distance > left_distance
    right_amplitude = left_distance/right_distance;
    right_delay = (right_distance - left_distance)/343;
    delay_shift = int64(RATE * right_delay);
    
    rightY = circshift(y * right_amplitude, delay_shift);
    rightY(1:delay_shift) = 0;
    leftY = y;
else
    delay_shift = 0;
    leftY = y;
    rightY = y;
end

s = num2str(angle);
stereo_sound = transpose([leftY ; rightY]);
audiowrite(strcat('mathematical_model', s , '.wav'), stereo_sound, RATE)
    