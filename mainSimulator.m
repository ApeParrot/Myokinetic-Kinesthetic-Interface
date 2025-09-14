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

% Establish socket connection to the simulator.
% The port argument is ignored in MuJoCo (since we use a fixed port)
% If the user code is running on the simulation computer, set host to NULL
% (in C only) or pass the empty string to specify the local host.
port = [];
host = '';

hx_connect(host, port)
info = hx_robot_info;
% 
% disp("etto")

%%
hx_close