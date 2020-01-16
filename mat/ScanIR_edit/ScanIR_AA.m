function varargout = ScanIR(varargin)
% SCANIR M-file for ScanIR.fig
%      SCANIR, by itself, creates a new SCANIR or raises the existing
%      singleton*.
%
%      H = SCANIR returns the handle to a new SCANIR or the handle to
%      the existing singleton*.
%
%      SCANIR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANIR.M with the given input arguments.
%
%      SCANIR('Property','Value',...) creates a new SCANIR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ScanIR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ScanIR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ScanIR

%  Written by Agnieszka Roginska and Braxton Boren
%  NYU Music and Audio Research Lab
%  Copyright 2011

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ScanIR_OpeningFcn, ...
                   'gui_OutputFcn',  @ScanIR_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ScanIR is made visible.
function ScanIR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ScanIR (see VARARGIN)

% Choose default command line output for ScanIR
handles.output = hObject;

% add toolbar for zooming axes
set(hObject,'toolbar','figure');

handles.data = [];
handles.specs = [];
handles.app = [];

handles.specs.filtertype = 'fixed filters';
handles.specs.subjectName = [];
handles.specs.database = [];
handles.specs.comments = [];

handles.app.currID = 1;
handles.app.npositions = []; % number of total recording positions for HRIRs for each series of recordings
handles.app.sorted = 0; % 0 if unsorted, 1 if sorted
handles.app.azPositionData = [str2double(get(handles.az_start,'String')) str2double(get(handles.az_interval, 'String')) str2double(get(handles.az_end, 'String')) ];
handles.app.elPositionData = [str2double(get(handles.el_start,'String')) str2double(get(handles.el_interval, 'String')) str2double(get(handles.el_end, 'String')) ];
handles.app.seriesInfo = []; % stores the ID numbers of positions at the end of each series

handles.hrir_az = []; % row vector of azimuths for HRIR measurements
handles.hrir_el = []; % row vector of elevations for HRIR measurements
handles.sizeLoadedData = 0;
handles.numSeries = 1; % index of current series

opening = welcome;
disp(opening);
if ( strcmp(opening, 'createNew') )
    setup = createNew;
    handles.app.inMode = setup.inMode;
    handles.specs.signalType = setup.signalType;
    handles.app.sigLength = setup.sigLength;
    handles.app.irLength = setup.irLength;
    handles.specs.sampleRate = setup.sampleRate;
    handles.app.numInputChls = setup.numInputChls;
    handles.app.numOutputChls = setup.numOutputChls;
    handles.app.outMode = setup.outMode;
    handles.maxOuts = setup.maxOuts;
    handles.app.numPlays = setup.numPlays;
    
    if (handles.app.sigLength == 1)
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' second'));
    else
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' seconds'));
    end
    set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength),' samples'));
    if (handles.app.inMode == 2)
        set(handles.hrir_panel, 'Visible', 'on');
    end
elseif ( strcmp(opening, 'loadSession') )
    handles = loadFile(hObject, handles);
    % find maximum number of output and input channels
    
    InitializePsychSound;
    dev = PsychPortAudio('GetDevices');
    [m n] = size(dev);
    handles.maxOuts = 0;
    handles.maxIns = 0;
    for k = 1:n
        testOuts = getfield(dev, {1,k}, 'NrOutputChannels');
        if (handles.maxOuts < testOuts)
            handles.maxOuts = testOuts;
        end
        testIns = getfield(dev, {1,k}, 'NrInputChannels');
        if (handles.maxIns < testIns)
            handles.maxIns = testIns;
        end
    end
end

if exist('handles.loaded')
    if ( strcmp(handles.loaded, 'fail') ) 
        error('User cancelled file load');
        return
    end
end

handles.app.outchl = str2double(get(handles.outChannelEdit, 'String'));

% update 'setup' panel
set(handles.sigTypeDisp, 'String', handles.specs.signalType);
set(handles.srateDisp, 'String', strcat(num2str(handles.specs.sampleRate),' samples/second'));
set(handles.numinchlsDisp, 'String', num2str(handles.app.numInputChls));

if (handles.app.inMode == 1) % Mono IR
    set(handles.modeDisp, 'String', 'Mono IR        ');
    set(handles.text21, 'Visible', 'off');
    set(handles.freqchl_edit, 'Visible', 'off');
elseif (handles.app.inMode == 2) % HRIR
    set(handles.modeDisp, 'String', 'HRIR           ');
    set(handles.plottype_popup, 'String', 'Time - overlay|Frequency - overlay|Time - cascade|Frequency - cascade|Frequency - cascade chl'); 
    set(handles.az_edit, 'Enable', 'off');
    set(handles.el_edit, 'Enable', 'off');
    if (handles.app.outMode == 2)
        handles.app.npositions(1) = handles.app.numOutputChls;
        handles.app.seriesInfo(1) = handles.app.numOutputChls;
        set(handles.outChannelEdit, 'Enable', 'off');
        set(handles.outChannelEdit, 'String', strcat('1-',num2str(handles.app.npositions(handles.numSeries))));
        set(handles.az_end, 'Enable', 'off');
        set(handles.el_end, 'Enable', 'off');
    end    
    handles = updateHRIR(hObject,handles); 
    set(handles.hrir_panel, 'Title', strcat('HRIR Locations for 1-',num2str(handles.app.npositions(handles.numSeries))));
elseif (handles.app.inMode == 3) % Multichannel IR
    set(handles.modeDisp, 'String', 'Multichannel IR');
    if (handles.app.numInputChls < 4)
        set(handles.plottype_popup, 'String', 'Time - overlay|Frequency - overlay|Time - cascade|Frequency - cascade|Frequency - cascade chl');
    else
        set(handles.plottype_popup, 'String', 'Time - cascade|Frequency - cascade|Frequency - cascade chl');
    end
end

set(handles.backButton, 'Enable', 'off');
if (size(handles.data,2) < 1)
    set(handles.forwardButton, 'Enable', 'off');
end
    
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ScanIR_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = goBackward(hObject, handles);


% --- Executes on selection change in fftlen_popup.
function fftlen_popup_Callback(hObject, eventdata, handles)
if (handles.app.currID<=size(handles.data,2))
    plotresponse(handles);
end

% --- Executes during object creation, after setting all properties.
function fftlen_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in measureButton.
function measureButton_Callback(hObject, eventdata, handles)

set(handles.measureButton, 'Enable', 'off');
if (handles.app.currID ~= 1)
    set(handles.backButton, 'Enable', 'off');
end
if (handles.app.currID <= size(handles.data,2))
   set(handles.forwardButton, 'Enable', 'off');
end
drawnow;

if ( handles.app.outMode == 1 )
    handles = measurePosition(hObject, handles);    
elseif(handles.app.outMode == 2 && handles.app.currID > size(handles.data,2) )
    for k = 1:handles.app.npositions(handles.numSeries)
        handles.app.outchl = k;
        handles = measurePosition(hObject, handles);
        drawnow;
        if (k < handles.app.npositions(handles.numSeries))
            handles = goForward(hObject, handles);
        end
    end
elseif ( handles.app.outMode == 2 && handles.app.currID <= size(handles.data,2) )
    handles = calcModID(hObject, handles);
    handles.app.outchl = handles.modID;
    handles = measurePosition(hObject, handles);
end

set(handles.measureButton, 'Enable', 'on');
if (handles.app.currID ~= 1)
    set(handles.backButton, 'Enable', 'on');
end
if (handles.app.currID <= size(handles.data,2))
   set(handles.forwardButton, 'Enable', 'on');
end

%%%%%
% auto-save data after measurement%

    if (get(handles.sort_checkbox, 'Value'))
        % sort data before saving
        len = size(handles.data,2); % overall number of measured positions
        pts = [];
        for i = 1:len
            pts = [pts; [handles.data(i).elevation handles.data(i).azimuth] ];
        end
        pts = sortrows(pts, [1 2]); % sort by elevation, then by azimuth when tied
        out = [];
        for j = 1:len % index over raw data
            for k = 1:len % index over sorted data file
                if ( (handles.data(j).elevation == pts(k,1)) && (handles.data(j).azimuth == pts(k,2)) )
                    out(k).azimuth = handles.data(j).azimuth;
                    out(k).elevation = handles.data(j).elevation;
                    out(k).distance = handles.data(j).distance;
                    out(k).IR = handles.data(j).IR;
                    out(k).ITD = handles.data(j).ITD;
                    out(k).comments = handles.data(j).comments;
                end
            end
        end
        tempData = out; % save sorted data
        handles.app.sorted = 1;
    else
        tempData = handles.data; % save unsorted data
        handles.app.sorted = 0;
    end

    specs = handles.specs; % save entire specs struct
    app = handles.app; % save entire ScanIR application-specific struct

    save('ScanIR_AutoSave', 'tempData', 'specs', 'app');

% --- Executes on button press in forwardButton.
function forwardButton_Callback(hObject, eventdata, handles)
handles = goForward(hObject, handles);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)

if (get(handles.sort_checkbox, 'Value'))
    % sort data before saving
    len = size(handles.data,2); % overall number of measured positions
    pts = [];
    for i = 1:len
        pts = [pts; [handles.data(i).elevation handles.data(i).azimuth] ];
    end
    pts = sortrows(pts, [1 2]); % sort by elevation, then by azimuth when tied
    out = [];
    for j = 1:len % index over raw data
        for k = 1:len % index over sorted data file
            if ( (handles.data(j).elevation == pts(k,1)) && (handles.data(j).azimuth == pts(k,2)) )
                out(k).azimuth = handles.data(j).azimuth;
                out(k).elevation = handles.data(j).elevation;
                out(k).distance = handles.data(j).distance;
                out(k).IR = handles.data(j).IR;
                out(k).ITD = handles.data(j).ITD;
                out(k).comments = handles.data(j).comments;
            end
        end
    end
    data = out; % save sorted data
    handles.app.sorted = 1;
else
    data = handles.data; % save unsorted data
    handles.app.sorted = 0;
end

[filename,pathname] = uiputfile('*.mat', 'Save...');

specs = handles.specs; % save entire specs struct
app = handles.app; % save entire ScanIR application-specific struct

save(strcat(pathname, filename), 'data', 'specs', 'app');
delete 'ScanIR_AutoSave.mat';


function az_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function az_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function el_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function el_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dist_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function dist_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotDomainListBox.
function plotDomainListBox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function plotDomainListBox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
handles = loadFile(hObject, handles);

% function for loading files
function handles = loadFile(hObject, handles)
[filename,pathname] = uigetfile('*.mat', 'Load Session');

if filename
    load(strcat(pathname,filename));
    handles.loaded = 'succeed';
else
    handles.loaded = 'fail';
    return
end

handles.data = data;
num = length(data);
for j = 1:num
   if ( handles.data(j).ITD > 0 )
       prepend = zeros( handles.data(j).ITD, 1 );
       append = prepend;
       ch1 = [ prepend; handles.data(j).IR(:,1) ];
       ch2 = [ handles.data(j).IR(:,2); append ];
       handles.data(j).IR = [ch1 ch2];
   elseif ( handles.data(j).ITD < 0 )
       prepend = zeros( handles.data(j).ITD, 1 );
       append = prepend;
       ch1 = [ handles.data(j).IR(:,1); append ];
       ch2 = [ prepend; handles.data(j).IR(:,2) ];
       handles.data(j).IR = [ch1 ch2];
   end
end

handles.specs = specs;
handles.numSeries = 1;
handles.sizeLoadedData = size(data,2);
% check size of loaded data
if (handles.sizeLoadedData >= 1)
    set(handles.forwardButton, 'Enable', 'on');
end
set(handles.backButton, 'Enable', 'off');
handles.internal = exist('app','var');
if (handles.internal) % if we're loading a file made in ScanIR, the 'app' struct should exist in the load file
    handles.app = app;
    if (app.inMode == 1)
        modeString = 'Mono IR        ';
    elseif (app.inMode == 2)
        modeString = 'HRIR           ';
        if (handles.app.sorted == 1)
            set(handles.hrir_panel, 'Visible', 'off');
            disp('1');
        else
            set(handles.hrir_panel, 'Visible', 'on');
            set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
            set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
            set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
            set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
            set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
            set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
            set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
        end
    elseif (app.inMode == 3)
        modeString = 'Multichannel IR';
    end
    if (handles.app.sigLength == 1)
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' second'));
    else
        set(handles.sigLengthDisp, 'String', strcat(num2str(handles.app.sigLength),' seconds'));
    end
    set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength), ' samples'));
    set(handles.outChannelEdit, 'String',handles.app.outchl);
else % if we're loading HRIRs from a different database with no ScanIR-specific 'app' struct
    set(handles.hrir_panel, 'Visible', 'off');
    modeString = 'HRIR           ';
    handles.app.numInputChls = 2;
    disp('Loading HRIR database - you must have 2 active input channels to record extra HRIR positions.');
    handles.app.inMode = 2;
    handles.app.outMode = 1;
    handles.app.irLength = size(handles.data(1).IR,1);
    if ~exist('handles.app.sigLength')
        handles.app.sigLength = 1;
        disp('No value for test signal length detected - for all measurements, a 1-second signal will be used.');
    end
    set(handles.sigLengthDisp, 'String', 'unknown');
    handles.app.numPlays = 1;
    
end
handles.app.currID = 1;
set(handles.modeDisp, 'String', modeString);
set(handles.sigTypeDisp, 'String', handles.specs.signalType);
set(handles.irLengthDisp, 'String', strcat(num2str(handles.app.irLength), ' samples'));
    
guidata(hObject, handles); %updates the handles
updatefields(handles);


% --- Executes on selection change in plottype_popup.
function plottype_popup_Callback(hObject, eventdata, handles)

if (handles.app.currID<=size(handles.data,2))
    plotresponse(handles);
end


% --- Executes during object creation, after setting all properties.
function plottype_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)

cla(handles.plotarea,'reset')
guidata(hObject, handles); %updates the handles


function plotresponse(handles)
cla(handles.plotarea,'reset')

plottype = get(handles.plottype_popup, 'Value');
if (plottype == 3) % plot all three IRs in time cascade mode
    plotchls = [1:min(8, handles.app.numInputChls*3)];
else
    plotchls = [1:min(8, handles.app.numInputChls)];
end

offset = 50;

fftlens = [512 1024 2048 4096 8192 16384 32768];
fftlen = fftlens(get(handles.fftlen_popup, 'Value'));

lgnd = 0;
%plot
plottype = get(handles.plottype_popup, 'Value');
if (handles.app.numInputChls > 3)   % when we have more than 3 channels
    if (plottype == 1)  % choice 1 is time cascading
        plottype = 3;
    elseif (plottype == 2) % choice 2 is frequency cascading
        plottype = 4;
    elseif (plottype == 3) % when we pick frequency by channel
        if (size(handles.data,2) < 2) % if there are less than two channels measured
            plottype = 4; % plot frequency cascading for a single measurement position
        else
            plottype = 5; % otherwise we can plot the change over the single channel for multiple positions
        end
    end
elseif (plottype == 5) % when we pick frequency by channel in HRIR mode
    if (size(handles.data,2) < 2) % if there are less than two channels,
        plottype = 4; % plot frequency cascading for a single measurement position
    else
        plottype = 5; % otherwise we can plot the change over the single channel for multiple positions
    end
end
    
if (plottype == 1) %time domain overlay
    plot(handles.plotarea, handles.data(handles.app.currID).IR(:, plotchls));
    xlabel('Time (samples)');
    ylabel('Amplitude');
    lgnd = 1;
    
elseif (plottype == 2) %frequency - overlay
    %    fftlen =  2^nextpow2(length(handles.data(handles.app.currID).IR));
    %    RESP = 20*log10(abs(fft(handles.data(handles.app.currID).IR(:,:),fftlen)));
    resp = [];
    [junk, ind]= max(abs(handles.data(handles.app.currID).IR));
    firstIRind = min(ind);
    
    for i = plotchls
        r = handles.data(handles.app.currID).IR(:,i);
        [m, ind] = max(abs(r(:)));
        strt = max(1, firstIRind-offset);
        r = r(strt:min(strt+fftlen-1, length(r)));
        resp = [resp, r];
    end;
    RESP = 20*log10(abs(fft(resp,fftlen)));
    semilogx([0:1/(length(RESP)/2):1]*((handles.specs.sampleRate/1000)/2), RESP(1:length(RESP)/2+1,plotchls));
    xlabel('Frequency (kHz)');
    ylabel('dB');
    lgnd = 1;
        
elseif (plottype == 3) %time domain cascade
    hold off
    maxVal = 0;
%     temp = [handles.data(handles.app.currID).IR handles.data(handles.app.currID).IR_MLS handles.data(handles.app.currID).IR_golayCodes];
    temp = [handles.data(handles.app.currID).IR handles.data(handles.app.currID).IR_golayCodes];

    for k = plotchls
        maxVal = max(maxVal, max(abs(temp(:,k))));
        %disp(maxVal);
    end
    yScale = .5/maxVal;
    for i = plotchls
        plot(handles.plotarea, yScale*temp(:,i)+i);
        hold on;
    end;
    set(handles.plotarea,'ytick', [1:handles.app.numInputChls*3]);
    xlabel('Time (samples)');
    ylabel('Channel');
    yL = get(handles.plotarea, 'ylim');
    %disp(yL);

elseif (plottype == 4) %frequency - cascade
    if (handles.app.numInputChls == 1)
        set(handles.plottype_popup, 'Value', 2);
        plotresponse(handles);
    else
        resp = [];
        [junk, ind]= max(abs(handles.data(handles.app.currID).IR));
        firstIRind = min(ind);
        for i = plotchls
            r = handles.data(handles.app.currID).IR(:,i);
            [m, ind] = max(abs(r(:)));
            strt = max(1, firstIRind-offset);
            r = r(strt:min(strt+fftlen-1, length(r)));
            resp = [resp, r];
        end;
        %       fftlen =  2^nextpow2(length(handles.data(handles.app.currID).IR));
        %       RESP = 20*log10(abs(fft(handles.data(handles.app.currID).IR(:,:),fftlen)));
        RESP = 20*log10(abs(fft(resp,fftlen)));
        mesh([1:size(RESP(1:length(RESP)/4+1,:),2)], [0:1/(length(RESP)/2):.5]*(handles.specs.sampleRate/1000/2), RESP(1:length(RESP)/4+1,:));%, [-60, 0]);
        caxis([-60 -10]);
        colorbar;
        xlabel('Channel');
        ylabel('Frequency (kHz)');
        zlabel('dB');
        set(handles.plotarea,'xtick', [1:handles.app.numInputChls]);
    end;
    
elseif (plottype == 5) %frequency - cascade by channel
    chl = str2num(get(handles.freqchl_edit, 'String'));
        resp = [];
        temp = [];
        for i = 1:size(handles.data,2)
            temp = [temp handles.data(i).IR(:,chl)];
        end
        [junk, ind]= max(abs(handles.data(handles.app.currID).IR));
        firstIRind = min(ind);
        for i = 1:size(handles.data,2)
            r = handles.data(i).IR(:,chl);
            [m, ind] = max(abs(r));
            strt = max(1, firstIRind-offset);
            r = r(strt:min(strt+fftlen-1, length(r)));
            resp = [resp, r];
        end;
        
        RESP = 20*log10(abs(fft(resp,fftlen)));
        x = [];
        for i = 1:size(handles.data, 2)
            x = [x, handles.data(i).distance];
        end;

        if (size(RESP, 2)>9)
            imagesc_up(1:size(RESP,2),[0:1/(length(RESP)/2):.5]*(handles.specs.sampleRate/1000/2),RESP(1:length(RESP)/4+1, :),'auto',8,8,[]);
        else
            mesh([1:size(RESP(1:length(RESP)/4+1,:),2)], [0:1/(length(RESP)/2):.5]*(handles.specs.sampleRate/1000/2), RESP(1:length(RESP)/4+1,:));
        end;
        caxis([-80 0]);
        set(handles.plotarea,'xtick', [1:size(RESP, 2)]);        
        %set(handles.plotarea,'xticklabel', x);
        view([0 90]);
        colorbar;
        xlabel('ID');
        ylabel('Frequency (kHz)');
        zlabel('dB');
        
end;

%legend
if (lgnd)
    str = [];
    for i = plotchls
        str = strvcat(str, sprintf('Chl %i', i));
    end;
    legend(str);
end;

function updatefields(handles)
set(handles.currID_txt, 'String', handles.app.currID);
if (handles.app.currID>size(handles.data,2))
    cla(handles.plotarea,'reset');
    set(handles.comments_edit, 'String', ' ');
    return;
end;

plotresponse(handles);

if (handles.app.currID <= size(handles.data,2))
    set(handles.az_edit, 'String', num2str(handles.data(handles.app.currID).azimuth));
    set(handles.el_edit, 'String', num2str(handles.data(handles.app.currID).elevation));
    set(handles.dist_edit, 'String', num2str(handles.data(handles.app.currID).distance));
    set(handles.comments_edit, 'String', handles.data(handles.app.currID).comments);
end


function comments_edit_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function comments_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in savewav_checkbox.
function savewav_checkbox_Callback(hObject, eventdata, handles)


function freqchl_edit_Callback(hObject, eventdata, handles)
currentValue = str2double(get(handles.freqchl_edit, 'String'));
if (currentValue > handles.app.numInputChls)
    currentValue = handles.app.numInputChls;
    set(handles.freqchl_edit, 'String', num2str(currentValue));
elseif (currentValue < 1)
    currentValue = 1;
    set(handles.freqchl_edit, 'String', num2str(currentValue));
elseif (round(currentValue) ~= currentValue)
    currentValue = round(currentValue);
    set(handles.freqchl_edit, 'String', num2str(currentValue));
end
if (handles.app.currID<=size(handles.data,2) && (get(handles.plottype_popup, 'Value') == 5) )
    plotresponse(handles);
end


% --- Executes during object creation, after setting all properties.
function freqchl_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = updateHRIR(hObject, handles) % updates array of az and el values
%disp('UPDATE HRIR');

% update az/el start/int/end
azStart = str2double(get(handles.az_start, 'String'));
azInt = str2double(get(handles.az_interval, 'String') );

elStart = str2double(get(handles.el_start, 'String') );
elInt = str2double(get(handles.el_interval, 'String') );
if (handles.app.outMode == 1) % mono output mode
    azEnd = str2double(get(handles.az_end, 'String') );
    elEnd = str2double(get(handles.el_end, 'String') );
elseif (handles.app.outMode == 2) % multichannel output mode
    azEnd = azStart + (handles.app.npositions(handles.numSeries) - 1) * azInt;
    elEnd = elStart + (handles.app.npositions(handles.numSeries) - 1) * elInt;
    set(handles.az_end,'String', num2str(azEnd));
    set(handles.el_end,'String', num2str(elEnd));
end
if (azInt == 0)  % make a full vector of the same azimuth if interval is zero
    handles.hrir_az = [azStart];
    for k = 1:(handles.app.npositions(handles.numSeries) - 1)
        handles.hrir_az = [handles.hrir_az azStart];
    end
else  % set up vector of azimuths for non-zero intervals
    if (azEnd > 360)
        azEnd = 360;      % max of 360 (later changed to 0 for simplicity)
    elseif (azEnd < -360)
        azEnd = -360;     % min of -360 (later changed to 0)
    end
    if (azStart > 360)     % same bounds for azStart
        azStart = 360;
    elseif (azStart < -360)
        azStart = -360;
    end
    
    handles.hrir_az = (azStart:azInt:azEnd);
    if (azEnd == 360 || azEnd == -360)
        handles.hrir_az(end) = 0;
        set(handles.az_end, 'String', '0');
    end
    if (azStart == 360 || azStart == -360)
        handles.hrir_az(1) = 0;
        set(handles.az_start, 'String', '0');
    end
end
if (elInt == 0)  % make a full vector of the same azimuth if interval is zero
    handles.hrir_el = [elStart];
    for k = 1:(handles.app.npositions(handles.numSeries) - 1)
        handles.hrir_el = [handles.hrir_el elStart];
    end
else
    if (elEnd > 90)
        elEnd = 90;       % max of 90
        set(handles.el_end, 'String', '90');
    elseif (elEnd < -90)
        elEnd = -90;     % min of -90
        set(handles.el_end, 'String', '-90');
    end
    if (elStart > 90)    % same bounds for elStart
        elStart = 90;
        set(handles.el_start, 'String', '90');
    elseif (elStart < -90)
        elStart = -90;
        set(handles.el_start, 'String', '-90');
    end
    handles.hrir_el = (elStart:elInt:elEnd);
end

% store this series's position data in global arrays
%disp('STORING POSITION DATA');
handles.app.azPositionData(handles.numSeries,1) = azStart;
handles.app.azPositionData(handles.numSeries,2) = azInt;
handles.app.azPositionData(handles.numSeries,3) = azEnd;
handles.app.elPositionData(handles.numSeries,1) = elStart;
handles.app.elPositionData(handles.numSeries,2) = elInt;
handles.app.elPositionData(handles.numSeries,3) = elEnd;

% disp('Az position data:'); disp(handles.app.azPositionData);
% disp('El position data:'); disp(handles.app.elPositionData);
% disp('Az array:'); disp(handles.hrir_az);
% disp('El array:'); disp(handles.hrir_el);

% update npositions and seriesInfo
if (handles.app.outMode == 1) % mono output mode
    handles.app.npositions(handles.numSeries) = length(handles.hrir_az) * length(handles.hrir_el);
%     disp('npos array:');
%     disp(handles.app.npositions);
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
%     disp('seriesInfo:');
%     disp(handles.app.seriesInfo);
    
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
    handles = calcModID(hObject, handles);
    disp('modID:'); disp(handles.modID);
    
    elIndex = ceil(handles.modID/length(handles.hrir_az));

    if (mod(handles.modID,length(handles.hrir_az)) == 0)
        azIndex = length(handles.hrir_az);
    else
        azIndex = mod(handles.modID,length(handles.hrir_az));
    end
elseif (handles.app.outMode == 2) % multichannel output mode
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
    handles = calcModID(hObject, handles);
    
    azIndex = handles.modID;   
    elIndex = handles.modID;
end
%disp('azIndex:'); disp(azIndex);
currentAz = handles.hrir_az(azIndex);
currentEl = handles.hrir_el(elIndex);
set(handles.az_edit, 'String', num2str(currentAz));
set(handles.el_edit, 'String', num2str(currentEl));

guidata(hObject,handles);

    


function az_start_Callback(hObject, eventdata, handles)
if (~get(handles.wrap_checkbox, 'Value'))  
    if (handles.app.outMode == 1)    
        testVal = str2num(get(handles.az_interval, 'String'));
        startVal = str2num(get(handles.az_start, 'String'));
        stopVal = str2num(get(handles.az_end, 'String'));
        testSign = sign(stopVal - startVal);

        if (sign(testVal) ~= testSign && testSign ~= 0)
            testVal = testVal * -1;
            set(handles.az_interval, 'String', num2str(testVal) );
        end    
    end
else
    warning('Hello Areti. I have disabled some of the error checking, so be sure all the azimuth inputs are right.');
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_start, 'String', num2str(handles.app.azPositionData(handles.numSeries,1))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);
    


% --- Executes during object creation, after setting all properties.
function az_start_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function az_interval_Callback(hObject, eventdata, handles)
if (~get(handles.wrap_checkbox, 'Value')) 
    if (handles.app.outMode == 1)
    testVal = str2num(get(handles.az_interval, 'String'));
    startVal = str2num(get(handles.az_start, 'String'));
    stopVal = str2num(get(handles.az_end, 'String'));
    testSign = sign(stopVal - startVal);

        if (testVal == 0)
            if (testSign == 0)
                testVal = 1;
            else
                testVal = testSign;
            end
            set(handles.az_interval, 'String', num2str(testVal));
        elseif (sign(testVal) ~= testSign && testSign ~= 0)
            testVal = testVal * -1;
            set(handles.az_interval, 'String', num2str(testVal) );
        end
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_interval, 'String', num2str(handles.app.azPositionData(handles.numSeries,2))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function az_interval_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function az_end_Callback(hObject, eventdata, handles)

if (~get(handles.wrap_checkbox, 'Value'))     
    testVal = str2num(get(handles.az_interval, 'String'));
    startVal = str2num(get(handles.az_start, 'String'));
    stopVal = str2num(get(handles.az_end, 'String'));
    testSign = sign(stopVal - startVal);

    if (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.az_interval, 'String', num2str(testVal) );
    end

end

if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.az_end, 'String', num2str(handles.app.azPositionData(handles.numSeries,3))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function az_end_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_start_Callback(hObject, eventdata, handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.el_interval, 'String'));
    startVal = str2num(get(handles.el_start, 'String'));
    stopVal = str2num(get(handles.el_end, 'String'));
    testSign = sign(stopVal - startVal);

    if (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.el_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_start, 'String', num2str(handles.app.elPositionData(handles.numSeries,1))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);

% --- Executes during object creation, after setting all properties.
function el_start_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function el_interval_Callback(hObject, eventdata, handles)
if (handles.app.outMode == 1)
    testVal = str2num(get(handles.el_interval, 'String'));
    startVal = str2num(get(handles.el_start, 'String'));
    stopVal = str2num(get(handles.el_end, 'String'));
    testSign = sign(stopVal - startVal);

    if (testVal == 0)
        if (testSign == 0)
            testVal = 1;
        else
            testVal = testSign;
        end
        set(handles.el_interval, 'String', num2str(testVal));
    elseif (sign(testVal) ~= testSign && testSign ~= 0)
        testVal = testVal * -1;
        set(handles.el_interval, 'String', num2str(testVal) );
    end
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_interval, 'String', num2str(handles.app.elPositionData(handles.numSeries,2))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function el_interval_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function el_end_Callback(hObject, eventdata, handles)
testVal = str2num(get(handles.el_interval, 'String'));
startVal = str2num(get(handles.el_start, 'String'));
stopVal = str2num(get(handles.el_end, 'String'));
testSign = sign(stopVal - startVal);

if (sign(testVal) ~= testSign && testSign ~= 0)
    testVal = testVal * -1;
    set(handles.el_interval, 'String', num2str(testVal) );
end
if (handles.app.currID<=size(handles.data,2))
    overwrite = questdlg('Overwrite position data?', 'Overwrite', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'No')
        set(handles.el_end, 'String', num2str(handles.app.elPositionData(handles.numSeries,3))); 
        return
    end
end  
handles = updateHRIR(hObject,handles);


% --- Executes during object creation, after setting all properties.
function el_end_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function outChannelEdit_Callback(hObject, eventdata, handles)
currentValue = str2double(get(handles.outChannelEdit, 'String'));
if (currentValue < 1 || isnan(currentValue))
    disp('Invalid Entry; outchl will default to 1');
    handles.app.outchl = 1;
    set(handles.outChannelEdit, 'String', num2str(1));
elseif (currentValue > handles.maxOuts)
    handles.app.outchl = handles.maxOuts;
    set(handles.outChannelEdit, 'String', num2str(handles.maxOuts));
elseif (currentValue ~= round(currentValue))
    handles.app.outchl = floor(currentValue);
    set(handles.outChannelEdit, 'String', num2str(handles.app.outchl));
else
    handles.app.outchl = currentValue;
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function outChannelEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Function to measure a single position
    function handles = measurePosition(hObject, handles)
if (handles.app.currID<=size(handles.data,2))
        overwrite = questdlg('Overwrite measurement?', 'Overwrite', 'Yes', 'No', 'Yes');
        if strcmp(overwrite, 'No')
            return;
        end;
end;

if (get(handles.savewav_checkbox, 'Value'))
    savewav.az = str2num(get(handles.az_edit, 'String'));
    savewav.el = str2num(get(handles.el_edit, 'String'));
    savewav.dist = str2num(get(handles.dist_edit, 'String'));
    savewav.ID = handles.app.currID;
else savewav = 0;
end;

%measure
disp('outchl: ');
disp(handles.app.outchl);

recLen = handles.app.irLength+handles.specs.sampleRate*0.5;
% if (handles.app.irLength > handles.specs.sampleRate)
%     recLen = handles.app.irLength+handles.specs.sampleRate; % record an additional second more than we need
% else
%     recLen = handles.specs.sampleRate*2;
% end

inChannelArray = [1:handles.app.numInputChls];

if ( strcmpi (handles.specs.signalType, 'Sine Sweep') || strcmpi (handles.specs.signalType, 'Sine-Sweep'))
    y = sweepZap_selectch(handles.app.outchl,handles.app.numInputChls,handles.specs.sampleRate,handles.app.sigLength,recLen,handles.app.numPlays, 20,handles.specs.sampleRate/2, .6, savewav);
elseif ( strcmpi (handles.specs.signalType, 'MLS') )
    mlsLen = nextpow2(handles.app.sigLength * handles.specs.sampleRate + 1)
    y = MlsZap_selectch(handles.app.outchl,inChannelArray,handles.specs.sampleRate,mlsLen,recLen,handles.app.numPlays,.6,savewav); 
elseif ( strcmpi (handles.specs.signalType, 'Golay Codes') || strcmpi (handles.specs.signalType, 'Golay-Codes'))
    golayLen = nextpow2(handles.app.sigLength * handles.specs.sampleRate + 1)
    y = golayZap_selectch(handles.app.outchl, inChannelArray, handles.specs.sampleRate,golayLen,recLen,handles.app.numPlays,1,.6,savewav);
end;
% mlsLen = nextpow2(handles.app.sigLength * handles.specs.sampleRate + 1);
% y = MlsZap_selectch(handles.app.outchl,inChannelArray,handles.specs.sampleRate,mlsLen,recLen,handles.app.numPlays, 0.6,savewav);
% pause(1)
% y2 = golayZap_selectch(handles.app.outchl, inChannelArray, handles.specs.sampleRate,mlsLen,recLen,handles.app.numPlays,1, 0.6,savewav);
% pause(1)


offset = 100;

[junk, ind1]= max(abs(y));
firstIRind = min(ind1);

% [junk, ind2]= max(abs(y2));
% firstIRind2 = min(ind2);



% if firstIRind-offset+handles.app.irLength-1 > recLen
%     warning('LOW SNR on Sine Sweep - RETAKE MEASUREMENT');
%     diff = firstIRind-offset+handles.app.irLength-1 - recLen;
%     handles.data(handles.app.currID).IR = [ y(firstIRind-offset:end, :); zeros(diff, handles.app.numInputChls) ];
% else
%     handles.data(handles.app.currID).IR = y(firstIRind-offset:firstIRind-offset+handles.app.irLength-1, :);
% end

if firstIRind-offset+handles.app.irLength-1 > recLen
    warning('LOW SNR on MLS - RETAKE MEASUREMENT');
    diff = firstIRind-offset+handles.app.irLength-1 - recLen;
    handles.data(handles.app.currID).IR = [ y(firstIRind-offset:end, :); zeros(diff, handles.app.numInputChls) ];
else
    handles.data(handles.app.currID).IR = y(firstIRind-offset:firstIRind-offset+handles.app.irLength-1, :);
end

% if firstIRind2-offset+handles.app.irLength-1 > recLen
%     warning('LOW SNR on Golay Codes - RETAKE MEASUREMENT');
%     diff = firstIRind2-offset+handles.app.irLength-1 - recLen;
%     handles.data(handles.app.currID).IR_golayCodes = [ y2(firstIRind2-offset:end, :); zeros(diff, handles.app.numInputChls) ];
% else
%     handles.data(handles.app.currID).IR_golayCodes = y2(firstIRind2-offset:firstIRind2-offset+handles.app.irLength-1, :);
% end

handles.data(handles.app.currID).azimuth = str2double(get(handles.az_edit, 'String'));
handles.data(handles.app.currID).elevation = str2double(get(handles.el_edit, 'String'));
handles.data(handles.app.currID).distance = str2double(get(handles.dist_edit, 'String'));
handles.data(handles.app.currID).ITD = 0; % ITD parameter for marl standard, but it's zero because ScanIR's HRIRs include delay
handles.data(handles.app.currID).comments = get(handles.comments_edit, 'String');

if (handles.app.currID == size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'on');
end

plotresponse(handles);
guidata(hObject, handles);

% when we go forward
function handles = goForward(hObject, handles)
%disp('GO FORWARD');

if (handles.app.currID<=size(handles.data,2))
   handles.app.currID = handles.app.currID+1;
end

if (handles.app.currID == 2)
    set(handles.backButton, 'Enable', 'on');
end

% reactivate hrir position panel if you've moved past sorted data
if ( (handles.app.inMode == 2) && (handles.app.sorted == 1) && ( handles.app.currID - 1 == handles.sizeLoadedData ) )
    handles = updateHRIR(hObject,handles);
    set(handles.hrir_panel, 'Visible', 'on');
end

if (handles.app.inMode == 2) % in HRIR mode
    if ( handles.app.currID - 1 == handles.app.seriesInfo(handles.numSeries) ) % moving forward to another series (may or may not be new)
        handles.numSeries = handles.numSeries + 1;
%         disp('GOING FORWARD TO ANOTHER SERIES');
%         disp('numSeries:'); disp(handles.numSeries);
%         disp('SeriesInfo:'); disp(handles.app.seriesInfo);
        
        if ( (handles.app.currID > size(handles.data,2) ) &&(handles.numSeries ~= length(handles.app.npositions)) ) % going forward to a new series         
            handles = newSeries(hObject, handles);
        end
        set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
        set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
        set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
        set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
        set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
        set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
        set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
    end
    
    if (handles.app.currID > size(handles.data,2)) % when we're going forward to a new recording index
        set(handles.forwardButton, 'Enable', 'off');
        handles = calcModID(hObject, handles);
        %disp('modID:'); disp(handles.modID);
       
        if (handles.app.outMode == 1) % single channel output mode
            elIndex = ceil(handles.modID/length(handles.hrir_az));

            if (mod(handles.modID,length(handles.hrir_az)) == 0)
                azIndex = length(handles.hrir_az);
            else
                azIndex = mod(handles.modID,length(handles.hrir_az));
            end
        elseif (handles.app.outMode == 2 ) % multichannel output mode
            azIndex = handles.modID;   
            elIndex = handles.modID;
        end
        currentAz = handles.hrir_az(azIndex);
        currentEl = handles.hrir_el(elIndex);
        set(handles.az_edit, 'String', num2str(currentAz));
        set(handles.el_edit, 'String', num2str(currentEl));
    end
else % in Mono or Multi-input mode

    if (handles.app.currID > size(handles.data,2)) % when we're going forward to a new position
       set(handles.forwardButton, 'Enable', 'off');
    end
end

guidata(hObject, handles);
updatefields(handles);


% when we go backward
function handles = goBackward(hObject, handles)
%disp('GO BACKWARD');
if (handles.app.currID>1)
    handles.app.currID = handles.app.currID-1;
end

if (handles.app.currID == 1)
   set(handles.backButton, 'Enable', 'off');
end

if (handles.app.currID <= size(handles.data,2))
    set(handles.forwardButton, 'Enable', 'on')
end

% deactivate hrir position panel if you've moved into sorted data
if ( (handles.app.inMode == 2 ) && (handles.app.sorted == 1) && ( handles.app.currID == handles.sizeLoadedData ) )
    set(handles.hrir_panel, 'Visible', 'off');
end

if ( (handles.numSeries ~= 1) && (handles.app.inMode == 2) && (handles.app.currID == handles.app.seriesInfo(handles.numSeries-1)) )
    %disp('GOING BACK TO A NEW SERIES');
    handles.numSeries = handles.numSeries - 1;
    %disp('Az position data:');
    %disp(handles.app.azPositionData);
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID-(handles.app.npositions(handles.numSeries)-1)) '-' num2str(handles.app.currID)]);
    set(handles.az_start,'String', num2str(handles.app.azPositionData(handles.numSeries,1)));
    set(handles.az_interval,'String', num2str(handles.app.azPositionData(handles.numSeries,2)));
    set(handles.az_end,'String', num2str(handles.app.azPositionData(handles.numSeries,3)));
    set(handles.el_start,'String', num2str(handles.app.elPositionData(handles.numSeries,1)));
    set(handles.el_interval,'String', num2str(handles.app.elPositionData(handles.numSeries,2)));
    set(handles.el_end,'String', num2str(handles.app.elPositionData(handles.numSeries,3)));
end

guidata(hObject, handles);
updatefields(handles);


function handles = newSeries(hObject,handles)
% going forward to a new series
%disp('NEW SERIES!');
% update npositions and seriesInfo
if (handles.app.outMode == 1) % mono output mode
    handles.app.npositions(handles.numSeries) = length(handles.hrir_az) * length(handles.hrir_el);
    disp('npos array:'); disp(handles.app.npositions);
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
    %disp('seriesInfo:');
    %disp(handles.app.seriesInfo);
    set(handles.hrir_panel,'Title',['HRIR Locations for ' num2str(handles.app.currID) '-' num2str(handles.app.currID + handles.app.npositions(handles.numSeries) - 1)]);
elseif (handles.app.outMode == 2) % multichannel output mode
    handles.app.npositions(handles.numSeries) = handles.app.npositions(handles.numSeries-1);
    if (handles.numSeries == 1)
        handles.app.seriesInfo(1) = handles.app.npositions(handles.numSeries);
    else
        handles.app.seriesInfo(handles.numSeries) = handles.app.npositions(handles.numSeries) + handles.app.seriesInfo(handles.numSeries-1);
    end
end

handles.app.azPositionData(handles.numSeries,1) = handles.app.azPositionData(handles.numSeries-1,1);
handles.app.azPositionData(handles.numSeries,2) = handles.app.azPositionData(handles.numSeries-1,2);
handles.app.azPositionData(handles.numSeries,3) = handles.app.azPositionData(handles.numSeries-1,3);
handles.app.elPositionData(handles.numSeries,1) = handles.app.elPositionData(handles.numSeries-1,1);
handles.app.elPositionData(handles.numSeries,2) = handles.app.elPositionData(handles.numSeries-1,2);
handles.app.elPositionData(handles.numSeries,3) = handles.app.elPositionData(handles.numSeries-1,3);

%disp('Az position data:');
%disp(handles.app.azPositionData);

currentAz = handles.hrir_az(1);
currentEl = handles.hrir_el(1);
set(handles.az_edit, 'String', num2str(currentAz));
set(handles.el_edit, 'String', num2str(currentEl));
guidata(hObject,handles);


function handles = calcModID(hObject, handles)
if (handles.numSeries == 1)
    handles.modID = mod( handles.app.currID, handles.app.npositions(handles.numSeries)); % ID within the given series
else
    handles.modID = mod( (handles.app.currID-handles.app.seriesInfo(handles.numSeries-1)), handles.app.npositions(handles.numSeries)); % ID within the given series
end
if (handles.modID == 0)
   handles.modID = handles.app.npositions(handles.numSeries);
end


% --- Executes on button press in sort_checkbox.
function sort_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to sort_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sort_checkbox


% --- Executes on button press in wrap_checkbox.
function wrap_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to wrap_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wrap_checkbox
