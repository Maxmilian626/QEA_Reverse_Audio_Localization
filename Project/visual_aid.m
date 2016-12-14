%plot while running

clf
axis([-1 1 -1 1])
loop_step = loop_step;
x = linspace(90,450,360/loop_step);
hold on

for i = 1:length(x)
    c = cosd(x(i));
    s = sind(x(i));
    plot(c,s,'b*')
    drawnow
    pause(49/length(x)); %don't remember where 49 came from
end