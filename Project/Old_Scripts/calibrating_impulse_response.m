% plot(y2(length(y2)-length(y1):end),'r')
% plot(soundR,'r')
% hold on
% plot(soundL, 'b')

%line up start of impulses (for 0 and 180, or calibration)
[max_soundL, indexL] = max(soundL);
[max_soundR, indexR] = max(soundR);
time_before_index = 500; %so we don't miss any values
length_of_sound = 7000; %so they're equal length

soundR = soundR(indexR - time_before_index:indexR + length_of_sound);
soundL = soundL(indexL - time_before_index:indexL + length_of_sound);

% plot(soundR,'r')
% hold on
% plot(soundL,'b')

%find average scaling factor between L and R
for i = 1:length(soundR)
    if soundL(i) == 0
        diff(i) = 0;
    else
        diff(i) = soundR(i)/soundL(i);
    end
end
% average_scaling_factor = mean(diff);
% average_scaling_factor = soundR./soundL;

% plot(soundR,'r')
% figure
% plot(soundL.*average_scaling_factor,'b')
