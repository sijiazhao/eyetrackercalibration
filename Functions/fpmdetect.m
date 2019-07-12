function pm = fpmdetect(Pn,mode)
% Check Makoto's script: PM = pmdetect(Pn, smpfreq, pblinkrem,ridnum, varargin)
% Pn = pupil data
% thrs = threshold parameter for pupil dilation duration (default = 300ms)

% if nargin < 2 % define threshold parameters (for pupil dilation duration)
%     thrs = 300; %[ms]
% end

Pn = smooth(Pn,150,'hann'); %Smooth pupil data

%% Step 1: check peak and troughs
[pks1,locs1,~,~] = findpeaks(Pn); %Peak = peak pupil dilation
[pks2,locs2,~,~] = findpeaks(-Pn); %Trough = peak pupil constriction
pks2 = -pks2;

%% Step 2: Find differential ((concerning rates of change and slopes of
% curve)
% dx = mean(diff(1:numel(Pn))); % Find Mean Differece In ‘x’ Values
% dy = gradient(Pn,dx);
dy = [NaN,diff(Pn)];
% Find the time point of switch: shown as the points when green changes to red
dypos = find(dy>0);
dyneg = find(dy<0);
dyy = zeros(size(dy));
dyy(dypos) = 1; dyy(dyneg) = -1;
neg2pos = [find(diff(dyy) == 2),find(diff(dyy) == 1)];
% pos2neg = [find(diff(dyy) == -2)];
pos2neg = [find(diff(dyy) == -2),find(diff(dyy) == -1)];

% ------
debugmode = 0;
if debugmode
    figure(1);clf;
    subplot(2,1,1);
    hold on;
    plot(Pn);
    scatter(locs2,pks2,'o','b');
    scatter(locs1,pks1,'x','r');
    hold off;
    title('o: peak constriction; x: peak dilation');
    ylabel('pupil diameter [z]');
    
    subplot(2,1,2)
    plot(dy);
    ylabel('derivative');
    hold on;  scatter(dypos,dy(dypos),'r','o','filled', 'LineWidth',1);
    hold on;  scatter(dyneg,dy(dyneg),'g','o','filled', 'LineWidth',1);
    title('red: dilation; green: constriction');
end
% ------

%%
pt = [neg2pos pos2neg];
ptidx = [ones(size(neg2pos)) (-1)*ones(size(pos2neg))];
[pt,sort_idx] = sort(pt);
ptidx = ptidx(sort_idx);

switch mode
    case 'PD'
        onset =  neg2pos;
    case 'PC'
        onset =  pos2neg;
end

pm_onset = onset;
pm_offset = [];
pm_duration = [];
pm_amplitude = [];

for this_onset = onset
    try
        this_offset = pt(find(pt == this_onset)+1);
    catch
        this_offset = length(Pn);
        
        debugmode = 0;
        if debugmode
            figure(2);clf;
            subplot(2,1,1);
            hold on;
            plot(Pn);
            scatter(locs2,pks2,'o','b');
            scatter(locs1,pks1,'x','r');
            hold off;
            title('o: peak constriction; x: peak dilation');
            ylabel('pupil diameter [z]');
            
            subplot(2,1,2)
            plot(dy);
            ylabel('derivative');
            hold on;  scatter(dypos,dy(dypos),'r','o','filled', 'LineWidth',1);
            hold on;  scatter(dyneg,dy(dyneg),'g','o','filled', 'LineWidth',1);
            title('red: dilation; green: constriction');
        end
    end
    duration = this_offset - this_onset;
    amplitude = Pn(this_offset)-Pn(this_onset);
    
    pm_offset = [pm_offset; this_offset];
    pm_duration = [pm_duration; duration];
    pm_amplitude = [pm_amplitude; amplitude];
end

pm.onset = zeros(size(Pn));
pm.offset = zeros(size(Pn));
pm.duration = NaN(size(Pn));
pm.amplitude = NaN(size(Pn));

pm.onset(pm_onset) = 1;
pm.offset(pm_offset) = 1;
pm.duration(pm_onset) = pm_duration;
pm.amplitude(pm_onset) = pm_amplitude;

debugmode = 0;
if debugmode
    figure(3);clf;
    hold on;
    plot(Pn,'k','LineWidth',1);
    scatter(pm_onset,Pn(pm_onset),'o','b','LineWidth',1.5);
    scatter(pm_offset,Pn(pm_offset),'x','r','LineWidth',1.5);
    hold off;
    title(['o: ' mode ' onset; x: offset']);
    ylabel('Pupil diameter [z-score]');
    xlabel('Time [ms]');
    
    for ix = 1:numel(pm_onset)
        text(pm_onset(ix),Pn(pm_onset(ix))+0.3,['dur=' num2str(pm_duration(ix))]);
        text(pm_onset(ix),Pn(pm_onset(ix))+0.15,['amp=' num2str(round(pm_amplitude(ix),2))]);
    end
    
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 4]);
    filename = ['eg'];
    saveas(gcf,[filename, '.png'],'png');
end

end
