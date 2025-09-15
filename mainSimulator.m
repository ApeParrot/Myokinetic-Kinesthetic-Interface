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

state.qpos(3) = 0.05;

% Set the state of the simulated system. The user is expected to fill out
% the data structure mjState. The size parameters "nq", "nv" and "na" must
% match the corresponding sizes of the model being simulated; otherwise
% error mjCOM_BADSIZE is returned. The correct size parameters can be
% obtained using mj_get_state or mj_info. The time field is ignored.
% For the MATLAB interface, the necessary structure can be created using
% the struct command:
% >> state = struct('nq',7, 'nv',6, 'na',0, 'time',0, 'qpos',zeros(7,1), 'qvel',zeros(6,1), 'act',[])

% state = struct('nq',nq, 'nv',nv, 'na',na, 'time',0, 'qpos',qpos, ...
%     'qvel',qvel, 'act',state.act)

mj_set_state(state)

% hx_close