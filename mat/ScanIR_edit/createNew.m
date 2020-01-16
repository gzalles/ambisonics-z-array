function varargout = createNew(varargin)
% CREATENEW M-file for createNew.fig
%      CREATENEW by itself, creates a new CREATENEW or raises the
%      existing singleton*.
%
%      H = CREATENEW returns the handle to a new CREATENEW or the handle to
%      the existing singleton*.
%
%      CREATENEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATENEW.M with the given input arguments.
%
%      CREATENEW('Property','Value',...) creates a new CREATENEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createNew

% Last Modified by GUIDE v2.5 05-Oct-2011 17:30:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createNew_OpeningFcn, ...
                   'gui_OutputFcn',  @createNew_OutputFcn, ...
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

% --- Executes just before createNew is made visible.
function createNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createNew (see VARARGIN)

% Choose default command line output for createNew
handles.output.out = 'Created a new IR recording session';

handles.inMode = 1;  % starts as mono IR
handles.outMode = 1; % 1 channel output
handles.signalType = 'Sine Sweep'; % sine sweep
handles.sigLength = 1; % 1 second
handles.irLength = 44100; % 1 second IR
handles.sampleRate = 44100; 
handles.numInputChls = 1;
handles.numOutputChls = 1;
handles.numPlays = 1;

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

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;


set(handles.figure1, 'Colormap', IconCMap);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes createNew wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = createNew_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in createButton.
function createButton_Callback(hObject, eventdata, handles)

handles.output.inMode = handles.inMode;
handles.output.signalType = handles.signalType;
handles.output.sigLength = handles.sigLength;
handles.output.irLength = updateIRLength(hObject,handles);
handles.output.sampleRate = handles.sampleRate;
handles.output.numInputChls = handles.numInputChls;
handles.output.numOutputChls = handles.numOutputChls;
handles.output.outMode = handles.outMode;
handles.output.maxOuts = handles.maxOuts;
handles.output.numPlays = handles.numPlays;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output.inMode = handles.inMode;
handles.output.signalType = handles.signalType;
handles.output.sigLength = handles.sigLength;
handles.output.irLength = updateIRLength(hObject, handles);
handles.output.sampleRate = handles.sampleRate;
handles.output.numInputChls = handles.numInputChls;
handles.output.numOutputChls = handles.numOutputChls;
handles.output.outMode = handles.outMode;
handles.output.maxOuts = handles.maxOuts;
handles.output.numPlays = handles.numPlays;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function createSigLength_Callback(hObject, eventdata, handles)
% hObject    handle to createSigLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sigLengthEdit = str2double(get(handles.createSigLength, 'String'));
if (sigLengthEdit <= 0 || isnan(sigLengthEdit)) % at least one (non-string) input channel
    disp('Invalid entry; sigLength will default to 1 second');
    handles.sigLength = 1;
    set(handles.createSigLength, 'String', num2str(1));
elseif (sigLengthEdit > 10) % must be <= 10 seconds long
    disp('Maximum sigLength is 10 seconds');
    handles.sigLength = 10;
    set(handles.createSigLength, 'String', num2str(10));
else
    handles.sigLength = sigLengthEdit;
end

sigIndex = get(handles.createSignal, 'Value');
if (sigIndex ~= 1) % extra check when using MLS or Golay Codes
    
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSigLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to createSigLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function createNuminchls_Callback(hObject, eventdata, handles)
inChannelEdit = str2double(get(handles.createNuminchls, 'String'));
if (inChannelEdit < 1 || isnan(inChannelEdit)) % at least one (non-string) input channel
    disp('Invalid entry; numInputChls will default to 1');
    handles.numInputChls = 1;
    set(handles.createNuminchls, 'String', num2str(1));
elseif (inChannelEdit > handles.maxIns) % less than the maximum amount of channels
    handles.numInputChls = handles.maxIns;
    set(handles.createNuminchls, 'String', num2str(handles.maxIns));
elseif (inChannelEdit ~= round(inChannelEdit))
    handles.numInputChls = floor(inChannelEdit);
    set(handles.createNuminchls, 'String', num2str(handles.numInputChls) );
else
    handles.numInputChls = inChannelEdit;
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createNuminchls_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function createIRLength_Callback(hObject, eventdata, handles)


sigIndex = get(handles.createSignal, 'Value');
if (sigIndex ~= 1) % extra check when using MLS or Golay Codes
    irLength = updateIRLength(hObject, handles);
    pow2Len = nextpow2(handles.sigLength * handles.sampleRate + 1);
    handles.sigLength
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createIRLength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createSrate.
function createSrate_Callback(hObject, eventdata, handles)

srates = [22050 44100 48000 96000];
srate_i = get(handles.createSrate, 'Value');
handles.sampleRate = srates(srate_i);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSrate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createSignal.
function createSignal_Callback(hObject, eventdata, handles)

sigIndex = get(handles.createSignal, 'Value');
if (sigIndex == 1)
    handles.signalType = 'Sine Sweep';
elseif (sigIndex == 2)
    handles.signalType = 'MLS';
elseif (sigIndex == 3)
    handles.signalType = 'Golay Codes';
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSignal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createMode.
function createMode_Callback(hObject, eventdata, handles)

handles.inMode = get(handles.createMode, 'Value');

if (handles.inMode == 1) % Mono IR
    set(handles.outputModeLabel, 'Visible', 'off');
    set(handles.outputModePopup, 'Visible', 'off');
    set(handles.numInputLabel, 'Visible', 'off');
    set(handles.createNuminchls, 'Visible', 'off');
    handles.numInputChls = 1;
    handles.numOutputChls = 1;
    set(handles.text8, 'Visible', 'on');
    set(handles.text8, 'String', 'seconds');  % measure IR length in seconds for room acoustics
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
    set(handles.NumOutput_txt, 'Visible', 'off');
    set(handles.NumOutputEdit, 'Visible', 'off');
    set(handles.timeUnitsPopup, 'Visible', 'off');
elseif (handles.inMode == 2) % HRIR
    set(handles.outputModeLabel, 'Visible', 'on');
    set(handles.outputModePopup, 'Visible', 'on');
    set(handles.numInputLabel, 'Visible', 'off');
    set(handles.createNuminchls, 'Visible', 'off'); 
    handles.numInputChls = 1; % change this to 1 if you want to test HRIR mode on a mono input computer
    set(handles.text8, 'Visible', 'on');
    set(handles.text8, 'String', 'samples'); % measure HRIR length in samples
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    set(handles.timeUnitsPopup, 'Visible', 'off');
elseif (handles.inMode == 3) % Multichannel IR
    set(handles.outputModeLabel, 'Visible', 'off');
    set(handles.outputModePopup, 'Visible', 'off');
    set(handles.numInputLabel, 'Visible', 'on');
    set(handles.createNuminchls, 'Visible', 'on');
    handles.numInputChls = str2double(get(handles.createNuminchls, 'String'));
    handles.numOutputChls = 1;
    set(handles.text8, 'Visible', 'off');
    set(handles.timeUnitsPopup, 'Value', 1);
    set(handles.timeUnitsPopup, 'Visible', 'on');
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    set(handles.NumOutput_txt, 'Visible', 'off');
    set(handles.NumOutputEdit, 'Visible', 'off');
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function createMode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in outputModePopup.
function outputModePopup_Callback(hObject, eventdata, handles)
handles.outMode = get(handles.outputModePopup, 'Value');

if (handles.outMode == 1)
    handles.numOutputChls = 1;
    set(handles.NumOutput_txt, 'Visible', 'off');
    set(handles.NumOutputEdit, 'Visible', 'off');
elseif (handles.outMode == 2)
    set(handles.NumOutput_txt, 'Visible', 'on');
    set(handles.NumOutputEdit, 'Visible', 'on');
    outEditVal = str2double(get(handles.NumOutputEdit,'String'));
    if (outEditVal <= handles.maxOuts) % makes sure it's not greater than maximum # of outputs
        handles.numOutputChls = outEditVal;
    else
        handles.numOutputChls = handles.maxOuts;
        set(handles.NumOutputEdit, 'String', num2str(handles.maxOuts));
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function outputModePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NumOutputEdit_Callback(hObject, eventdata, handles)
outEditVal = str2double(get(handles.NumOutputEdit,'String'));
if (outEditVal < 1 || isnan(outEditVal))
    disp('Invalid Entry; numOutputChls defaults to 1.');
    handles.numOutputChls = 1;
    set(handles.NumOutputEdit, 'String', num2str(1));
elseif (outEditVal > handles.maxOuts) % makes sure it's not greater than maximum # of outputs
    handles.numOutputChls = handles.maxOuts;
    set(handles.NumOutputEdit, 'String', num2str(handles.numOutputChls));
elseif (outEditVal ~= round(outEditVal)) % no decimal numbers of channels
    handles.numOutputChls = floor(outEditVal);
    set(handles.NumOutputEdit, 'String', num2str(handles.numOutputChls));
else
    handles.numOutputChls = outEditVal;
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function NumOutputEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function createNumPlays_Callback(hObject, eventdata, handles)
% hObject    handle to createNumPlays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playbackEdit = str2double(get(handles.createNumPlays, 'String'));
if (playbackEdit < 1 || isnan(playbackEdit))
    disp('Invalid Entry; numPlays defaults to 1.');
    handles.numPlays = 1;
    set(handles.createNumPlays, 'String', num2str(1));
elseif (playbackEdit > 5)
    disp('Maximum number of plays is 5');
    handles.numPlays = 5;
    set(handles.createNumPlays, 'String', num2str(5));
elseif (playbackEdit ~= round(playbackEdit))
    handles.numPlays = floor(playbackEdit);
    set(handles.createNumPlays, 'String', num2str(handles.numPlays));
else
    handles.numPlays = playbackEdit;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createNumPlays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to createNumPlays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in timeUnitsPopup.
function timeUnitsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to timeUnitsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.timeMode = get(handles.timeUnitsPopup, 'Value');

if (handles.timeMode == 1)
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
elseif (handles.timeMode == 2)
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
end

% --- Executes during object creation, after setting all properties.
function timeUnitsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeUnitsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newIRLength = updateIRLength(hObject, handles)
length_i = get(handles.createIRLength, 'Value');
if (handles.inMode == 1) % if we're in mono IR mode
    IRlengths = 1:9;
    newIRLength = handles.sampleRate * IRlengths(length_i);
elseif (handles.inMode == 2); % HRIR mode
    IRlengths = [128 256 512 1024 2048 4096 8192];
    newIRLength = IRlengths(length_i);
elseif (handles.inMode == 3) % multichannel mode
    val = get(handles.timeUnitsPopup, 'Value');
    if (val == 1) % multichannel: samples
        IRlengths = [128 256 512 1024 2048 4096 8192];
        newIRLength = IRlengths(length_i);
    elseif (val == 2) % multichannel: seconds
        newIRLength = handles.sampleRate * length_i;
    end  
end
guidata(hObject, handles);
