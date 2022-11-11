This batch file is for running batch simulations of NetSim via command line without any user interventions.

There are various methods to run this based on the type of licensing that users use. The different options/methods are explained:

1. Initial setup for running NetSim batch automation
	>> Create a folder named as 'Test Files'
	>> Copy-paste AutoTest.bat to this folder
	>> Also copy the batch of NetSim configuration files folder whereby the individual folder should contain configuration files, metrics file and other input files like Static route/ACL/VLAN/Mobility files.
	>> Example File structure for running 2 experiments via NetSim Batch automation
			Test Files (Folder)
			|_ _ AutoTest.bat (File)
			|_ _ Experiment_1 (Folder)
			|	|_ _ Configuration.netsim (File)
			|	|_ _ metrics.xml (File)
			|	|_ _ StaticRoute1.txt (if required in scenario)
			|	|_ _ ACL/VLAN(if required in scenario)
			|	|_ _ Mobility.txt (if required in scenario)
			|_ _ Experiment_2 (Folder)
				|_ _ Configuration.netsim (File)
				|_ _ metrics.xml (File)
				|_ _ StaticRoute1.txt (if required in scenario)
				|_ _ ACL/VLAN (if required in scenario)
				|_ _ Mobility.txt (if required in scenario)

2. Open Command Prompt (cmd) in administrator mode in the current directory (Test Files).

Method 1: USB Dongle based License 

1. Run the below command which has 2 arguments 
	a. apppath (path to <install-dir>\bin folder) 
	b. port@IP for license checkout
	Syntax: AutoTest.bat <apppath> <5053@license> < nul
	Example: AutoTest.bat "C:\Program Files\NetSim\Standard_v13_1\bin\bin_x64" 5053@192.168.0.9 < nul

2. As soon as you hit Enter, the batch simulation starts running for the Experiments present in the Test Files folder.

Method 2: MAC based / Cloud based License 

1. Run the below command which has 1 argument
	a. apppath (path to <install-dir>\bin folder) 
	Syntax: AutoTest.bat <apppath> <License file path> < nul
   	AutoTest.bat "C:\Program Files\NetSim\Standard_v13_1\bin\bin_x64" "C:\Program Files\NetSim\Standard_v13_1\bin" < nul

2. As soon as you hit Enter, the batch simulation starts running for the Experiments present in the Test Files folder.

Obtaining results

After the completion of simulation of experiments one by one in the Test folder, the batch file generates results in the form of several text files such as
a. appMetrics.txt
b. Compare.txt
c. results.txt

Additional Infromation related to this batch file:

1. '< nul' is to skip the 'Terminate Batch Job(Y/N)?' message in the CMD window.

2. After the completion of all your simulation tests, the compared results will be appended to "results.txt".

3. The "appMetrics.txt" has the throughput(Mbps) and delay(microsec) of all the applications of all the experiments folders.

4. The "compare.txt" file consists of all the differences which were encountered while executing the "autoTest.bat".

5. If you want to stop the simulation tests mid-way, close the CMD window prior to closing NetSim simulation window.

6. If you pass the wrong arguments, quit the simulation by ending the process of 'Windows Command Processor' from Task Manager. 



NOTE: Do not run the AutoTest.bat by double-clicking. Run it only in a CMD window along with 2 arguments.


Pre-requisites:
	        1. SDN (Software Defined Networks) :
		   For all the samples in SND, modify the Interactive_simulation = 'FALSE' in the configuration.netsim file before running AutoTest.bat.
		   Restore back the edits to the originals after your tests.
	
                2. Experiment - 26 (Basic Networking Commands)
		   Modify the Interactive_simulation = 'FALSE' in the configuration.netsim file before running AutoTest.bat.
		   Restore back the edits to the originals after your tests.
                  
Exceptions:  
           	1. VANET
		   The simulation of all the samples will be stuck at "Creating Sumo Pipe".
		   So, remove the VANET folders from the 'Sample Configurations' 
		   before running AutoTest.bat.  
		   Restore back the changes to the originals after your tests.	

			
      