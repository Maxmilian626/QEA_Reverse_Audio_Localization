angle = [0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320];
%+ means R is greater by that much, - means L is greater by that much
% amp_diff = [.0153 .3586 .348 .3574 -.1529 -.3697 -.2980 -.2049];
% time_diff = [-2 17 33 22 -1 -24 -86 -29];
amp_diff = [.0736 .0638 .303 .3661 .3685 .225 .3723 .4723 .3273 .2381 .0068 .301 .1881 .3621 .2581 .3774 .3516];
time_diff = [2 14 14 80 21 0 600 282 755 11 -2 -1156 -18 -55 -757 -21 -16];
data_step_size = 20; %step between sample angles

%create impulse matrix
%     [y1, fs] = audioread('gwyn2_0.wav');
%     [y2, fs] = audioread('gwyn2_20.wav'); 
%     [y3, fs] = audioread('gwyn2_40.wav'); 
%     [y4, fs]  = audioread('gwyn2_60.wav');
%     [y5, fs] = audioread('gwyn2_80.wav');
%     [y6, fs] = audioread('gwyn2_100.wav');
%     [y7, fs] = audioread('gwyn2_120.wav');
%     [y8, fs] = audioread('gwyn2_140.wav');
%     [y9, fs] = audioread('gwyn2_160.wav');
%     [y10, fs] = audioread('gwyn2_180.wav');
%     [y11, fs] = audioread('gwyn2_200.wav');
%     [y12, fs] = audioread('gwyn2_220.wav');
%     [y13, fs] = audioread('gwyn2_240.wav');
%     [y14, fs] = audioread('gwyn2_260.wav');
%     [y15, fs] = audioread('gwyn2_280.wav');
%     [y16, fs] = audioread('gwyn2_300.wav');
%     [y17, fs] = audioread('gwyn2_320.wav');
%     l = length(y9);
% impulse_matrix = [y1(1:l,:), y2(1:l,:), y3(1:l,:), y4(1:l,:), y5(1:l,:), y6(1:l,:), y7(1:l,:), y8(1:l,:), y9(1:l,:), y10(1:l,:), y11(1:l,:), y12(1:l,:), y13(1:l,:), y14(1:l,:), y15(1:l,:), y16(1:l,:), y17(1:l,:)];

%desired sound sample and angle we want to simulate sound from
[desired_sound, fs] = audioread('walking.wav');
% desired_soundL = desired_sound(10000:15000,1);
% desired_soundR = desired_soundL; %no discernible difference between channel 1 and 2
% desired_soundR = desired_sound(:,2);
% desired_angle  = 20;
f = 'walking_loop_5.wav';
loop_step = 5;

interval_num = ceil(360/loop_step + 1); %break into this many chunks, ceil to be conservative
interval_length = floor(length(desired_sound)/interval_num) - 100; %length of each interval, floor to be conservative
stereo_adjusted_sound = [0, 0]; %initialize empty 2 column matrix

for desired_angle = 1:loop_step:360
    current_step = ceil(desired_angle/loop_step);
    start = current_step*interval_length - interval_length + 1;
    stop = current_step*interval_length;
    desired_soundL = desired_sound(start:stop,2);
    desired_soundR = desired_soundL; %no discernible difference between channel 1 and 2

    %figure out the ear -- need to know this later when we change sound samples
    if desired_angle < 180
        ear = 0; %R
    else
        ear = 1; %L
    end
    
    %finds closest angle and next closest angle from list of angles
    %for which we collected data -- this lets us know what step interval
    %it's on (i.e. 0 - 45 or 135 - 180), which we need to find slope;
    %it also finds diff between closest angle and desired angle (so we
    %know how close it is to the closest angle) and creates a 
    %corresponding closest_sample vector which we'll manipulate
    for i = 1:length(angle)
        if abs(angle(i) - desired_angle) < ceil(data_step_size/2)
            closest_angle_diff = abs(angle(i) - desired_angle);
            closest_angle_index = i;
            closest_impulse = impulse_matrix(:,i*2-1:i*2);
        elseif abs(angle(i) - desired_angle) <= data_step_size
             next_closest_angle_index = i;
        end
    end

    %find slopes for the interval the angle is on
    amp_interval_slope = (amp_diff(closest_angle_index) - amp_diff(next_closest_angle_index))/data_step_size;
    time_interval_slope = (time_diff(closest_angle_index) - time_diff(next_closest_angle_index))/data_step_size;

    %multiply by angle diff to get right proportion -- how much of it
    %is the lower angle sample, how much is the upper angle sample
    amp_shift = amp_interval_slope * closest_angle_diff;
    time_shift = round(time_interval_slope * closest_angle_diff);

    %get indices of max amp for the L and R microphones
    soundL = closest_impulse(:,2);
    soundR = closest_impulse(:,1);
    [max_soundL, indexL] = max(soundL);
    [max_soundR, indexR] = max(soundR);

    %adjust amplitude and set up time delay
    time_before = 50;
    time_after = 100;
    if ear == 0 %if R, - slope should make R happen less ahead of L
        sound_amp_adjustedR = soundR * (1 + amp_shift);
        sound_amp_adjustedL = soundL;
        time_before_indexR = time_before + time_shift;
        time_after_indexR = time_after + time_shift; 
    else %if L, - slope should make R happen more ahead of L
        sound_amp_adjustedR = soundR;
        sound_amp_adjustedL = soundL * (1 + amp_shift);
        time_before_indexR = time_before - time_shift;
        time_after_indexR = time_after - time_shift;   
    end
    time_before_indexL = time_before;
    time_after_indexL = time_after;

    %implement time delay
    sound_adjustedL = sound_amp_adjustedL(indexL - time_before_indexL:indexL + time_after_indexL);
    sound_adjustedR = sound_amp_adjustedR(indexR - time_before_indexR:indexR + time_after_indexR);

    %convolve desired sound and manipulated impulse response
    conv_adjusted_soundL = conv(desired_soundL, sound_adjustedL,'valid');
    conv_adjusted_soundR = conv(desired_soundR, sound_adjustedR,'valid');

    %trim longer signal to length of shorter signal
    if length(conv_adjusted_soundL) < length(conv_adjusted_soundR)
        stereoR = conv_adjusted_soundR(1:length(conv_adjusted_soundL));
        stereoL = conv_adjusted_soundL;
    else
        stereoR = conv_adjusted_soundR;
        stereoL = conv_adjusted_soundL(1:length(conv_adjusted_soundR));
    end
    
%     hold on
%     plot(desired_soundR,'r')
%     plot(stereoR,'b')

%     stereoR = zeros(length(stereoR),1);
    stereo_adjusted_sound = [stereo_adjusted_sound; [stereoL, stereoR]];

end

    audiowrite(f, (stereo_adjusted_sound), fs);

