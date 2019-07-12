clear;close all;clc
rng('shuffle');
dbstop if error;

length_resting = 30; % in [s]

Screen('Preference', 'SkipSyncTests', 1);
expsbj = input(' NAME of PARTICIPANT? [ex. S10] = ','s');
thisblock = 'resting';
disp(' -- Checking the absolute pupil diameter at resting state --');
when = input(' before the experimental session or after? [eg. pre, post] = ','s');
% whicheye = input(' which eye? [eg. l for left, r for right] ','s');

thisblock = [thisblock '_' when];

el = 1; % 1 = Eyelink on; 0 = Eyelink off;

disp([expsbj,' block ', thisblock, 'is starting...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set folders and filenames
ExpDataDrct = ['./Data/']; %this vector will be updated later (add date)
outfile = [expsbj,'_',thisblock];

% Eye-tracking data's filename (temporary)
switch el
    case 1
        Eyelinkuse = 'on';
    case 0
        Eyelinkuse = 'off';
end
ExpDrct =  './';
tmpname = '100'; %temporary name for eyetracking data

ExpDataDrct = [ExpDataDrct,'/'];
mkdir(ExpDataDrct);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Eyelink Setting
dummymode = 0;
KbName('UnifyKeyNames');
Screen('Preference', 'VisualDebuglevel', 2);
screens=Screen('Screens');

% screenNumber = 1;
screenNumber=max(screens);
[window,ExpCond.rect]=Screen('OpenWindow',screenNumber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EyeLink Calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Eyelinkuse,'on')==1
    if ~dummymode, HideCursor; end
    commandwindow;
    fprintf('EyelinkToolbox Example\n\n\t');
    eyl=EyelinkInitDefaults(window);
    ListenChar(2);
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    [v,vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    %     Eyelink('Openfile',[EyelinkName,'.edf']);
    Eyelink('Openfile',[tmpname,'.edf']);
    EyelinkDoTrackerSetup(eyl);
    EyelinkDoDriftCorrection(eyl);
    Eyelink('StartRecording');
    WaitSecs(0.1);
    Eyelink('Message', 'SYNCTIME');
end
%%%%%%%%%%%%%%%%%%%%%% EyeLink Calibration End %%%%%%%%%%%%%%%%%%%%%%%%%%
% Common eyetracking set up
ExpCond.distSc_Sbj = 65; % Distance from subject to monitor [cm]
ExpCond.ScWidth = 53.4; % Screen width [cm]
ExpCond.smpfreq = 1000; % Sampling rate of Eyelink [Hz]
ExpCond.linewidth = 7; % in pixels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up Screens

white = WhiteIndex(window);
black = BlackIndex(window);
% gray = (white+black)/2;
gray = 50; % NEW GRAY on 2018-09-08
inc = white-gray;
bgColor = [gray gray gray]*3/2;
red = [black white white];
fixSize = [0 0 25 25];
fixColor = 10;
FBcolor = [180 180 180];

VA1deg.cm = 2*pi*ExpCond.distSc_Sbj/360;  % visual angle 1 deg [unit:cm]
VA05deg.cm = 2*pi*ExpCond.distSc_Sbj/360/2;  % visual angle 0.5 deg [unit:cm]
px_in_cm = ExpCond.ScWidth/ExpCond.rect(3); % one pixel on the specified screen [unit:cm]
VA1deg.px = floor(VA1deg.cm/px_in_cm); % visual angle 1 deg [unit:pixel]
VA05deg.px = floor(VA05deg.cm/px_in_cm); % visual angle 0.5 deg [unit:pixel]

% positions of the fixation point
centerpx = [ExpCond.rect(3)/2 ExpCond.rect(4)/2];       % position of the center H,V (in pixel)
fxpointH = [centerpx(1) centerpx(2) centerpx(1) centerpx(2)]+[-1 0 1 0]*floor(VA1deg.px/2);
fxpointV = [centerpx(1) centerpx(2) centerpx(1) centerpx(2)]+[0 -1 0 1]*floor(VA1deg.px/2);

textSize = 16;

text= ['Please keep your eyes open for the following ' num2str(length_resting) 's. Press SPACE KEY to start the test.'];

Screen('FillRect', window, bgColor);
Screen(window,'TextFont','Arial');
Screen(window,'TextSize',textSize);
x=(ExpCond.rect(3)-textSize*10)/2;
y=(ExpCond.rect(4)+textSize*0.75)/2;
Screen(window,'DrawText',text,x,y,[black black black]);
Screen('Flip', window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
done = 0;
while 1
    [ keyIsDown, ~, keyCode ] = KbCheck;
    if keyIsDown && done==0
        if keyCode(KbName('Space'))
            Screen('FillRect', window, bgColor);
            Screen('DrawLine', window, [black black black], fxpointH(1), fxpointH(2), fxpointH(3), fxpointH(4), 4);
            Screen('DrawLine', window, [black black black], fxpointV(1), fxpointV(2), fxpointV(3), fxpointV(4), 4);
            Screen('Flip', window);
            disp('START!');
            WaitSecs(1.5)
            done=1;
            break
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experiment Part

Screen('FillRect', window, bgColor);
Screen('DrawLine', window, [black black black], fxpointH(1), fxpointH(2), fxpointH(3), fxpointH(4), 4);
Screen('DrawLine', window, [black black black], fxpointV(1), fxpointV(2), fxpointV(3), fxpointV(4), 4);
Screen('Flip', window);

tmptime = GetSecs;

breakp = 0;

%% Resting state pupil diameter
if strcmp(Eyelinkuse,'on')==1
    
    feedback4fixation = 0;
    
    Eyelink('StartRecording'); % start recording (to the file)
    error = Eyelink('checkrecording'); % Check recording status, stop display if error
    if(error~=0)
        break;
    end
    
%     % check for endsaccade events
%     fixcenter = 0;
%     while fixcenter==0
%         if Eyelink('isconnected') == eyl.dummyconnected % in dummy mode use mousecoordinates
%             [x,y] = GetMouse(window);
%             evt.type = eyl.ENDSACC;
%             evt.genx = x;
%             evt.geny = y;
%             evtype = eyl.ENDSACC;
%         else % check for events
%             evtype = Eyelink('getnextdatatype');
%         end
%         
%         if evtype == eyl.ENDSACC % if the subject finished a saccade check if it fell on an object
%             if Eyelink('isconnected') == eyl.connected % if we're really measuring eye-movements
%                 evt = Eyelink('getfloatdata', evtype); % get data
%             end
%             
%             % check if saccade landed on fixation cross
%             if 1 == IsInRect(evt.genx,evt.geny, [centerpx(1)-100,centerpx(2)-100,centerpx(1)+100,centerpx(2)+100])
%                 
%                 fixcenter = 1;
%                 if feedback4fixation
%                     Screen('FillRect', window, bgColor);
%                     Screen('DrawLine', window, [black black black], fxpointH(1), fxpointH(2), fxpointH(3), fxpointH(4), 4);
%                     Screen('DrawLine', window, [black black black], fxpointV(1), fxpointV(2), fxpointV(3), fxpointV(4), 4);
%                     Screen('Flip', window);
%                 end
%                 
%             else % if not fixating, toggle red fixation !
%                 
%                 if feedback4fixation
%                     Screen('FillRect', window, bgColor);
%                     Screen('DrawLine', window, [black white white], fxpointH(1), fxpointH(2), fxpointH(3), fxpointH(4), 4);
%                     Screen('DrawLine', window, [black white white], fxpointV(1), fxpointV(2), fxpointV(3), fxpointV(4), 4);
%                     Screen('Flip', window);
%                 end
%                 
%             end
%             WaitSecs(.1);
%         end % saccade?
%     end
    
    Screen('FillRect', window, bgColor);
    Screen('DrawLine', window, [black black black], fxpointH(1), fxpointH(2), fxpointH(3), fxpointH(4), 4);
    Screen('DrawLine', window, [black black black], fxpointV(1), fxpointV(2), fxpointV(3), fxpointV(4), 4);
    Screen('Flip', window);
    
%     WaitSecs(2); % this needs to add into ISI
end % el

disp(['Block:',thisblock,' Resting state starts (',num2str(length_resting),'s)']);
disp('***');
if strcmp(Eyelinkuse,'on')==1
    Eyelink('Message', ['Trial: 0 ' thisblock,'_',num2str(length_resting)]);
end

%% Wait for resting state
WaitSecs(length_resting);

%% Check if you want to terminate the experiment
[ keyIsDown, ~, keyCode ] = KbCheck;
if keyCode(KbName('Escape'))
    breakp = 1;
    break;
end

totaltime = GetSecs - tmptime;

if breakp==0
    text='FINISHED!';
elseif breakp==1
    text='ABORTED!';
end

Screen('FillRect', window, bgColor);
Screen(window,'TextFont','Arial');
Screen(window,'TextSize',textSize);
x=(ExpCond.rect(3)-textSize*8)/2;
y=(ExpCond.rect(4)+textSize*0.75)/2;
Screen(window,'DrawText',text,x,y,[black black black]);
Screen('Flip', window);
WaitSecs(1.5);

if strcmp(Eyelinkuse,'on')==1
    
    EyelinkName=[ExpDataDrct outfile];
    
    Eyelink('Stoprecording');
    Eyelink('ReceiveFile',tmpname); % copy the file from eyetracker PC to Stim PC
    Eyelink('CloseFile');
    Eyelink('Shutdown');
    if breakp==0
        command = ['edf2asc ',tmpname,'.edf -ns'];
        status = dos(command);
        command = ['rename ',tmpname,'.asc ',tmpname,'_event.asc '];
        status = dos(command);
        command = ['edf2asc ',tmpname,'.edf -ne'];
        status = dos(command);
        command = ['rename ',tmpname,'.asc ',tmpname,'_sample.asc '];
        status = dos(command);
        movefile([tmpname '.edf'],[EyelinkName '.edf']);
        movefile([tmpname '_sample.asc'],[EyelinkName '_sample.asc']);
        movefile([tmpname '_event.asc'],[EyelinkName '_event.asc']);
    end
end

if breakp==0 %&& ifpractice==0 %&& Sblock~=0
    disp('----- EXPERIMENT FINISHIED -----')
    disp(['- TOTAL TIME: ',num2str(totaltime)])
elseif breakp==1
    disp('----- EXPERIMENT ABORTED -----')
    disp(['- TOTAL TIME: ',num2str(totaltime)])
end
disp([thisblock])
Screen('CloseAll');
close all;