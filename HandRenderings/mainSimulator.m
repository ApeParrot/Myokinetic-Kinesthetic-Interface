clc
clear
close all
%%

addpath(genpath("mjhaptix150"))

%% Establish Connection to the simulator

% First Step:
% open mjhaptix.exe

% Second Step:
% load MPL.xml model

disp("Did you perform First and Second step? If Yes, press any key.")
pause

% Establish socket connection to the simulator.
% The port argument is ignored in MuJoCo (since we use a fixed port)
% If the user code is running on the simulation computer, set host to NULL
% (in C only) or pass the empty string to specify the local host.
port = [];
host = '';

hx_close
hx_connect(host, port)
% This function not only provides useful information to the user, but also
% saves the result internally and later uses it to determine the sizes of
% the variable-size arrays in hxSensor and hxCommand. Thus it must be
% called when the connection to the simulator is first established, and
% when a different model is loaded.
info = hx_robot_info;

%% Functions Tests

% Get the mjState data structure containing the simulation state.
state = mj_get_state
% Get the mjControl data structure containing the vector of control 
% signals acting on the actuators.
control = mj_get_control
% Get the mjApplied data structure containing user-specified applied 
% forces in generalized and Cartesian coordinates.
applied = mj_get_applied
% Get the mjOneBody data structure containing detailed information about a 
% single body. Note that the MATLAB function takes the body id as an 
% argument.
bodyid = 1
onebody = mj_get_onebody(bodyid)
% Get the mjMocap data structure containing the positions and 
% orientations of the mocap bodies defined in the model.
mocap = mj_get_mocap
% Get the mjDynamics data structure containing the main output of the 
% forward dynamics.
dynamics = mj_get_dynamics
% Get the mjSensor data structure containing the sensor data array.
sensor = mj_get_sensor
% Get the mjBody data structure containing the positions and orientations 
% of all bodies.
body = mj_get_body
% Get the mjGeom data structure containing the positions and 
% orientations of all geoms.
geom = mj_get_geom
% Get the mjSite data structure containing the positions and orientations
% of all sites.
site = mj_get_site
% Get the mjTendon data structure containing the lengths and velocities
% of all tendons.
tendon = mj_get_tendon
% Get the mjActuator data structure containing the lengths, velocities and
% forces of all actuators.
actuator = mj_get_actuator
% Get the mjForce data structure containing all generalized forces acting
% on the system.
force = mj_get_force
% Get the mjContact data structure containing information about all active
% contacts.
contact = mj_get_contact

nq = state.nq;
nv = state.nv;
na = state.na;

qpos = zeros(nq,1);
qvel = zeros(nv,1);
qpos(1) = 0;



% Description of the simulators DoFs:
% qpos(1:3) = hand position in space
% qpos(4:6) = hand orientation in space
% qpos(7) weird or does not move
% qpos(8:10) = wrist degrees of freedom (pron/sup, rad/uln dev, flex/ext)
% qpos(11) = thumb ab/add
% qpos(12) = thumb MCP flex
% qpos(13) = thumb PIP flex
% qpos(14) = thumb DIP flex
% qpos(15) = index ab/add
% qpos(16) = index MCP flex
% qpos(17) = index IP flex
% qpos(18) = index DIP flex
% qpos(19) = middle MCP flex
% qpos(20) = middle IP flex
% qpos(21) = middle DIP flex
% qpos(22) = ring ab/add
% qpos(23) = ring MCP flex
% qpos(24) = ring IP flex
% qpos(25) = ring DIP flex
% qpos(26) = pinky ab/add
% qpos(27) = pinky MCP flex
% qpos(28) = pinky IP flex
% qpos(29) = pinky DIP flex


% Set the state of the simulated system. The user is expected to fill out
% the data structure mjState. The size parameters "nq", "nv" and "na" must
% match the corresponding sizes of the model being simulated; otherwise
% error mjCOM_BADSIZE is returned. The correct size parameters can be
% obtained using mj_get_state or mj_info. The time field is ignored.
% For the MATLAB interface, the necessary structure can be created using
% the struct command:
% >> state = struct('nq',7, 'nv',6, 'na',0, 'time',0, 'qpos',zeros(7,1), 'qvel',zeros(6,1), 'act',[])

% Easiest way is to update qpos directly from previous state variable read
% with the mj_get_state function


% Import the CSV as a table
T = readtable('joint_angle_second_last.csv');

% Subtract Pi and take absolute value for both columns
T.Second_Angle = abs(T.Second_Angle - pi);
T.Last_Angle   = abs(T.Last_Angle   - pi);

% Get unique participant sessions from the table
unique_sessions = unique(T.Session);

% Prompt user to select a session from the list
[idx_session, tf] = listdlg('PromptString', 'Select a participant session:', ...
                           'SelectionMode', 'single', ...
                           'ListString', unique_sessions);

if ~tf
    error('No session selected. Exiting.');
end
selected_session = unique_sessions{idx_session};

% Filter the table for the selected session
T_selected = T(strcmp(T.Session, selected_session), :);

% Indices in state.qpos to replace (as given)
qpos_idx = [12 13 14 16 17 18 19 20 21 23 24 25 27 28 29];
qpos_idx = qpos_idx - 7;
% Prompt user to select time point: 1=Second Angle, 2=Last Angle
selection = input('Select the time point to use (1=Second Angle, 2=Last Angle): ');

if selection == 1
    vals = T_selected.Second_Angle(1:15);  % Assuming first 15 entries correspond to joints
elseif selection == 2
    vals = T_selected.Last_Angle(1:15);
else
    error('Input must be 1 or 2');
end

% Initialize state.qpos if not existing
if ~exist('state', 'var') || ~isfield(state, 'qpos')
    state.qpos = zeros(30, 1); % Adjust size as needed
end

% Assign selected values to state.qpos at specified indices
for k = 1:numel(qpos_idx)
    %state.qpos(qpos_idx(k)) = vals(k);
    control.ctrl(qpos_idx(k)) = vals(k);
end

% Display updated qpos values
disp('Updated state.qpos values at specified indices:');
disp(state.qpos(qpos_idx));


%state.qpos(11) = 1.55;
control.ctrl(4) = 1.30;

%state.qpos(11) = 0.93;

%mj_set_state(state) % instead, use... set_control 
mj_update(control) % instead, use... set_control 

% mj_reset(-1)

% hx_close