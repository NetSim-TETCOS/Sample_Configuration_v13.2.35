:: ************************************************************************************
:: * Copyright (C) 2019                                                               *
:: * TETCOS, Bangalore. India                                                         *
:: *                                                                                  *
:: * Tetcos owns the intellectual property rights in the Product and its content.     *
:: * The copying, redistribution, reselling or publication of any or all of the       *
:: * Product or its content without express prior written consent of Tetcos is        *
:: * prohibited. Ownership and / or any other right relating to the software and all  *
:: * intellectual property rights therein shall remain at all times with Tetcos.      *
:: *                                                                                  *
:: * Author:  Kundrapu Dilip Kumar                                                     *
:: * Date:    21-10-2019                                                                              *
:: * ---------------------------------------------------------------------------------*

@ECHO OFF

setlocal
REM - NetSim will not ask for key press after the simulation
SET NETSIM_AUTO=1 
REM - Windows won't pop-up GUI screen for error reporting on exception
SET NETSIM_ERROR_MODE=1 


REM - This will restrict the AutoTest.bat to open via double clicking (without CLI arguments)
if [%1] == [] (
	if [%2] == [] (
		exit
	)
)

REM - Arguments from user input
SET APP_PATH=%1
SET LICENSE=%2

setlocal EnableDelayedExpansion

if exist results.txt (
	DEL results.txt
)

if exist appMetrics.txt (
	DEL appMetrics.txt
)

if exist compare.txt (
	DEL compare.txt
)

if exist "%Temp%\NetSimCoreAuto" (
	RD /Q /S "%Temp%\NetSimCoreAuto"
)

REM - Creates a folder in the %TEMP%
MD "%Temp%\NetSimCoreAuto"

REM - For all the directories/sub-directories which contain .netsim file
for /r %%i in (*.netsim) do (

	COPY "%%~dpi" "%Temp%\NetSimCoreAuto"	
	
	REM - If the Metrics.xml doesn't exist in the Test file then the simulation is skipped
	IF exist "%%~dpi\Metrics.xml" (
		DEL "%Temp%\NetSimCoreAuto\Metrics.xml"

		REM - Runs the simulation 
		START "" /w /MIN %APP_PATH%\NetSimCore.exe -apppath %APP_PATH% -iopath "%Temp%\NetSimCoreAuto" -license %LICENSE%

		REM - If the Metrics.xml doesn't exist after simulation then the simulation is crashed
		IF exist "%Temp%\NetSimCoreAuto\Metrics.xml" (	
		
			REM - Compares the Metrics.xml files  
			C:\windows\system32\FC "%%~dpi\Metrics.xml" "%Temp%\NetSimCoreAuto\Metrics.xml" > "%Temp%\NetSimCoreAuto\diff.txt"
			
			REM - If the previous command gives an errorlevel equal to or greater
			IF errorlevel 1 (
				
				REM - This loop skips the comparision on plots section in Metrics.xml
				SET /A plotError=0
				SET /A errorCounter=0
				FOR /F "usebackqtokens=1-4delims=<=>" %%a IN ("%Temp%\NetSimCoreAuto\diff.txt") DO (
					echo "%%~a"|C:\windows\system32\find "***** " >nul
					if errorlevel 1 (
						IF "%%~b"=="MENU Name" (
							SET /A plotCounter=!plotCounter! + 1
						) ELSE (
							IF "%%~b"=="PLOT data_file_name" (
								SET /A plotCounter=!plotCounter! + 1
								SET /A plotError=!plotError! + 1
							) ELSE (
								IF "%%~b"=="/MENU" (
									SET /A plotCounter=!plotCounter! + 1
								) ELSE (
									IF "%%~a"=="*****" (		
										IF !plotCounter!==3 (
											IF NOT !plotError!==0 (
												IF !errorCounter!==1 (
													SET status=plotDifference
												)
											)
										)
									)ELSE (
										IF !plotError!==0 (
											IF NOT !errorCounter!==0 (
												SET status=difference
											)
											SET /A errorCounter=!errorCounter! + 1
										)
									)
								)
							)
						)
					) else (
						SET /A plotCounter=0
					)
				)

				IF "!status!"=="difference" (
					echo %%~dpi - Difference Found >> results.txt				
				) ELSE (
					IF "!status!"== "plotDifference" (
						echo %%~dpi - Plot Difference >> results.txt									
					)
				)

			) ELSE (
				echo %%~dpi - Success >> results.txt
			)

			REM - The differences of diff.txt is appended to compare.txt
			TYPE "%Temp%\NetSimCoreAuto\diff.txt" >> compare.txt
			echo ------------------------------------------------------------------------------------------------------------ >> compare.txt

			REM - Writes the throughput of all the applications to a file
			SET flag=false
			SET /A application=0
			FOR /f "usebackqtokens=1-4delims=<=>" %%a IN ("%Temp%\NetSimCoreAuto\Metrics.xml") DO (	
				IF "%%~b"=="TABLE name" (
					IF "%%~c"=="Application_Metrics" (
						SET flag=true
					)
				)
				
				IF "!flag!"=="true" (
					IF "%%~b"=="TR" (
						SET /A application=!application! + 1
						SET /A count=0
					)
				)
				
				IF NOT !application!==0 (
					IF "%%~b"=="TC Value" (
						SET /A count=!count!+1
						IF !count!==2 (
							echo %%~dpi - %%~c >> appMetrics.txt
						)
						IF !count!==9 (
							echo "Throughput(Mbps) = %%~c" >> appMetrics.txt
						)
						IF !count!==10 (
							echo "Delay(microSec) = %%~c" >> appMetrics.txt
						)
					)
				)

				IF "%%~b"=="/TABLE" (
						SET flag=false
						SET /A application=0
						SET /A count=0
				)
			)
			echo ------------------------------------------------------------------------------------------------------------ >> appMetrics.txt

		) ELSE (
				  echo %%~dpi - Crashed >> results.txt
			   )
		
		REM - Close if Wireshark.exe is open
		C:\windows\system32\TASKLIST /fi "IMAGENAME EQ Wireshark.exe" | C:\windows\system32\find ":" > nul
		IF errorlevel 1 (
			C:\windows\system32\TASKKILL /f /im "Wireshark.exe"
		)

		echo ----------------------------------------------------------------------------

	) ELSE (
		echo %%~dpi - Missing 'Metrics.xml' >> results.txt
	)
	
	REM - Delete all the files from NetSimCoreAuto
	DEL /Q "%Temp%\NetSimCoreAuto"
)

REM - Removes the folder from the %TEMP%
RD /Q /S "%Temp%\NetSimCoreAuto"
PAUSE
endlocal