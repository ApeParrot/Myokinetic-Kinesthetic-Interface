This repo contains data and codes for data analysis of the paper: Masiero, et al. "Coordinated hand movement sensation revealed through an implanted magnetic prosthetic kinesthetic interface."

To run the data analysis code the following dependencies are required:
- MATLAB R2020b or more recent (may be compatible even with older versions)
- Python 3.9 (may be compatible even with older versions)

MUJOCO

MuJoCo is an advanced simulator for multi-body dynamics with contact. It was developed by Roboti LLC and was available as a commercial product from 2015 to 2021.

From October 2021, DeepMind has acquired MuJoCo and has made it freely available as an open source project under the Apache 2.0 license. The updated homepage is mujoco.org. The software distribution is available at github.com/deepmind/mujoco.

Installation of Mujoco can be performed with the following Python commands:

python.exe -m pip install --upgrade pip

pip install mujoco



MUJOCO HAPTIX

MuJoCo HAPTIX is a free end-user product (https://roboti.us/book/haptix.html). It relies on the legacy commercial MuJoCo Pro library for simulation and visualization, and extends it with a GUI as well as optional real-time motion capture. User code can interact with it via a socket API. This API does not impose restrictions in terms of simulation or visualization, however it lacks the efficiency and flexibility of the shared-memory API which is available when MuJoCo Pro is linked directly to user code.

Mujoco Haptix is downloaded directly from here:
https://www.roboti.us/download.html

The software distribution contains the necessary communication libraries for C/C++ and for MATLAB, in directories "apicpp" and "apimex" respectively. To use the C/C++ API, include "haptix.h" in your code and link with the stub library "mjhaptix_user.lib" which will in turn load the actual library "mjhaptix_user.dll" at runtime. To use the MATLAB API, add the directory "apimex" to the MATLAB path. Note however that the simple flavor of the MATLAB API is common to MuJoCo and Gazebo, thus the corresponding .m files have the same names and calling conventions. If you are installing the API for both simulators on the same machine, be careful to set the path to the simulator you want to work with.

The MATLAB API is a straightforward adaptation of the C/C++ API. Its software architecture however is somewhat unusual from a MATLAB perspective. The C/C++ API is contained in a single dynamic library. In contrast, the usual mode of operation in MATLAB would be to have a separate .m or .mex file for each API function. The problem with the latter approach is that we are using a TCP/IP socket connection, which is established at the beginning of the session and then needs to be maintained. Such maintenance is difficult to achieve if we were to use separate .m or .mex files for each API function, especially since the socket handle created in the underlying C++ code is not a valid MATLAB object. One way around this is to rely on MATLAB's native Java sockets instead - which we have used previously, but they have proven to be slower and less reliable compared to our C++ implementation.

Thus the MATLAB API to MuJoCo HAPTIX is based on a single mex file "mjhx.mexw64". This file automatically locks itself within the MATLAB workspace when a connection to the simulator is established, and automatically unlocks itself when the connection is closed. The user can call it directly (as summarized in the built-in help) but we also provide .m wrappers matching the C/C++ syntax to the extent possible.

Unlike the C/C++ API where most functions return success or error codes, in the MATLAB API errors are generated using MATLAB's standard error handling mechanism, i.e. error messages are printed in the command window and the function terminates.