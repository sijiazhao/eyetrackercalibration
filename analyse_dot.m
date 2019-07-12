function dot = analyse_dot

subject = 'S0';
EyelinkName = '_resting_dot';
unit = '_diameter';
% unit = '_area';
EyelinkName = [EyelinkName,unit];

addpath(['.\Functions']);
path_root = '.\';
path_in = [path_root 'Data\'];

trial_number = 1; condlist = {'dot'}; triallist = {'dot'};

tw_epoch = [-2 30]; % time window for epoch [s]
tw_bc = [-2 0]; % time window for epoch baseline correction [s]

EyelinkName = [path_in, subject,EyelinkName];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------- Start to convert -------------
smpfreq = 250;
block = 1;

%% Load pupil data (* requires asc2data)
[eyedata,pupildata,time,starttime,smpfreq] = asc2data([EyelinkName,'_sample.asc'],smpfreq,'binoc');
eyedata = eyedata'; %LX,LY,RX,RY
pupildata = pupildata'; %pupil dimeter of L and R


% au vs 5mm (the dot real diameter)
dot.left = nanmedian(pupildata(:,1))/5; % = number of au for 1mm
dot.right = nanmedian(pupildata(:,2))/5;
dot.both = nanmedian(reshape(pupildata,1,numel(pupildata))/5);

figure(1); clf;
% xl = [680 685];
% subplot(2,1,1); hist(pupildata(:,1)/5); xlabel('a.u. per mm'); xlim(xl); title('Left eye'); text(min(xl),max(ylim)*0.9,['median = ' num2str(dot.left)]);
% subplot(2,1,2); hist(pupildata(:,2)/5); xlabel('a.u. per mm'); xlim(xl); title('Right eye'); text(min(xl),max(ylim)*0.9,['median = ' num2str(dot.right)]);

subplot(1,2,1); hist(pupildata(:,1)/5); xlabel('a.u. per mm'); title('Left eye'); 
text(min(xlim),max(ylim)*0.9,['median = ' num2str(dot.left)]);
subplot(1,2,2); hist(pupildata(:,2)/5); xlabel('a.u. per mm'); title('Right eye'); 
text(min(xlim),max(ylim)*0.9,['median = ' num2str(dot.right)]);

disp([' 1mm = '  num2str(dot.both) '(both), ' num2str(dot.left) '(left eye), ' num2str(dot.right) '(right eye)']);

suptitle({'Fixed 5-mm-wide black dot'; 'Distribution of pupil diameters over 30s'});
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 4]);
filename = ['fig_' subject unit '_distribution'];
saveas(gcf,[filename,'.png']);
