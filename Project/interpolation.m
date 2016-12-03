%linearly interpolate between angles
%get angle
%take closest sound sample and adjust max amp and delay
%play

angle = [0 45 90 135 180 225 270 315];
%+ means R is greater by that much, - means L is greater by that much
amp_diff = [.0153 .3586 .348 .3574 -.1529 -.3697 -.2980 -.2049];
time_diff = [-2 17 33 22 -1 -24 -86 -29];
step_size = 45; %step between sample angles

%desired sound sample and angle we want to simulate sound from
[desired_sound, fs] = audioread('bee.wav');
% desired_soundL = desired_sound(10000:15000,1);
% desired_soundR = desired_soundL; %no discernible difference between channel 1 and 2
% desired_soundR = desired_sound(:,2);
% desired_angle  = 20;
f = 'bee_flying_loop.wav';
step = 30;

interval_num = ceil(360/step); %break into this many chunks, ceil to be conservative
interval_length = 55000/interval_num; %length of each interval
stereo_adjusted_sound = [0, 0]; %initialize empty 2 column matric

for desired_angle = 1:step:360
    current_step = ceil(desired_angle/step);
    start = current_step*interval_length - interval_length + 1;
    stop = current_step*interval_length;
    desired_soundL = desired_sound(start:stop,1);
    desired_soundR = desired_soundL; %no discernible difference between channel 1 and 2

    %figure out the ear -- need to know this later when we change sound samples
    if desired_angle < 180
        ear = 0; %R
    else
        ear = 1; %L
    end

    %create impulse matrix
    % [y1, fs] = audioread('uma_0.wav');
    % [y2, fs] = audioread('uma_45.wav'); 
    % [y3, fs] = audioread('uma_90.wav'); 
    % [y4, fs]  = audioread('uma_135.wav');
    % [y5, fs] = audioread('uma_180.wav');
    % [y6, fs] = audioread('uma_225.wav');
    % [y7, fs] = audioread('uma_270.wav');
    % [y8, fs] = audioread('uma_315.wav');
    % impulse_matrix = [y1 y2 y3 y4 y5 y6 y7 y8];

    %finds closest angle and next closest angle from list of angles
    %for which we collected data -- this lets us know what step interval
    %it's on (i.e. 0 - 45 or 135 - 180), which we need to find slope;
    %it also finds diff between closest angle and desired angle (so we
    %know how close it is to the closest angle) and creates a 
    %corresponding closest_sample vector which we'll manipulate
    for i = 1:length(angle)
        if abs(angle(i) - desired_angle) < ceil(step_size/2)
            closest_angle_diff = abs(angle(i) - desired_angle);
            closest_angle_index = i;
            closest_impulse = impulse_matrix(:,i*2-1:i*2);
        elseif abs(angle(i) - desired_angle) <= step_size
             next_closest_angle_index = i;
        end
    end

    %find slopes for the interval the angle is on
    amp_interval_slope = (amp_diff(closest_angle_index) - amp_diff(next_closest_angle_index))/step_size;
    time_interval_slope = (time_diff(closest_angle_index) - time_diff(next_closest_angle_index))/step_size;

    %multiply by angle diff to get right proportion -- how much of it
    %is the lower angle sample, how much is the upper angle sample
    amp_shift = amp_interval_slope * closest_angle_diff;
    time_shift = round(time_interval_slope * closest_angle_diff);

    %get indices of max amp for the L and R microphones
    soundL = closest_impulse(:,1);
    soundR = closest_impulse(:,2);
    [max_soundL, indexL] = max(soundL);
    [max_soundR, indexR] = max(soundR);

    %adjust amplitude and set up time delay
    if ear == 0 %if R, - slope should make R happen less ahead of L
        sound_amp_adjustedR = soundR * (1 + amp_shift);
        sound_amp_adjustedL = soundL;
        time_before_indexR = 500 - time_shift;
        time_after_indexR = 7000 - time_shift; 
    else %if L, - slope should make R happen more ahead of L
        sound_amp_adjustedR = soundR;
        sound_amp_adjustedL = soundL * (1 + amp_shift);
        time_before_indexR = 500 + time_shift;
        time_after_indexR = 7000 + time_shift;   
    end
    time_before_indexL = 500;
    time_after_indexL = 7000;

    %implement time delay
    sound_adjustedL = sound_amp_adjustedL(indexL - time_before_indexL:indexL + time_after_indexL);
    sound_adjustedR = sound_amp_adjustedR(indexR - time_before_indexR:indexR + time_after_indexR);

    %convolve desired sound and manipulated impulse response
    conv_adjusted_soundL = conv(desired_soundL, sound_adjustedL);
    conv_adjusted_soundR = conv(desired_soundR, sound_adjustedR);

    %trim longer signal to length of shorter signal
    if length(conv_adjusted_soundL) < length(conv_adjusted_soundR)
        stereoR = conv_adjusted_soundR(1:length(conv_adjusted_soundL));
        stereoL = conv_adjusted_soundL;
    else
        stereoR = conv_adjusted_soundR;
        stereoL = conv_adjusted_soundL(1:length(conv_adjusted_soundR));
    end

    stereo_adjusted_sound = [stereo_adjusted_sound; [stereoL, stereoR]];

end

    audiowrite(f, stereo_adjusted_sound, fs);







