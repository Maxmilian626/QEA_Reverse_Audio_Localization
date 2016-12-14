angle = [0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320];
%+ means R is greater by that much, - means L is greater by that much
% amp_diff = [.0153 .3586 .348 .3574 -.1529 -.3697 -.2980 -.2049];
% time_diff = [-2 17 33 22 -1 -24 -86 -29];
amp_diff = [.0736 .0638 .303 .3661 .3685 .225 .3723 .4723 .3273 .2381 .0068 .301 .1881 .3621 .2581 .3774 .3516];
time_diff = [2 14 14 80 21 0 600 282 755 11 -2 -1156 -18 -55 -757 -21 -16];
data_step_size = 20; %step between sample angles

%desired sound sample and angle we want to simulate sound from
[desired_sound, fs] = audioread('bee.wav');
f = 'bee_loop_5.wav';
loop_step = 5;

interval_num = ceil(360/loop_step/2 + 1); %break into this many chunks, ceil to be conservative
interval_length = floor(length(desired_sound)/interval_num) - 100; %length of each interval, floor to be conservative
half_interval_length = interval_length/2;
stereo_adjusted_sound = [0, 0]; %initialize empty 2 column matric
which = 2;
current_step = 1;

for desired_angle = 1:loop_step:360
%     current_step = ceil(desired_angle/loop_step)
    if which == 1 %go halfway back -- for each step, start with this
        start = current_step*interval_length - interval_length + 1 - half_interval_length;
        stop = current_step*interval_length - half_interval_length;
        which = 2;
    else %take normal chunk -- move on to next step after this (1 comes first)
        start = current_step*interval_length - interval_length + 1;
        stop = current_step*interval_length;
        which = 1;
        current_step = current_step + 1;
    end
    disp(['start: ',num2str(start)])
    disp(['stop: ',num2str(stop)])

    desired_soundL = desired_sound(start:stop,2);
%     desired_soundL = desired_sound(start:stop);
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
             next_closest_impulse = impulse_matrix(:,i*2-1:i*2);
        end
    end

    %find slopes for the interval the angle is on
    amp_interval_slope = (amp_diff(closest_angle_index) - amp_diff(next_closest_angle_index))/data_step_size;
    time_interval_slope = (time_diff(closest_angle_index) - time_diff(next_closest_angle_index))/data_step_size;

    %multiply by angle diff to get right proportion -- how much of it
    %is the lower angle sample, how much is the upper angle sample
    amp_shift = amp_interval_slope * closest_angle_diff;
    closest_time_shift = round(time_interval_slope * closest_angle_diff);

    %get indices of max amp for the L and R microphones
    closest_soundL = closest_impulse(10000:end,2); %account for spike at beginning
    closest_soundR = closest_impulse(10000:end,1); %account for spike at beginning
    [closest_max_soundL, closest_indexL] = max(closest_soundL);
    [closest_max_soundR, closest_indexR] = max(closest_soundR);

    %adjust amplitude and set up time delay
    time_before = 50;
    time_after = 100;
    closest_proportion = (data_step_size - closest_angle_diff) / data_step_size;
    next_closest_proportion = closest_angle_diff/data_step_size;
    if ear == 0 %if R, - slope should make R happen less ahead of L
        closest_time_before_indexR = time_before - closest_time_shift;
        closest_time_after_indexR = time_after - closest_time_shift;
    else %if L, - slope should make R happen more ahead of L
        closest_time_before_indexR = time_before + closest_time_shift;
        closest_time_after_indexR = time_after + closest_time_shift;
    end
    closest_time_before_indexL = time_before;
    closest_time_after_indexL = time_after;
    
    %need to start at same index to capture delay
    if closest_indexL > closest_indexR
        closest_index = closest_indexR;
    else
        closest_index = closest_indexL;
    end
    
    %implement time delay
    closest_sound_time_adjustedL = closest_soundL(closest_index + closest_time_before_indexL:closest_index + closest_time_after_indexL);
    closest_sound_time_adjustedR = closest_soundR(closest_index + closest_time_before_indexR:closest_index + closest_time_after_indexR);
    sound_amp_adjustedR = closest_sound_time_adjustedR * amp_shift;
    sound_amp_adjustedL = closest_sound_time_adjustedL * amp_shift;
    
    %convolve desired sound and manipulated impulse response
    conv_adjusted_soundL = conv(desired_soundL, sound_amp_adjustedL);
    conv_adjusted_soundR = conv(desired_soundR, sound_amp_adjustedR);

    %trim longer signal to length of shorter signal
    if length(conv_adjusted_soundL) < length(conv_adjusted_soundR)
        stereoR = conv_adjusted_soundR(1:length(conv_adjusted_soundL));
        stereoL = conv_adjusted_soundL;
    else
        stereoR = conv_adjusted_soundR;
        stereoL = conv_adjusted_soundL(1:length(conv_adjusted_soundR));
    end

    hamming_window = hamming(length(stereoR)) * 15; %stereoL and stereoR have same length; multiply to make it louder
    hamming_stereoR = hamming_window .* stereoR;
%     plot(hamming_stereoR,'r')
%     hold on
%     plot(stereoR,'b')
    hamming_stereoL = hamming_window .* stereoL;
       
    if current_step ~= 2 %doing this on first step would throw error
        bob =  stereo_adjusted_sound(end - half_interval_length + 1: end, 1);
%         figure
%         plot(bob)
        stereo_adjusted_sound(end - half_interval_length + 1: end, 1) = stereo_adjusted_sound(end - half_interval_length+1: end, 1) + hamming_stereoL(1:half_interval_length);        
        stereo_adjusted_sound(end - half_interval_length + 1: end, 2) = stereo_adjusted_sound(end - half_interval_length+1: end, 2) + hamming_stereoR(1:half_interval_length);
    end
    
    stereo_adjusted_sound = [stereo_adjusted_sound; [hamming_stereoL(half_interval_length+1:end), hamming_stereoR(half_interval_length+1:end)]];
    desired_angle %so you know how far along it is
end

    audiowrite(f, stereo_adjusted_sound, fs);
%     plot(stereo_adjusted_sound)

