::
:: Draw Batch by Markus Maal
:: Source code and integrated binaries
::

::Initial batch crap
@echo off
setlocal EnableDelayedExpansion EnableExtensions

::Preparation function
:prep
	::Set initial variables
	set "version=1.01"
	set "canvas="
	set "canvb="
	set "canvf="
	set "canvas2="
	set "canvb2="
	set "canvf2="
	set "block=ç"
	set "preblock=Ú"
	set "nextblock=Û"
	set "place=false"
	set "exit=false"
	set "gethelp=false"
	set "openfile=false"
	set "newmap=false"
	set "moveto=w"
	set "color=07"
	set "smartplace=false"
	set "showsplash=true"
	set "showabout=false"
	set "previewonly=false"
	set "c_b=40"
	set "c_f=37"
	set "border=ÉÍ»ºÈ¼"
	set "font=6"
	set "resplash=false"
	set "write_access=true"
	set "skip_load=false"
	set "skip_test=false"
	set "forceokay=false"
	set "nosidepanel=false"
	set "forcedims=false"
	set "altertitle=true"
	set "noprogress=false"
	set "nocolor=false"
	set "reference_height="
	set "reference_width="
	set "args=%*"
	set /a canvas_splice=50
	set /a canvas_height=30
	set "filename=sm_color.txt"
	set "splashname="
	set "args=!args:/= /!"
	if "!args!"=="" goto skipargs
	if not "!args:/?=!"=="!args!" (
		echo.
		echo Draw Batch ^(Multi-color/Two color hybrid^) version %version%
		echo.
		echo./? - Command line syntax
		echo /border:[n] - Select border style ^(1-4^)
		echo /filename:[file] - Specify file to load.
		echo /customsplash:[file] - Use a custom splash screen.
		echo /new - Load an empty canvas instead of a file
		echo /height:[n] - Set canvas height ^(default 30^)
		echo /width:[n] - Set canvas width ^(default 50^)
		echo /nosplash - Disable splash screen
		echo /skipwrite - Skip write access test, assume writable
		echo /skipread - Skip write access test, assume read only
		echo /font:[n] - Set console font type ^(legacy console only^)
		echo /preview - Preview drawing ^(quick preview for .ans files^)
		echo /force - Force open the file and bypass any warnings
		echo /noside - Disable sidepanel
		echo /nocolor - Disable multi-color mode, enable two color mode
		echo /keeptitle - Avoid modifying the title text of the window
		echo /noprogress - Hide progress bars
		echo /forcedims - Force canvas dimensions for the splash screen
		echo /eraseunpacked - Delete every unpacked file
		echo.
		exit /b
	)
	if exist "%1" (
		set "filename=%~nx1"
		if not exist "%~nx1" copy "%1" "%~nx1" 2>nul >nul
		if errorlevel 0 goto skipargs
		if not errorlevel 0 set "filename=sm_color.txt"	
	)
	if exist "%*" set "filename=%*"&set /a canvas_splice=50&goto skipargs
	for %%a in (!args!) do (
		set "arg=%%a"
		if not "!arg:/border:=n!"=="!arg!" (
			if not "!arg:2=n!"=="!arg!" set "border=+-+|++"
			if not "!arg:3=n!"=="!arg!" set "border=ÛÛÛÛÛÛ"
			if not "!arg:4=n!"=="!arg!" set "border=ÚÄ¿³ÀÙ"
		)
		if not "!arg:/filename:=n!"=="!arg!" (
			set "filename=!arg:/filename:=!"
			if not exist "!filename!" (
				if "!args:/new=n!"=="!args!" (
					echo Error: The file specified doesn't exist&echo Draw Batch halted.&exit /b
				)
			)
		)
		if not "!arg:/customsplash:=n!"=="!arg!" (
			set "splashname=!arg:/customsplash:=!"
			if not exist "!splashname!" (
				Echo Error: The splash screen file specified doesn't exist&echo Draw Batch halted.&exit /b
			)
		)
		if not "!arg:/new=n!"=="!arg!" (
			set "skip_load=true"
		)
		if not "!arg:/preview=n!"=="!arg!" (
			set "previewonly=true"
		)
		if not "!arg:/height:=n!"=="!arg!" (
			set /a canvas_height=!arg:/height:=!
			if !canvas_height! LSS 10 (
				Echo Error: The height specified is too small&echo Draw Batch halted.&exit /b
			)
		)
		if not "!arg:/width:=n!"=="!arg!" (
			set /a canvas_splice=!arg:/width:=!
			if !canvas_splice! LSS 15 (
				Echo Error: The width specified is too small&echo Draw Batch halted.&exit /b
			)
		)
		if not "!arg:/font:=n!"=="!arg!" (
			set /a font=!arg:/font:=!
		)
		if not "!arg:/nosplash=n!"=="!arg!" (
			set "showsplash=false"
		)
		if not "!arg:/forcedims=n!"=="!arg!" (
			set "forcedims=true"
		)
		if not "!arg:/skipwrite=n!"=="!arg!" (
			set "skip_test=true"
			set "write_access=true"
		)
		if not "!arg:/skipread=n!"=="!arg!" (
			set "skip_test=true"
			set "write_access=false"
		)
		if not "!arg:/force=n!"=="!arg!" (
			set "forceokay=true"
		)
		if not "!arg:/noside=n!"=="!arg!" (
			set "nosidepanel=true"
		)
		if not "!arg:/noprogress=n!"=="!arg!" (
			set "noprogress=true"
		)
		if not "!arg:/keeptitle=n!"=="!arg!" (
			set "altertitle=false"
		)
		if not "!arg:/bg_test=n!"=="!arg!" (
			echo Press a key...
			bg kbd
			echo The code for pressed key was !ERRORLEVEL!
			exit/b
		)
		if not "!arg:/nocolor=n!"=="!arg!" (
			set "nocolor=true"
			if "%filename%"=="sm_color.txt" call :setsamplebw
		)
		if not "!arg:/eraseunpacked=n!"=="!arg!" (
			for /l %%a in (1 1 2) do (
				if exist ANSI64.DLL del ANSI64.DLL
				if exist ANSI32.DLL del ANSI32.DLL
				ansicon -pu
				if exist ansicon.exe del ansicon.exe
				if exist bg.exe del bg.exe
				if exist sm_color.txt del sm_color.txt
				if exist sample.txt del sample.txt
			)
			if errorlevel 0 echo Extracted files have been erased. Re-launching will now take longer.
			if not errorlevel 0 echo Unable to delete some of the extracted files.
			exit /b
		)
	)
	goto skipargs
	
:setsamplebw
	if not "!filename!"=="sm_color.txt" exit/b
	set "filename=sample.txt"
	exit/b

:skipargs
	set /a randval=%random%
	if "!altertitle!"=="true" title Draw Batch %version%
	echo Starting draw batch...
	if not "!skip_test!"=="true" (
		echo.a>.test%randval%
		if not exist .test%randval% set "write_access=false"
		if exist .test%randval% (
			set /p test=<.test%randval%
			if "!test!"=="a" del .test%randval%
			if not "!test!"=="a" set "write_access=false"
		)
	)
	if not "!previewonly!!forcedims!"=="truefalse" cls&mode 75,34
	set "r_x=!canvas_splice!"
	set "r_y=!canvas_height!"
	if "!forcedims!"=="true" set /a canvas_splice-=24&set /a canvas_height-=4
	if "!forcedims!"=="true" cls&mode !r_x!,!r_y!
	if "!showsplash!!previewonly!!forcedims!"=="truetruefalse" cls&mode 75,34
	::Display splash screen, unpack screen or nothing at all, depending on the situation
	if "!showsplash!"=="true" call :splashscreen
	::Extract internal binaries or create other required files if they don't exist
	if not exist bg.exe (
		if "!write_access!"=="false" (
			color 07
			cls
			echo Error: Unable to extract bg.exe, because the drive is write protected
			echo Draw Batch halted.
			exit/b
		)
	)
	if not exist bg.exe cls&call :unpackscreen&call :makebg&set "resplash=true"
	set "rescolor=!nocolor!"
	set "nocolor=true"
:redoansicon
	if not exist ansicon.exe (
		if "!write_access!"=="false" (
			color 07
			cls
			echo Error: Unable to extract ansicon.exe, because the drive is write protected
			echo Draw Batch halted.
			exit/b
		)
	)
	if not exist ansicon.exe call :redraw_text Unpacking...&call :makeansicon
	if not errorlevel 0 goto redoansicon
:remake
	if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
		if not exist ANSI64.DLL (
			if "!write_access!"=="false" (
				color 07
				cls
				echo Error: Unable to extract ANSI64.DLL, because the drive is write protected
				echo Draw Batch halted.
				exit/b
			)
		)
		if not exist ANSI64.DLL call :redraw_text Unpacking...&call :makeansi64
	) else (
		if not exist ANSI32.DLL (
			if "!write_access!"=="false" (
				color 07
				cls
				echo Error: Unable to extract ANSI32.DLL, because the drive is write protected
				echo Draw Batch halted.
				exit/b
			)
		)
		if not exist ANSI32.DLL call :redraw_text Unpacking...&call :makeansi32
	)
	if not errorlevel 0 goto remake
	if "!splashname!"=="" color 07
	ansicon.exe -p
	if "!showsplash!!splashname!"=="true" color 2f
	set "nocolor=!rescolor!"
	if not exist sm_color.txt (
		if "!write_access!"=="false" (
			if "!nocolor!"=="true" echo [1;1fWarning: Skip extracting sm_color.txt, because the drive is write protected
			if "!nocolor!"=="false" echo [1;1f[93;40mWarning[37;40m: Skip extracting sm_color.txt, because the drive is write protected
			goto skipsample
		)
	)
	if not exist sample.txt (
		if "!write_access!"=="false" (
			if "!nocolor!"=="true" echo [1;1fWarning: Skip extracting sample.txt, because the drive is write protected
			if "!nocolor!"=="false" echo [1;1f[93;40mWarning[37;40m: Skip extracting sample.txt, because the drive is write protected
			goto skipsample
		)
	)
	if not exist sm_color.txt call :redraw_text Unpacking...&call :makesample
	if not exist sample.txt call :redraw_text Unpacking...&call :makesample
:skipsample
	if "!altertitle!"=="true" title Draw Batch %version%
	if not exist splice.bat (
		if "!write_access!"=="false" (
			color 07
			cls
			echo Error: Unable to extract splice.bat, because the drive is write protected
			echo Draw Batch halted.
			exit/b
		)
	)
	if not exist splice.bat call :redraw_text Unpacking...&call :makesplice
	if "!altertitle!!replash!"=="truetrue" title Draw Batch %version%
	if "!resplash!!showsplash!"=="truetrue" cls&call :splashscreen
	if "!resplash!"=="true" set "resplash=false"
	bg.exe font !font!
	if "!previewonly!"=="false" bg.exe cursor 0
	if "!showsplash!!splashname!"=="true" call :progress 51 19 0 1 20 92
	::Get filename and canvas dimensions from arguments
	::If no arguments are given, use defaults
	bg _kbd
	set key=%ERRORLEVEL%
	if %key% == 13 cls&call :newdialog&cls&call :splashscreen
	if %key% == 338 set "filename=drawing.txt"&set "skip_load=true"
	::Set pointer location to 1x1
	set /a p_x=1
	set /a p_y=1
	::Force the whole canvas to be redrawn
	set update=true
	::This variable is used when secondary lines need to be updated (e.g. when using smart draw mode)
	set "update2="
	::Automatically allow the file to be opened if it already exists
	if "!skip_load!"=="false" (
		if exist "!filename!" set "openfile=true"
	)
	set /a canvas_height=!canvas_height!+1
	set /a canvas_count=!canvas_splice!*!canvas_height!
	if !canvas_count! GTR 7700 bg cursor 1&color 07&cls&echo The specified size is too big. Please try using a smaller size.&echo Draw Batch halted.&exit/b
	::Create default canvas and set initial resolution
	for /l %%a in (1 1 !canvas_count!) do set "canvas=!canvas!Û"
	for /l %%a in (1 1 !canvas_count!) do set "canvb=!canvb!0"
	for /l %%a in (1 1 !canvas_count!) do set "canvf=!canvf!7"
	if "!nosidepanel!"=="false" set /a r_x=!canvas_splice!+25
	set /a r_y=!canvas_height!+3
	if "!nosidepanel!"=="true" set /a r_x=!canvas_splice!+3
	if "!showsplash!!previewonly!"=="falsefalse" cls&mode !r_x!,!r_y!
	::Draw sidepanel graphics
	if "!showsplash!!previewonly!"=="falsefalse" call :initial_draw
	::Go to the main loop
	goto redir

::Allows the user to change the border and set smart mode characters
:changeborder
	if "!border!"=="ÚÄ¿³ÀÙ" set "border=ÉÍ»ºÈ¼"&exit /b
	if "!border!"=="ÉÍ»ºÈ¼" set "border=+-+|++"&exit /b
	if "!border!"=="+-+|++" set "border=ÛÛÛÛÛÛ"&exit /b
	if "!border!"=="ÛÛÛÛÛÛ" set "border=ÚÄ¿³ÀÙ"&exit /b
	set "border=ÉÍ»ºÈ¼"
	exit /b
	

::Create new file function
:newfile
	::Erase the canvas variable
	set "canvas="
	set "canvb="
	set "canvf="
	::Fill canvas with solid block characters
	for /l %%a in (1 1 !canvas_count!) do set "canvas=!canvas!Û"
	for /l %%a in (1 1 !canvas_count!) do set "canvb=!canvb!0"
	for /l %%a in (1 1 !canvas_count!) do set "canvf=!canvf!7"
	::Set resolution
	
	if "!nosidepanel!"=="false" set /a r_x=!canvas_splice!+25
	if "!nosidepanel!"=="true" set /a r_x=!canvas_splice!+3
	set /a r_y=!canvas_height!+3
	if !r_x! LSS 50 set /a r_x=50
	if !r_y! LSS 14 set /a r_y=14
	set /a rem=!r_y!%%2
	if not "!rem!"=="0" set /a r_y+=1
	if "!showsplash!"=="false" cls&mode !r_x!,!r_y!
	::Draw sidepanel graphics
	if "!showsplash!"=="false" call :initial_draw
	::Set initial variables
	set "newmap=false"
	set "update=true"
	set "redraw=true"
	set "block=ç"
	set "preblock=Ú"
	set "nextblock=Û"
	::Return to main function
	goto redir

::Loads file function
:loadfile
	::Display warning if batch file is detected
	set "ext=!filename:~-3!"
	set "bats=bat"
	if not "!bats:%ext%=!"=="!bats!" (
		if "!previewonly!"=="true" (
			if "!forceokay!"=="false" (
				echo You are trying to open a batch file within itself.
				echo Please pass the /force argument to bypass all warnings.
				echo Operation cancelled.
				exit /b
			)
		)
		if "!forceokay!"=="false" (
			call :typewarning
			if "!openfile!"=="false" call :opendialog
		)
	)
	if not "!ext:cmd=!"=="!ext!" (
		set /p test_a1=<!filename!
		if not "!test_a1:a1=!"=="!test_a1!" (
			set /a p_x=1
			set /a p_y=1
			:: Movement Batch map detected, convert to ANS data
			set "b_color=!color!"
			for /l %%a in (1 1 400) do set "a%%a="
			call !filename!
			set "canvas="
			set "canvb="
			set "canvf="
			if "!color!"=="no" (
				set /a canvas_splice=40
				set /a canvas_height=10
				set /a canvas_count=400
				for /l %%a in (1 1 40) do set "canvas=!canvas!_"
				for /l %%a in (1 1 400) do set "canvas=!canvas!!a%%a!"
				for /l %%a in (1 1 400) do set "canvb=!canvb!0"
				for /l %%a in (1 1 400) do set "canvf=!canvf!f"
				set "canvas=!canvas:=!"
				set "canvas=!canvas: =ç!"
			) else (
				if "!color!"=="!b_color!" (
					set /a canvas_splice=20
					set /a canvas_height=5
					set /a canvas_count=100
					for /l %%a in (1 1 20) do set "canvas=!canvas!_"
					for /l %%a in (1 1 100) do set "canvas=!canvas!!a%%a!"
					for /l %%a in (1 1 100) do set "canvb=!canvb!0"
					for /l %%a in (1 1 100) do set "canvf=!canvf!f"
					set "canvas=!canvas:=!"
					set "canvas=!canvas: =ç!"
				) else (
					set /a canvas_splice=40
					set /a canvas_height=10
					set /a canvas_count=400
					set "raw_ansi="
					call :redraw_text Interpreting...
					for /l %%a in (1 1 400) do set "raw_ansi=!raw_ansi!!a%%a!"
					set "raw_ansi=!raw_ansi:=!"
					set "raw_ansi=!raw_ansi: =ç!"
					set "raw_ansi=!raw_ansi:;22m=m!"
					set "raw_ansi=!raw_ansi:30;1m=90m!"
					set "raw_ansi=!raw_ansi:31;1m=91m!"
					set "raw_ansi=!raw_ansi:32;1m=92m!"
					set "raw_ansi=!raw_ansi:33;1m=93m!"
					set "raw_ansi=!raw_ansi:34;1m=94m!"
					set "raw_ansi=!raw_ansi:35;1m=95m!"
					set "raw_ansi=!raw_ansi:36;1m=96m!"
					set "raw_ansi=!raw_ansi:37;1m=97m!"
					set "raw_ansi=!raw_ansi:38;1m=98m!"
					set "raw_ansi=!raw_ansi:39;1m=99m!"
					set "raw_ansi=!raw_ansi:[0;=!"
					set "raw_ansi=!raw_ansi:[1;=!"
					set "raw_ansi=!raw_ansi:[5;=!"
					set "raw_ansi=!raw_ansi:[0;=!"
					set "raw_ansi=!raw_ansi:[1;=!"
					set "raw_ansi=!raw_ansi:[5;=!"
					set "raw_ansi=!raw_ansi:[0;=!"
					set "raw_ansi=!raw_ansi:[1;=!"
					set "raw_ansi=!raw_ansi:[5;=!"
					set "raw_ansi=!raw_ansi:;=…!"
					set "c="
					set "b="
					set "f="
					if "!nocolor!!write_access!"=="falsetrue" call :quickconvert !raw_ansi!
					for /l %%a in (1 1 40) do set "canvas=!canvas!_"
					for /l %%a in (1 1 40) do set "canvb=!canvb!0"
					for /l %%a in (1 1 40) do set "canvf=!canvf!7"
					if "!nocolor!"=="true" (
						for /l %%a in (1 1 400) do (
							set "c=!a%%a!"
							set "c=!c: =ç!"
							set "canvas=!canvas!!c:~-1!"
						)
						for /l %%a in (1 1 400) do set "canvb=!canvb!0"
						for /l %%a in (1 1 400) do set "canvf=!canvf!f"
						set "color=0f"
					) else (
						set "canvas=!canvas!!c!
						set "canvas=!canvas:~0,-3!"
						set "canvb=!canvb!!b!"
						set "canvb=!canvb:~0,-3!"
						set "canvf=!canvf!!f!"
						set "canvf=!canvf:~0,-3!"
					)
				)
			)
			if "!nosidepanel!"=="false" set /a r_x=!canvas_splice!+25 2>nul
			if "!nosidepanel!"=="true" set /a r_x=!canvas_splice!+3
			if !canvas_height! GTR 10 (
				set /a r_y=!canvas_height!+3 2>nul
			) else (
				set /a r_y=13 2>nul
			)
			::Make sure the height is divisible by 2 for centerting things properly
			set /a rem=!r_y!%%2
			if not "!rem!"=="0" set /a r_y+=1
			::Add 1 to canvas height to make sure the bottom line is visible
			set /a canvas_height=!canvas_height!+1
			::Draw sidepanel graphics
			for /l %%a in (1 1 400) do set "a%%a="
			for /l %%a in (1 1 10) do set "ent%%a="
			for /l %%a in (1 1 10) do set "bent%%a="
			for /l %%a in (1 1 10) do set "svar%%a="
			set "b=!canvas!"
			set "canvas="
			if "!showsplash!!previewonly!"=="falsefalse" cls&mode !r_x!, !r_y!&call :initial_draw
			set "canvas=!b!"
			set "b="
			set "start="
			set "start2="
			set "finish="
			set "finish2="
			set "author="
			set "raw_ansi="
			set "color=!b_color!"
			if "!color!"=="yes" set "color=07"
			set "b_color="
			set "password="
			set "gravity="
			set "jumpmax="
			set "usuage="
			set "handicap="
			set "update=true"
			set "openfile=false"
			goto redir
		) else (
			if "!previewonly!"=="true" (
				if "!forceokay!"=="false" (
					echo You are trying to open a batch file within itself.
					echo Please pass the /force argument to bypass all warnings.
					echo Operation cancelled.
					exit /b
				)
			)
			if "!forceokay!"=="false" (
				call :typewarning
				if "!openfile!"=="false" call :opendialog
			)
		)
	)
	::Display "Loading..." text
	set /a xp=!r_x!-20 2>nul
	set /a yp=!r_y!-1 2>nul
	if "!showsplash!!previewonly!"=="falsefalse" echo [!yp!;!xp!fLoading...   
	if "!showsplash!!splashname!"=="true" call :redraw_text Loading...
	if "!showsplash!!previewonly!"=="falsetrue" echo Loading...
	set "openfile=false"
	set "canvas="
	set "canvb="
	set "canvf="
	set "block=ç"
	::Load the first line of the file, check the length
	::Set that as the splice value
	set /p firstline=<%filename%
	set "firstline=%firstline: =ç%"
	set /a length=0 2>nul
	set "ans=false"
	if "%firstline:~0,1%"=="" set "ans=true"
	if "!ans!!previewonly!!showsplash!"=="truetruefalse" ansicon -t !filename!&exit/b
	if "!ans!!previewonly!!showsplash!"=="truetruetrue" (
		color 07
		cls
		ansicon -t !filename!
:rewaitpresspreview
		bg kbd
		if "%ERRORLEVEL%"=="13" goto rewaitpresspreview
		exit/b
	)
	if "!ans!!nocolor!"=="truetrue" call :colorneeded&goto loadfile
	if "!ans!"=="true" set "firstline=!firstline:=!"
	if "!ans!"=="true" set "firstline=!firstline: =?!"
	if "!ans!"=="true" (
		set "firstline=!firstline:;22m=m!"
		set "firstline=!firstline:30;1m=90m!"
		set "firstline=!firstline:31;1m=91m!"
		set "firstline=!firstline:32;1m=92m!"
		set "firstline=!firstline:33;1m=93m!"
		set "firstline=!firstline:34;1m=94m!"
		set "firstline=!firstline:35;1m=95m!"
		set "firstline=!firstline:36;1m=96m!"
		set "firstline=!firstline:37;1m=97m!"
		set "firstline=!firstline:38;1m=98m!"
		set "firstline=!firstline:39;1m=99m!"
		set "firstline=!firstline:[0;=!"
		set "firstline=!firstline:[1;=!"
		set "firstline=!firstline:[5;=!"
		set "firstline=!firstline:[0;=!"
		set "firstline=!firstline:[1;=!"
		set "firstline=!firstline:[5;=!"
		set "firstline=!firstline:[0;=!"
		set "firstline=!firstline:[1;=!"
		set "firstline=!firstline:[5;=!"
		set "firstline=!firstline:;=…!"
	)
	if "!ans!"=="true" call :quickconvert !firstline!
	if "!ans!"=="true" set "firstline=!c:~4!"
	if "!ans!"=="true" set "canvb=!canvb!!b:~4!"
	if "!ans!"=="true" set "canvf=!canvf!!f:~4!"
	::if "!nocolor!"=="false" (
	::	if "!showsplash!"=="false" (
	::		if "!ans!"=="true" cls&ansicon.exe -t %filename%&pause >nul&set "openfile=true"&call :opendialog&goto redir
	::	) else (
	::		if "!ans!"=="true" cls&color 07&ansicon.exe -t %filename%&pause >nul&exit/b
	::	)
	::)
	call :findlen !firstline!
	::Save current splice value, just in case an error occours
	set /a backup_splice=!canvas_splice! 2>nul
	set /a canvas_splice=!length! 2>nul
	set /a canvas_height=0 2>nul
	set /a colortype=1
	set default_colors=true"
	::Append lines from file to the canvas variable
	set /a linecount=-2
	set /a p_x=1
	set /a p_y=1
	for /f %%P in (%filename%) do set /a linecount+=1
	for /f "delims=" %%l in (%filename%) do (
		set "temp=%%l"
		if "!ans!"=="false" (
			if not "!temp:~0,1!"=="–" set "canvas=!canvas!%%l"&set /a canvas_height+=1
			if "!temp:~0,1!!colortype!"=="–1" set canvb=!temp:~1!&set /a colortype+=1
			if "!temp:~0,1!!colortype!"=="–2" set canvf=!temp:~1!&set "default_colors=false"
		) else (
			set "line=!temp:=!"
			set "line=!line: =ç!"
			set "c="
			set "b="
			set "f="
			set "line=!line:;22m=m!"
			set "line=!line:30;1m=90m!"
			set "line=!line:31;1m=91m!"
			set "line=!line:32;1m=92m!"
			set "line=!line:33;1m=93m!"
			set "line=!line:34;1m=94m!"
			set "line=!line:35;1m=95m!"
			set "line=!line:36;1m=96m!"
			set "line=!line:37;1m=97m!"
			set "line=!line:38;1m=98m!"
			set "line=!line:39;1m=99m!"
			set "line=!line:[0;=!"
			set "line=!line:[1;=!"
			set "line=!line:[5;=!"
			set "line=!line:[0;=!"
			set "line=!line:[1;=!"
			set "line=!line:[5;=!"
			set "line=!line:[0;=!"
			set "line=!line:[1;=!"
			set "line=!line:[5;=!"
			set "line=!line:;=…!"
			call :quickconvert !line!
			set "canvas=!canvas!!c!"
			set "canvas=!canvas:~0,-4!"
			set "canvb=!canvb!!b!"
			set "canvb=!canvb:~0,-4!"
			set "canvf=!canvf!!f!"
			set "canvf=!canvf:~0,-4!"
			set "default_colors=false"
			set /a canvas_height+=1
		)
		if "!showsplash!"=="true" (
			if not "!splashname!"=="" call :progress 0 0 !canvas_height! !linecount! 20 92
			if "!splashname!"=="" call :progress 51 19 !canvas_height! !linecount! 20 92
		) else (
			set /a x=!r_x!-21
			set /a y=!r_y!-3
			if "!previewonly!"=="false" call :progress !x! !y! !canvas_height! !linecount! 19 92
		)
	)
	if exist "._ans_bg_vals" del "._ans_bg_vals"
	if exist "._ans_fg_vals" del "._ans_fg_vals"
	if exist "._ans_canvas" del "._ans_canvas"
	::Append first line to the canvas (because the previous line didn't do that for some reason)
	set "canvas=!firstline!!canvas!"
	::If the canvas height is 0, then we definitely know it's not a text file (0 line text
	::files are basically blank files and for /f doesn't do anything with binary files)
	if "!previewonly!"=="false" (
		if "!canvas_height!"=="0" call :typerror&set /a canvas_splice=!backup_splice!&goto redir
	)
	::Check the number of blocks
	::If over 7700, it's too long to store in a single variable
	set /a canvas_count=!canvas_splice!*!canvas_height!
	if "!previewonly!"=="false" (
		if !canvas_count! GTR 7700 call :sizeproblem&set /a canvas_splice=!backup_splice!&goto redir
	)
	if "!canvb!"=="" (
		for /l %%a in (1 1 !canvas_count!) do set "canvb=!canvb!0"
		for /l %%a in (1 1 !canvas_count!) do set "canvf=!canvf!7"
	)

	::Replace spaces with a reserved character
	::This only gets turned back into a space when it's displayed to the user
	set "canvas=!canvas: =ç!"
	::Force re-update everything
	set update=true
	::Set resolution
	if "!nosidepanel!"=="false" set /a r_x=!canvas_splice!+25 2>nul
	if "!nosidepanel!"=="true" set /a r_x=!canvas_splice!+3
	set /a r_y=!canvas_height!+3 2>nul
	if !r_x! LSS 50 set /a r_x=50
	if !r_y! LSS 14 set /a r_y=14
	set /a rem=!r_y!%%2
	if not "!rem!"=="0" set /a r_y+=1
	if "!showsplash!!previewonly!"=="falsefalse" cls&mode !r_x!, !r_y!
	::Add 1 to canvas height to make sure the bottom line is visible
	set /a canvas_height=!canvas_height!+1
	::Draw sidepanel graphics
	if "!showsplash!!previewonly!"=="falsefalse" call :initial_draw
	::Go back to main loop
	goto redir

:pallette_view
	mode 58,26
	cls
	echo.[40;37;22m
	echo. ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	echo. º Color index                                          º
	echo. ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
	set "backup=%block%"
	set "block=%block:ç= %"
	set "block=%block:ø=^|%"
	echo.[40;37;22m
	echo   [40;37;22mDD [47;30;22m0[37;40;22m  [40;31;22m4  [40;32;22m2  [40;33;22m6  [40;34;22m1  [40;35;22m5  [40;36;22m3  [40;37;22m7  D[40;37;1mL[40;37;22m [40;30;1m8  [40;31;1mc  [40;32;1ma  [40;33;1me  [40;34;1m9  [40;35;1md  [40;36;1mb  [40;37;1mf
	for /l %%a in (40 1 47) do echo [40;37;22m   [%%a;37;22m [40;37;22m [%%a;30m%block%[40;37;22m  [%%a;31m%block%[40;37;22m  [%%a;32m%block%[40;37;22m  [%%a;33m%block%[40;37;22m  [%%a;34m%block%[40;37;22m  [%%a;35m%block%[40;37;22m  [%%a;36m%block%[40;37;22m  [%%a;37m%block%[40;37;22m     [%%a;30;1m%block%[40;37;22m  [%%a;31;1m%block%[40;37;22m  [%%a;32;1m%block%[40;37;22m  [%%a;33;1m%block%[40;37;22m  [%%a;34;1m%block%[40;37;22m  [%%a;35;1m%block%[40;37;22m  [%%a;36;1m%block%[40;37;22m  [%%a;37;1m%block%
	echo.[40;37;22m  [40;37;1mL[40;37;22mD                         [40;37;1mLL
	for /l %%a in (100 1 107) do echo [40;37;22m    [40;37;22m [%%a;30m%block%[40;37;22m  [%%a;31m%block%[40;37;22m  [%%a;32m%block%[40;37;22m  [%%a;33m%block%[40;37;22m  [%%a;34m%block%[40;37;22m  [%%a;35m%block%[40;37;22m  [%%a;36m%block%[40;37;22m  [%%a;37m%block%[40;37;22m     [%%a;30;1m%block%[40;37;22m  [%%a;31;1m%block%[40;37;22m  [%%a;32;1m%block%[40;37;22m  [%%a;33;1m%block%[40;37;22m  [%%a;34;1m%block%[40;37;22m  [%%a;35;1m%block%[40;37;22m  [%%a;36;1m%block%[40;37;22m  [%%a;37;1m%block%
	echo.[40;37;22m 
	echo [7;4f0
	echo [31m[8;4f4
	echo [32m[9;4f2
	echo [33m[10;4f6
	echo [34m[11;4f1
	echo [35m[12;4f5
	echo [36m[13;4f3
	echo [37m[14;4f7
	
	echo [90m[16;4f8
	echo [91m[17;4fc
	echo [92m[18;4fa
	echo [93m[19;4fe
	echo [94m[20;4f9
	echo [95m[21;4fd
	echo [96m[22;4fb
	echo [97m[23;4ff
	echo [40;37m[25;0fPress any key to continue . . .
:pv_p
	bg kbd
	if not "%ERRORLEVEL%"=="120" goto epv
	goto pv_p
:epv
	mode !r_x!,!r_y!
	set "block=%backup%"
	cls
	exit/b


:quickconvert
	set "line=%1"
	set "line=!line:…=;!"
	set "bg_vals="
	set "fg_vals="
	set "temp2="
	set "showprogress=false"
	if "!color!"=="yes" set "showprogress=true"
	if "!color!"=="yes" set "color=07"
	set "last_char="
	set "llast_char="
	set "color_check=false"
	set /A IDX=0
:convertans3
	set "char=!line:~%IDX%,1!"
	if "!char!!color_check!"=="false" goto finishans2
	if "!char!"=="[" set "color_check=true"
	if "!char!!color_check!"=="mtrue" set "color_check=false"&goto continueans2
	if not "!last_char!"=="m" (
		if "!color_check!"=="false" (
			set "bg_vals=!bg_vals!!bg_vals:~-1!"
			set "fg_vals=!fg_vals!!fg_vals:~-1!"
		)
	)
	if "!color_check!"=="true" (
		if "!llast_char!!last_char!!char!"=="[40" set "bg_vals=!bg_vals!0"
		if "!llast_char!!last_char!!char!"=="[41" set "bg_vals=!bg_vals!4"
		if "!llast_char!!last_char!!char!"=="[42" set "bg_vals=!bg_vals!2"
		if "!llast_char!!last_char!!char!"=="[43" set "bg_vals=!bg_vals!6"
		if "!llast_char!!last_char!!char!"=="[44" set "bg_vals=!bg_vals!1"
		if "!llast_char!!last_char!!char!"=="[45" set "bg_vals=!bg_vals!5"
		if "!llast_char!!last_char!!char!"=="[46" set "bg_vals=!bg_vals!3"
		if "!llast_char!!last_char!!char!"=="[47" set "bg_vals=!bg_vals!7"
		if "!llast_char!!last_char!!char!"=="100" set "bg_vals=!bg_vals!8"
		if "!llast_char!!last_char!!char!"=="101" set "bg_vals=!bg_vals!c"
		if "!llast_char!!last_char!!char!"=="102" set "bg_vals=!bg_vals!a"
		if "!llast_char!!last_char!!char!"=="103" set "bg_vals=!bg_vals!e"
		if "!llast_char!!last_char!!char!"=="104" set "bg_vals=!bg_vals!9"
		if "!llast_char!!last_char!!char!"=="105" set "bg_vals=!bg_vals!d"
		if "!llast_char!!last_char!!char!"=="106" set "bg_vals=!bg_vals!b"
		if "!llast_char!!last_char!!char!"=="107" set "bg_vals=!bg_vals!f"
		if "!llast_char!!last_char!!char!"==";30" set "fg_vals=!fg_vals!0"
		if "!llast_char!!last_char!!char!"==";31" set "fg_vals=!fg_vals!4"
		if "!llast_char!!last_char!!char!"==";32" set "fg_vals=!fg_vals!2"
		if "!llast_char!!last_char!!char!"==";33" set "fg_vals=!fg_vals!6"
		if "!llast_char!!last_char!!char!"==";34" set "fg_vals=!fg_vals!1"
		if "!llast_char!!last_char!!char!"==";35" set "fg_vals=!fg_vals!5"
		if "!llast_char!!last_char!!char!"==";36" set "fg_vals=!fg_vals!3"
		if "!llast_char!!last_char!!char!"==";37" set "fg_vals=!fg_vals!7"
		if "!llast_char!!last_char!!char!"==";90" set "fg_vals=!fg_vals!8"
		if "!llast_char!!last_char!!char!"==";91" set "fg_vals=!fg_vals!c"
		if "!llast_char!!last_char!!char!"==";92" set "fg_vals=!fg_vals!a"
		if "!llast_char!!last_char!!char!"==";93" set "fg_vals=!fg_vals!e"
		if "!llast_char!!last_char!!char!"==";94" set "fg_vals=!fg_vals!9"
		if "!llast_char!!last_char!!char!"==";95" set "fg_vals=!fg_vals!d"
		if "!llast_char!!last_char!!char!"==";96" set "fg_vals=!fg_vals!b"
		if "!llast_char!!last_char!!char!"==";97" set "fg_vals=!fg_vals!f"
	) else (
		set "temp2=!temp2!!char!"
	)
	if "!showprogress!"=="true" (
		if "!showsplash!"=="true" (
			if "!splashname!"=="" call :progress 51 19 !IDX! 3520 20 95
			if not "!splashname!"=="" call :progress 0 0 !IDX! 3520 20 95
		) else (
			set /a axp=!xp!-1
			set /a ayp=!yp!-2
			call :progress !axp! !ayp! !IDX! 3520 19 95
		)
	)
:continueans2
	set "llast_char=!last_char!"
	set "last_char=!char!"
	set /A IDX+=1
	goto convertans3
:finishans2
	set "c=!temp2!..."
	set "b=!bg_vals!00"
	set "f=!fg_vals!77"
	exit/b


::Find string length
:findlen
	set "ln=%1"
	set /a length=0
:findlen2
	if %length% GTR 100 exit/b
	if not "!ln:~%length%,1!"=="" set /a length+=1&goto findlen2
	exit /b

:convertans
	setlocal EnableDelayedExpansion
	set "temp2="
	set "showprogress=false"
	if "!color!"=="yes" set "showprogress=true"
	if "!color!"=="yes" set "color=07"
	set "last_char="
	set "llast_char="
	set "line=%*"
	set "line=!line:;22m=m!"
	set "line=!line:30;1m=90m!"
	set "line=!line:31;1m=91m!"
	set "line=!line:32;1m=92m!"
	set "line=!line:33;1m=93m!"
	set "line=!line:34;1m=94m!"
	set "line=!line:35;1m=95m!"
	set "line=!line:36;1m=96m!"
	set "line=!line:37;1m=97m!"
	set "line=!line:38;1m=98m!"
	set "line=!line:39;1m=99m!"
	set "line=!line:[0;=!"
	set "line=!line:[1;=!"
	set "line=!line:[5;=!"
	set "line=!line:[0;=!"
	set "line=!line:[1;=!"
	set "line=!line:[5;=!"
	set "line=!line:[0;=!"
	set "line=!line:[1;=!"
	set "line=!line:[5;=!"
	set "length="
	call :findlen !line!
	set "bg_vals="
	set "fg_vals="
	set "color_check=false"
	if "!showprogress!"=="true" (
		set /a xp=!r_x!-20
		if "!nosidepanel!"=="false" set /a yp=!r_y!-1
		if "!nosidepanel!"=="true"  set /a yp=!r_y!-2
		if "!showsplash!"=="true" set /a xp=52&set /a yp=18
		if "!splashname!"=="" echo [!yp!;!xp!fInterpreting...
		if not "!splashname!"=="" (
			if "!showsplash!"=="false"  echo Interpreting...
		)
		set /a yp-=1
	)
	set /A IDX=0
:convertans2
	set "char=!line:~%IDX%,1!"
	if "!char!!color_check!"=="false" goto finishans
	if "!char!"=="[" set "color_check=true"
	if "!char!!color_check!"=="mtrue" set "color_check=false"&goto continueans
	if not "!last_char!"=="m" (
		if "!color_check!"=="false" (
			set "bg_vals=!bg_vals!!bg_vals:~-1!"
			set "fg_vals=!fg_vals!!fg_vals:~-1!"
		)
	)
	if "!color_check!"=="true" (
		if "!llast_char!!last_char!!char!"=="[40" set "bg_vals=!bg_vals!0"
		if "!llast_char!!last_char!!char!"=="[41" set "bg_vals=!bg_vals!4"
		if "!llast_char!!last_char!!char!"=="[42" set "bg_vals=!bg_vals!2"
		if "!llast_char!!last_char!!char!"=="[43" set "bg_vals=!bg_vals!6"
		if "!llast_char!!last_char!!char!"=="[44" set "bg_vals=!bg_vals!1"
		if "!llast_char!!last_char!!char!"=="[45" set "bg_vals=!bg_vals!5"
		if "!llast_char!!last_char!!char!"=="[46" set "bg_vals=!bg_vals!3"
		if "!llast_char!!last_char!!char!"=="[47" set "bg_vals=!bg_vals!7"
		if "!llast_char!!last_char!!char!"=="100" set "bg_vals=!bg_vals!8"
		if "!llast_char!!last_char!!char!"=="101" set "bg_vals=!bg_vals!c"
		if "!llast_char!!last_char!!char!"=="102" set "bg_vals=!bg_vals!a"
		if "!llast_char!!last_char!!char!"=="103" set "bg_vals=!bg_vals!e"
		if "!llast_char!!last_char!!char!"=="104" set "bg_vals=!bg_vals!9"
		if "!llast_char!!last_char!!char!"=="105" set "bg_vals=!bg_vals!d"
		if "!llast_char!!last_char!!char!"=="106" set "bg_vals=!bg_vals!b"
		if "!llast_char!!last_char!!char!"=="107" set "bg_vals=!bg_vals!f"
		if "!llast_char!!last_char!!char!"==";30" set "fg_vals=!fg_vals!0"
		if "!llast_char!!last_char!!char!"==";31" set "fg_vals=!fg_vals!4"
		if "!llast_char!!last_char!!char!"==";32" set "fg_vals=!fg_vals!2"
		if "!llast_char!!last_char!!char!"==";33" set "fg_vals=!fg_vals!6"
		if "!llast_char!!last_char!!char!"==";34" set "fg_vals=!fg_vals!1"
		if "!llast_char!!last_char!!char!"==";35" set "fg_vals=!fg_vals!5"
		if "!llast_char!!last_char!!char!"==";36" set "fg_vals=!fg_vals!3"
		if "!llast_char!!last_char!!char!"==";37" set "fg_vals=!fg_vals!7"
		if "!llast_char!!last_char!!char!"==";90" set "fg_vals=!fg_vals!8"
		if "!llast_char!!last_char!!char!"==";91" set "fg_vals=!fg_vals!c"
		if "!llast_char!!last_char!!char!"==";92" set "fg_vals=!fg_vals!a"
		if "!llast_char!!last_char!!char!"==";93" set "fg_vals=!fg_vals!e"
		if "!llast_char!!last_char!!char!"==";94" set "fg_vals=!fg_vals!9"
		if "!llast_char!!last_char!!char!"==";95" set "fg_vals=!fg_vals!d"
		if "!llast_char!!last_char!!char!"==";96" set "fg_vals=!fg_vals!b"
		if "!llast_char!!last_char!!char!"==";97" set "fg_vals=!fg_vals!f"
	) else (
		set "temp2=!temp2!!char!"
	)
	if "!showprogress!"=="true" (
		if "!showsplash!"=="true" (
			if "!splashname!"=="" call :progress 51 19 !IDX! 3520 20 95
			if not "!splashname!"=="" call :progress 0 0 !IDX! 3520 20 95
		) else (
			call :progress !xp! !yp! !IDX! 3520 19 95
		)
	)
:continueans
	set "llast_char=!last_char!"
	set "last_char=!char!"
	set /A IDX+=1
	goto convertans2
:finishans
	set "c=!temp2!"
	set "b=!bg_vals!"
	set "f=!fg_vals!"
	echo.!temp2!>"._ans_canvas"
	echo.!bg_vals!>"._ans_bg_vals"
	echo.!fg_vals!>"._ans_fg_vals"
	exit /b

::Draw sidepanel graphics (slow, avoid when possible)
:initial_draw
	if "!show_splash!"=="true" exit/b
		if "!nosidepanel!"=="false" (
		set /a xp=!r_x!-20
		echo [3;!xp!fDraw Batch !version!
		echo [5;!xp!fPosition:
		echo [6;!xp!f1D:
		echo [7;!xp!fSplice:
		echo [8;!xp!fBlock:
		echo [9;!xp!fFile:
		echo [10;!xp!fColor:
		if !r_y! GTR 14 echo [12;!xp!fKeymaps:
		if !r_y! GTR 15 echo [13;!xp!f?     = All keymaps
		if !r_y! GTR 16 echo [14;!xp!fSpace = Place dot
		if !r_y! GTR 17 echo [15;!xp!fP     = Toggle draw
		if !r_y! GTR 18 echo [16;!xp!fArrow = Move
		if !r_y! GTR 19 echo [17;!xp!fEsc   = Exit
		set /a loc=20
		set /a y=18
		if "!write_access!"=="true" (
			if !r_y! GTR !loc! echo [!y!;!xp!fCtl+S = Save file&set /a loc+=1&set /a y+=1
		)
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+R = Rename file&set /a loc+=1&set /a y+=1
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+B = Block select&set /a loc+=1&set /a y+=1
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+T = Insert text&set /a loc+=1&set /a y+=1
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+P = Pick block&set /a loc+=1&set /a y+=1
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+O = Open file&set /a loc+=1&set /a y+=1
		if !r_y! GTR !loc! echo [!y!;!xp!fCtl+N = New file
	)
	if not "!canvas!"=="" (
		if not "!update!"=="true" call :screen 2
	)
	exit /b

::Warn the user that opening batch files within themselves can
::cause dangerous side effects (such as unexpected code
::execution from the loaded batch file, unwanted file
::writes, sending data to your printer unexpectedly, etc.)
:typewarning
	if "!showsplash!"=="false" set /a xp=!r_x!-21
	if "!showsplash!"=="false" set /a yp=!r_y!-1
	if "!showsplash!"=="false" echo [!yp!;!xp!f Type warning   
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-4
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Opening a batch file within a      !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! batch file can lead to unexpected  !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! behaviour. Are you sure you want   !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! to continue?                       !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Y=Yes  N=No                        !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	if "!previewonly!"=="false" bg.exe cursor 0
:kbd
	bg kbd
	set "openfile="
	if %errorlevel% == 121 set "openfile=true"
	if %errorlevel% == 110 set "openfile=false"
	if "!openfile!"=="" goto kbd
	if "!showsplash!"=="true" cls&call :splashscreen
	if "!showsplash!!openfile!"=="truefalse" set "openfile=true"&set "filename=sm_color.txt"&exit/b
	if "!showsplash!"=="true" exit/b
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-4
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp=!yp!-2&set /a xp=!xp!+8
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f                 
	exit /b

::Display "not plain text" error
:typerror
	if "!showsplash!"=="false" set /a xp=!r_x!-21
	if "!showsplash!"=="false" set /a yp=!r_y!-1
	if "!showsplash!"=="false" echo [!yp!;!xp!f Load error 
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-4
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!  This file does not seem to be a   !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!  plain text document. Please try   !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!  loading another file.             !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	if "!previewonly!"=="false" bg.exe cursor 0
	set "openfile=false"

:rewaitpresstype
	bg kbd
	if "%ERRORLEVEL%"=="13" goto rewaitpresstype
	if "!showsplash!"=="true" call :splashscreen&set "openfile=true"&set "filename=sm_color.txt"&exit/b
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-4
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp=!yp!-2&set /a xp=!xp!+8
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f            
	if "!previewonly!"=="false" call :opendialog
	exit /b

::Display "file does not exist" error
:existproblem
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f File not found 
	set /a xp=!r_x!/2-10
	set /a yp=!r_y!/2-3
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!     The file     !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!  specified does  !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! not exist. Check !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!   the spelling.  !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	if "!previewonly!"=="false" bg.exe cursor 0
	set "openfile=false"
:rewaitpressexist
	bg kbd
	if "%ERRORLEVEL%"=="13" goto rewaitpressexist
	if "!showsplash!"=="true" cls&call :splashscreen&set "openfile=true"&set "filename=sm_color.txt"
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f                 
	if "!previewonly!"=="false" call :opendialog
	exit /b

::Display "file is too large" error
:sizeproblem
	if "!showsplash!"=="false" (
		set /a xp=!r_x!-21
		set /a yp=!r_y!-1
		if "%1"=="" (
			echo [!yp!;!xp!f Load error 
		) else (
			echo [!yp!;!xp!f Size error 
		)
	)
	set /a xp=!r_x!/2-9
	set /a yp=!r_y!/2-2
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	if "%1"=="" (
		echo [!yp!;!xp!f!border:~3,1! This file is too !border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1!   large. Please  !border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1!    try loading   !border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1!   another file.  !border:~3,1!&set /a yp+=1
	) else (
		echo [!yp!;!xp!f!border:~3,1!The size specified!border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1!   is too large.  !border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1! Please try using !border:~3,1!&set /a yp+=1
		echo [!yp!;!xp!f!border:~3,1!   another size.  !border:~3,1!&set /a yp+=1
	)
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	if "!previewonly!"=="false" bg.exe cursor 0
:rewaitpresssize
	bg kbd
	if "%ERRORLEVEL%"=="13" goto rewaitpresssize
	set "openfile=false"
	if "!showsplash!"=="true" cls&call :splashscreen&set "openfile=true"&set "filename=sm_color.txt"&exit /b
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f            
	if "%1"=="" (
		call :opendialog
	) else (
		call :newdialog
	)
	exit /b


::Display "color mode needed to open this file" error
:colorneeded
	if "!showsplash!"=="false" (
		set /a xp=!r_x!-21
		set /a yp=!r_y!-1
		echo [!yp!;!xp!f Load error 
	)
	set /a xp=!r_x!/2-10
	set /a yp=!r_y!/2-2
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Color mode is    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! required to open !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! this file.       !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	if "!previewonly!"=="false" bg.exe cursor 0
:rewaitpresscolor
	bg kbd
	if "%ERRORLEVEL%"=="13" goto rewaitpresscolor
	set "openfile=false"
	if "!showsplash!"=="true" cls&call :splashscreen&set "openfile=true"&set "filename=sm_color.txt"&exit /b
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f            
	call :opendialog
	exit /b

::Open file dialog box
:opendialog
	set /a xp=!r_x!-21
	set /a yp=!r_y!-1
	echo [!yp!;!xp!f Ready to load 
	set "fltr=*.txt"
	call :openwindow
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-6
	if "!previewonly!"=="false" bg.exe cursor 0
	set /a xp=!r_x!-22
	set /a yp=!r_y!-2
	echo [!yp!;!xp!f               
	if "!filename!"=="" set "filename=!backup!"&cls&call :initial_draw&exit /b
	if not exist "%filename%" call :existproblem&exit /b
	set "openfile=true"
	set "me=%0"
	exit /b

:openwindow
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-6
	set "backup=!filename!"
	set "filename="
	set /a start_id=0
	set /a end_id=4
	set /a sel=0
	set "files="
	set /a count=0
	set "dirname=%cd:~-32%"
	set /a length=0
	call :getdirlen !dirname!
	set /a spacelength=34-!length!
	set "spaces="
	for /l %%i in (1 1 !spacelength!) do set "spaces=!spaces! "
	for /f %%f in ('dir /b /a-d !fltr!') do set "files=!files! %%f"&set /a count+=1
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!^< !fltr:~-3! ^>!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Open file                          !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!Enter=Open!border:~1,1!Esc=Close!border:~1,1!PgUpDn=Scroll!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
:file_loop
	set /a yp=!r_y!/2-4
	set /a xp=!r_x!/2-6
	set /a sel2=!sel!+1
	echo [!yp!;!xp!f^(!sel2!/!count!^)          
	set /a yp=!r_y!/2-2
	set /a xp=!r_x!/2-16
	set /a file_id=0
	for %%b in (!files!) do (
		if !file_id! GEQ !start_id! (
			if !file_id! LEQ !end_id! (
				set "file=%%b"
				if !file_id! EQU !sel! (
				
					if "!nocolor!"=="false" echo [!yp!;!xp!f[100;97m!file:~0,34![40;37m
					if "!nocolor!"=="true" echo [!yp!;!xp!f-^> !file:~0,31!
					set "filename=%%b"
				) else (
					if "!nocolor!"=="false" echo [!yp!;!xp!f[40;37m!file:~0,34!
					if "!nocolor!"=="true"  echo [!yp!;!xp!f   !file:~0,31!
				)
				set /a yp+=1
			)
		)
		set /a file_id+=1
	)
	bg.exe kbd
	set "key=%ERRORLEVEL%"
	set /a fapl=!count!-6
	if !sel! LSS !fapl! (
		if "!key!"=="336" set /a sel+=5&set /a start_id+=5&set /a end_id+=5&call :padrender
	)
	if "!key!"=="335" set /a sel+=1
	if !sel! GTR 4 (
		if "!key!"=="328" set /a sel-=5&set /a start_id-=5&set /a end_id-=5&call :padrender
	)
	if "!key!"=="332" call :setfltr 1&goto openwindow
	if "!key!"=="330" call :setfltr -1&goto openwindow
	if "!key!"=="327" set /a sel-=1
	if "!key!"=="27" call :fpadrender&set "filename="&exit/b
	if "!key!"=="13" call :fpadrender&call :initial_draw&call :screen 2&exit/b
	set /a count2=!count!-1
	if !sel! GTR !count2! set /a sel=!count!-1
	if !sel! LSS 0 set /a sel=0
	if !end_id! LSS 4 set /a end_id=4
	set /a start_delta=!sel!-!start_id!
	if !start_delta! EQU 5 (
		set /a start_id+=1
		set /a end_id+=1
		call :padrender
	)
	if !start_delta! LSS 0 (
		set /a start_id-=1
		set /a end_id-=1
		call :padrender
	)
	goto file_loop

:setfltr
	if "%1"=="1" (
		if "!fltr!"=="*.*" set "fltr=*.txt"&exit/b
		if "!fltr!"=="*.txt" set "fltr=*.ans"&exit/b
		if "!fltr!"=="*.ans" set "fltr=*.cmd"&exit/b
		if "!fltr!"=="*.cmd" set "fltr=*.*"&exit/b
	) else (
		if "!fltr!"=="*.*" set "fltr=*.cmd"&exit/b
		if "!fltr!"=="*.cmd" set "fltr=*.ans"&exit/b
		if "!fltr!"=="*.ans" set "fltr=*.txt"&exit/b
		if "!fltr!"=="*.txt" set "fltr=*.*"&exit/b
	)
	set "fltr=*.txt"
	exit/b

:padrender
	set /a yp=!r_y!/2-2
	set /a xp=!r_x!/2-18
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    &set /a yp+=1
	exit/b

:fpadrender
	set /a yp=!r_y!/2-6
	set /a xp=!r_x!/2-18
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	echo [!yp!;!xp!f                                      &set /a yp+=1
	exit/b

:getdirlen
	set "name=%*"
	set /a length=0
:dirlenloop
	if "!name:~%length%,1!"=="" exit/b
	set /a length+=1
	goto dirlenloop

:: New file dialog box
:newdialog
	if "!r_x!"=="" set /a r_x=75
	if "!r_y!"=="" set /a r_y=34
	set /a xp=!r_x!/2-9
	set /a yp=!r_y!/2-2
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! New file         !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Name:            !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Width:           !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Height:          !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-3&set /a xp=!xp!+8
	bg.exe cursor 1&set /p filename=[!yp!;!xp!f&set /a yp=!yp!+1&set /a xp=!xp!+1
	set /p canvas_splice=[!yp!;!xp!f&set /a yp=!yp!+1&set /a xp=!xp!+1
	set /p canvas_height=[!yp!;!xp!f
	set /a canvas_count=!canvas_height!*!canvas_splice!+!canvas_splice!
	if !canvas_count! GTR 7300 call :sizeproblem 1&exit /b
	if "!previewonly!"=="false" bg.exe cursor 0
	set "newmap=true"
	exit /b

:: Rename dialog box
:rename
	set /a xp=!r_x!/2-10
	set /a yp=!r_y!/2-3
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Rename file      !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                  !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! To:              !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                  !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+6
	bg.exe cursor 1&set /p filename=[!yp!;!xp!f
	if "!previewonly!"=="false" bg.exe cursor 0
	set "redraw=true"
	exit /b
	
:: Insert text dialog box
:textbox
	set /a xp=!r_x!/2-18
	set /a yp=!r_y!/2-4
	set "text="
	echo [!yp!;!xp!f!border:~0,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~2,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Insert text                        !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Do not use characters ^^^^^|^>^<,^^!%%=^&    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1! Text:                              !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~3,1!                                    !border:~3,1!&set /a yp+=1
	echo [!yp!;!xp!f!border:~4,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~1,1!!border:~5,1!&set /a yp=!yp!-2&set /a xp=!xp!+8
	bg.exe cursor 1&set /p text=[!yp!;!xp!f
	if "!previewonly!"=="false" bg.exe cursor 0
	if "!text!"=="" cls&call :initial_draw&exit /b
	set /a length=0
	set "backup=!block!"
	set "text=!text: =ç!"
	set /a length=!length!
	call :findlen !text!
	for /l %%i in (0 1 !length!) do (
		set "block=!text:~%%i,1!"
		if not "!block!"=="" (
			call :placeblock !p_x! !p_y!
			set /a p_x+=1
		)
	)
	set "block=!backup!"
	set "update=true"
	set "redraw=true"
	exit /b

:: Display constantly changing stuff on screen (such as the canvas and
:: position data)
:screen
	if "!nocolor!"=="true" color !color!
	set /a xp=!r_x!-20
	set /a yp=!r_y!-1
	if "!nosidepanel!"=="true" echo [!yp!;!xp!f            
	if not "%1"=="1" (
		if "!nosidepanel!"=="false" (
			set /a ry=!p_y!-1
			set /a xy=!ry!*!canvas_splice!+!p_x!
			set /a xp=!r_x!-10&echo [5;!xp!f!p_x!x!p_y!  
			set /a xp=!r_x!-16&echo [6;!xp!f!xy!         
			set /a xp=!r_x!-12&echo [7;!xp!f!canvas_splice!    
			set "preview_block=!block:ø=|!"
			if "!nocolor!"=="false" (
				set /a xp=!r_x!-13&echo [8;!xp!f[40;90m!preblock:ç= ![40;37m ^< [!c_b!;!c_f!m!preview_block:ç= ![40;37m ^> [40;90m!nextblock:ç= ![40;37m 
				set /a xp=!r_x!-14
				if "!filename:~-14!"=="!filename:~-13!" (
					echo [9;!xp!f!filename:~-13!
				) else (
					echo [9;!xp!f..!filename:~-11!
				)
				set /a xp=!r_x!-13&echo [10;!xp!f[!c_b!;37m!color:~0,1![!c_f!;40m!color:~1![40;37m
			) else (
				set /a xp=!r_x!-13&echo [8;!xp!f!preblock:ç= ! ^< !preview_block:ç= ! ^> !nextblock:ç= ! 
				set /a xp=!r_x!-14
				if "!filename:~-14!"=="!filename:~-13!" (
					echo [9;!xp!f!filename:~-13!
				) else (
					echo [9;!xp!f..!filename:~-11!
				)
				set /a xp=!r_x!-13&echo [10;!xp!f!color:~0,1!!color:~1!
			)
			set /a xp=!r_x!-20&set /a yp=!r_y!-2
			echo [!yp!;!xp!f                   &set /a yp=!r_y!-1
			set "pref="
			set "suf="
			if "!nocolor!"=="false" set "pref=[93m"
			if "!nocolor!"=="false" set "suf=[37m"
			if "!place!"=="true" echo [!yp!;!xp!f!pref!Draw mode!suf!         
			if "!smartplace!"=="true" echo [!yp!;!xp!f!pref!Smart draw!suf!        
			if "!smartplace!!place!!write_access!"=="falsefalsetrue" echo [!yp!;!xp!fReady             
			if "!smartplace!!place!!write_access!"=="falsefalsefalse" echo [!yp!;!xp!fRead only         
		)
		echo [0;0f!border:~0,1!!border_edge!!border:~2,1!
		set /a draw_c=!canvas_height!-1
		if "!nocolor!"=="false" (
			for /l %%c in (1 1 !draw_c!) do (
				set "line%%c=!line%%c:ø=|!"
				set /a pre_y=!p_y!-1
				set /a post_y=!p_y!+1
				set "d=false"
				if "%1"=="2" echo [40;37m!border:~3,1!!line%%c:ç= ![40;37m!border:~3,1!&set "d=true"
				if "!d!%%c"=="false!pre_y!" echo !!border:~3,1!!line%%c:ç= ![40;37m!border:~3,1!&set "d=true"
				if "!d!%%c"=="false!p_y!" echo [40;37m!border:~3,1!!line%%c:ç= ![40;37m!border:~3,1!&set "d=true"
				if "!d!%%c"=="false!post_y!" echo [40;37m!border:~3,1!!line%%c:ç= ![40;37m!border:~3,1!&set "d=true"
				if not "!d!"=="true" echo.
			)
		) else (
			for /l %%c in (1 1 !draw_c!) do (
				set "line%%c=!line%%c:ø=|!"
				echo !border:~3,1!!line%%c:ç= !!border:~3,1!
			)
		)
		echo !border:~4,1!!border_edge!!border:~5,1!
		set /a v_y=!p_y!+1
		set /a v_x=!p_x!+1
		if "!nocolor!"=="false" (
			if not "!c_f!"=="30" (
				echo [!v_y!;!v_x!f[40;!c_f!m+[40;37m
			) else (
				echo [!v_y!;!v_x!f[47;!c_f!m+[40;37m
			)
		)
		if "!nocolor!"=="true" echo [!v_y!;!v_x!f+
	) else (
		set /a t_w=!canvas_splice!+2
		set /a t_y=!r_y!-2
		cls&mode !t_w!,!t_y!
		set /a draw_c=!canvas_height!-1
		echo.
		if "!nocolor!"=="false" (
			for /l %%c in (1 1 !draw_c!) do (
				set "line%%c=!line%%c:ø=|!"
				echo. [0m!line%%c:ç= ![0m
			)
		) else (
			for /l %%c in (1 1 !draw_c!) do (
				set "line%%c=!line%%c:ø=|!"
				echo. !line%%c:ç= !
			)
		)
:waitpress
		bg kbd
		if "%ERRORLEVEL%"=="13" goto waitpress
		if "!previewonly!"=="false" cls&mode !r_x!,!r_y!
	)
	exit /b

:makeundo
	set "canvas2=!canvas!"
	set "canvb2=!canvb!"
	set "canvf2=!canvf!"
	exit/b

:undo
	set "b1=!canvas!"
	set "b2=!canvb!"
	set "b3=!canvf!"
	set "canvas=!canvas2!"
	set "canvb=!canvb2!"
	set "canvf=!canvf2!"
	set "canvas2=!b1!"
	set "canvb2=!b2!"
	set "canvf2=!b3!"
	set "b1="
	set "b2="
	set "b3="
	set "update=true"
	exit/b

:: Main loop
:redir
	call :redir_color
	set "status=Ready"
	if "!redraw!"=="true" set "status=Intializing OSD"
	if "!update!"=="true" set "status=Redrawing"
	if "!gethelp!"=="true" set "status=Keymaps"
	if "!showabout!"=="true" set "status=About"
	if "!openfile!!showsplash!"=="truefalse" set "status=Loading"
	if "!newmap!"=="true" set "status=New map"
	if not "!update!"=="true" (
		if not "!update!"=="false" set "status=Updating line"
	)
	if "!showsplash!!altertitle!"=="falsetrue" title Draw Batch !version! - !filename! [!status!]
	if "!newmap!"=="true" goto newfile
	if "!openfile!"=="true" goto loadfile
	if "!previewonly!!showsplash!"=="truetrue" call :redraw_text&call :layout !canvas!&set "showsplash=false"&set "update=false"&color 07&cls&call :screen 1&exit /b
	if "!previewonly!!showsplash!"=="truefalse" echo Processing...&call :layout !canvas!&set "showsplash=false"&set "update=false"&color 07&cls&call :screen 1&exit /b
	if "!showabout!"=="true" ( 
		set "showabout=false"
		cls
		mode 75,33
		call :splashscreen 1
:waitpressabout
		bg kbd
		if "%ERRORLEVEL%"=="48" goto waitpressabout
		cls
		mode !r_x!,!r_y!
		cls
		color 07
		call :initial_draw
	)
	if "!showsplash!"=="true" call :redraw_text&call :layout !canvas!&set "showsplash=false"&set "update=false"&color 07&cls&mode !r_x!, !r_y!&call :initial_draw
	if "!gethelp!"=="true" set "redraw=true"&call :keymaps&set "gethelp=false"
	if "!redraw!"=="true" cls&call :initial_draw&set "redraw=false"
	if "!update!"=="border" call :layout !canvas!&call :screen 2
	if "!update!"=="true" call :redraw_text&call :layout !canvas!&call :screen 2
	if not "!update!"=="false" call :updateline !update!
	if not "!update2!"=="" call :updateline !update2!
	call :screen !place!
	if "!altertitle!"=="true" title Draw Batch !version! - !filename! [Ready]
	call :input
	call :boundcheck
	if "!exit!" == "true" cls&echo Good bye!&bg.exe cursor 1&exit /b
	goto redir

:redir_color
	if "!nocolor!"=="true" exit/b
	set a=!color:~0,1!
	set b=!color:~-1!
	if "%a%"==" " exit/b
	if "%b%"=="" exit/b
	if "!a!"=="0" set "c_b=40"&goto fg
	if "!a!"=="1" set "c_b=44"&goto fg
	if "!a!"=="2" set "c_b=42"&goto fg
	if "!a!"=="3" set "c_b=46"&goto fg
	if "!a!"=="4" set "c_b=41"&goto fg
	if "!a!"=="5" set "c_b=45"&goto fg
	if "!a!"=="6" set "c_b=43"&goto fg
	if "!a!"=="7" set "c_b=47"&goto fg
	if "!a!"=="8" set "c_b=100"&goto fg
	if "!a!"=="9" set "c_b=104"&goto fg
	if "!a!"=="a" set "c_b=102"&goto fg
	if "!a!"=="b" set "c_b=106"&goto fg
	if "!a!"=="c" set "c_b=101"&goto fg
	if "!a!"=="d" set "c_b=105"&goto fg
	if "!a!"=="e" set "c_b=103"&goto fg
	if "!a!"=="f" set "c_b=107"&goto fg
:fg
	if "!b!"=="0" set "c_f=30"&exit/b
	if "!b!"=="1" set "c_f=34"&exit/b
	if "!b!"=="2" set "c_f=32"&exit/b
	if "!b!"=="3" set "c_f=36"&exit/b
	if "!b!"=="4" set "c_f=31"&exit/b
	if "!b!"=="5" set "c_f=35"&exit/b
	if "!b!"=="6" set "c_f=33"&exit/b
	if "!b!"=="7" set "c_f=37"&exit/b
	if "!b!"=="8" set "c_f=90"&exit/b
	if "!b!"=="9" set "c_f=94"&exit/b
	if "!b!"=="a" set "c_f=92"&exit/b
	if "!b!"=="b" set "c_f=96"&exit/b
	if "!b!"=="c" set "c_f=91"&exit/b
	if "!b!"=="d" set "c_f=95"&exit/b
	if "!b!"=="e" set "c_f=93"&exit/b
	if "!b!"=="f" set "c_f=97"&exit/b
	exit /b

::Display unpack screen
:unpackscreen
	if "!showsplash!"=="false" echo Unpacking...&exit/b
	cls
	color 2f
	echo.
	echo.
	echo.
	echo.
	echo.
	echo.
	echo       " m" " m  m
	echo     " m " "m   " " "m m m
	echo   "  m  " "  " "m" " " "m m
	echo     m m "  " " " " "m"m"m"m"m"m
	echo    " m " " "m"m" "m"m"m"m"m"m"m"m
	echo   m"m m"m" "m m"m"m"m"m"m"m"m"m"m$"m
	echo       $  " "m"m"m"m"m"m"m"m"m"m$"  $m
	echo       "          "m"m"m"m"m"m$"  m"m"m             Draw Batch %version%
	echo       $           $"m"m"m"m$"  m"m"  "m            created by Markus Maal
	echo      m"m          m  "m"m$"  m"m"     "m
	echo      $ $          $    $"  m"m"        "m          
	echo       "           m    "$m"m"          m"m         Unpacking...
	echo                  m"m     $"          m"  $
	echo                  $ $      $        m"  m"          
	echo                  "m"       $     m"  m$$
	echo                             $  m"  m$"  $
	echo                              $"  m""$    $
	echo                               """    $    $
	echo                                       $    $
	echo                                        $    $
	echo                                         $    $
	echo.
	exit/b

::Display splash screen
:splashscreen
	if not "!splashname!"=="" (
	
		
		if "!nocolor!"=="false" (
			cls
			color 07
			if not "!splashname:.ans=!"=="!splashname!"	ansicon.exe -p&ansicon -t !splashname!&exit/b
			if not "!splashname:.txt=!"=="!splashname!" (
				for /f "delims=" %%a in (!splashname!) do (
					set "line=%%a"
					set "line=!line:ø=|!"
					if not "!line:~0,1!"=="–" echo !line!
				)
				exit /b
			)
			if "!splashname:.ans=!!splashname:.txt=!"=="!splashname!!splashname!" set "splashname="
		)
		if "!nocolor!"=="true" (
			cls
			for /f "delims=" %%a in (!splashname!) do (
				set "line=%%a"
				if not "!line:~0,1!"=="–" echo !line!
			)
			exit/b
		)
	)
	cls
	color 2f
	echo.
	echo.
	echo.
	echo.
	echo.
	echo.
	echo       " m" " m  m
	echo     " m " "m   " " "m m m
	echo   "  m  " "  " "m" " " "m m
	echo     m m "  " " " " "m"m"m"m"m"m
	echo    " m " " "m"m" "m"m"m"m"m"m"m"m
	echo   m"m m"m" "m m"m"m"m"m"m"m"m"m"m$"m
	echo       $  " "m"m"m"m"m"m"m"m"m"m$"  $m
	echo       "          "m"m"m"m"m"m$"  m"m"m             Draw Batch %version%
	if "!nocolor!"=="false"	echo       $           $"m"m"m"m$"  m"m"  "m            multi-color edition
	if "!nocolor!"=="true" echo       $           $"m"m"m"m$"  m"m"  "m            two color mode
	echo      m"m          m  "m"m$"  m"m"     "m           created by Markus Maal
	echo      $ $          $    $"  m"m"        "m          
	if "%1"=="" echo       "           m    "$m"m"          m"m         Preparing...
	if "%1"=="1" echo       "           m    "$m"m"          m"m         Press any key to return
	echo                  m"m     $"          m"  $
	echo                  $ $      $        m"  m"
	echo                  "m"       $     m"  m$$
	echo                             $  m"  m$"  $
	echo                              $"  m""$    $
	echo                               """    $    $
	echo                                       $    $
	echo                                        $    $
	echo                                         $    $
	echo.
	exit/b
	
::Display keymaps
:keymaps
	mode 60,36
	cls
	echo.
	echo Keymaps:
	echo.
	echo ? key      = Display all keymaps with full descriptions
	echo Spacebar   = Place dot
	echo P          = Toggle drawing mode
	echo Arrow keys = Move position marker
	echo Escape     = Exit draw batch
	echo Ctrl+B     = Select next placable block
	echo Ctrl+Alt+B = Select previous placable block
	echo Ctrl+P     = Pick block below position marker
	echo Ctrl+T     = Insert text*
	echo Ctrl+N     = Create a new file*
	echo Ctrl+O     = Open file
	echo Ctrl+R     = Rename file to
	echo Ctrl+Z     = Undo/Redo
	if "!write_access!"=="true" (
		if not "!filename:~-3!"=="ans" echo Ctrl+S     = Save file
		if "!filename:~-3!"=="ans" echo Ctrl+S     = Save as raw ANSI data ^(rename to convert^)
	)
	echo F          = Erase everything, replace with selected block*
	echo T          = Teleport to a random position
	echo S          = Togle smart draw mode*
	echo 1          = Change character background color
	echo 2          = Change character foreground color
	echo 3          = Change border style/smart draw style
	echo 4          = Change font ^(legacy console only^)
	echo 5          = Redraw screen
	echo 6          = Replace color on selected block
	echo 7          = Create reference frame
	echo 8          = Display reference frame
	echo 9          = Render animation
	echo V          = View mode
	echo X          = Color palette
	echo 0          = About screen
	echo * Creates undo buffer
	echo.
	pause
	cls
	mode !r_x!,!r_y!
	cls
	exit /b


::For displaying the "Redrawing..." text
:redraw_text
	if "!nosidepanel!"=="false" set /a xp=!r_x!-20
	if "!nosidepanel!"=="true" set /a xp=!canvas_splice!-17
	set /a yp=!r_y!-1
	if "!showsplash!"=="true" set /a xp=52&set /a yp=18
	if "!showsplash!%1"=="false" echo [!yp!;!xp!fRedrawing...   
	if "!showsplash!!splashname!%1"=="true" echo [!yp!;!xp!fProcessing...   
	if "!showsplash!!resplash!"=="falsetrue" set /a yp=2&set /a xp=0
	if "!showsplash!!resplash!!noprogress!"=="falsetruetrue" set /a yp=1&set /a xp=0
	if not "%1"=="" echo [!yp!;!xp!f%1   
	exit/b

::For reloading data on all lines (slow, avoid when possible)
:layout
	set "status=Redrawing"
	set "border_edge="
	for /l %%b in (1 1 !canvas_splice!) do (
		set "border_edge=!border_edge!!border:~1,1!"
	)
	if "!update!"=="border" set "update=false"&exit/b
	set "canvas="
	set canvas=%1
	set "escape="
	set bc=!color!
	set bb=!c_b!
	set bf=!c_f!
	for /l %%C in (1 1 !canvas_height!) do set "line%%C="&set "bgs%%C="&set "chars%%C="
	for /l %%a in (1 1 !canvas_height!) do (
		for /f "delims=" %%s in ('call splice.bat !canvb! %%a !canvas_splice!') do set "bgs%%a=%%s"
		for /f "delims=" %%s in ('call splice.bat !canvf! %%a !canvas_splice!') do set "fgs%%a=%%s"
		for /f "delims=" %%s in ('call splice.bat !canvas! %%a !canvas_splice!') do set "chars%%a=%%s"
	)
	
	if "!nocolor!"=="true" (
		for /l %%l in (1 1 !canvas_height!) do (
			set canvbx=!bgs%%l!
			set canvfx=!fgs%%l!
			set charsx=!chars%%l!
			set "line%%l="
			set "last="
			for /l %%x in (0 1 !canvas_splice!) do (
				set "ccx=!charsx:~%%x,1!"
				set "line%%l=!line%%l!!ccx!"
			)
		)
	) else (
		for /l %%l in (1 1 !canvas_height!) do (
			set canvbx=!bgs%%l!
			set canvfx=!fgs%%l!
			set charsx=!chars%%l!
			set "line%%l="
			set "last="
			for /l %%x in (0 1 !canvas_splice!) do (
				set "ccx=!charsx:~%%x,1!"
				set "color=!canvbx:~%%x,1!!canvfx:~%%x,1!"
				set "repeat=true"
				if not "!last!"=="!color!" (
					set "a=!color:~0,1!"
					set "b=!color:~-1!"
					if "!a!"=="0" set "c_b=40"
					if "!a!"=="1" set "c_b=44"
					if "!a!"=="2" set "c_b=42"
					if "!a!"=="3" set "c_b=46"
					if "!a!"=="4" set "c_b=41"
					if "!a!"=="5" set "c_b=45"
					if "!a!"=="6" set "c_b=43"
					if "!a!"=="7" set "c_b=47"
					if "!a!"=="8" set "c_b=100"
					if "!a!"=="9" set "c_b=104"
					if "!a!"=="a" set "c_b=102"
					if "!a!"=="b" set "c_b=106"
					if "!a!"=="c" set "c_b=101"
					if "!a!"=="d" set "c_b=105"
					if "!a!"=="e" set "c_b=103"
					if "!a!"=="f" set "c_b=107"
					if "!b!"=="0" set "c_f=30"
					if "!b!"=="1" set "c_f=34"
					if "!b!"=="2" set "c_f=32"
					if "!b!"=="3" set "c_f=36"
					if "!b!"=="4" set "c_f=31"
					if "!b!"=="5" set "c_f=35"
					if "!b!"=="6" set "c_f=33"
					if "!b!"=="7" set "c_f=37"
					if "!b!"=="8" set "c_f=90"
					if "!b!"=="9" set "c_f=94"
					if "!b!"=="a" set "c_f=92"
					if "!b!"=="b" set "c_f=96"
					if "!b!"=="c" set "c_f=91"
					if "!b!"=="d" set "c_f=95"
					if "!b!"=="e" set "c_f=93"
					if "!b!"=="f" set "c_f=97"
					set "repeat=false"
				)
				set "cfx=!c_f!"
				set "cbx=!c_b!"
				if "!repeat!"=="false" set "line%%l=!line%%l![!cbx!;!cfx!m!ccx!"
				if "!repeat!"=="true" set "line%%l=!line%%l!!ccx!"
				set "last=!color!"
			)
			if "!showsplash!!splashname!"=="true" call :progress 51 19 %%l !canvas_height! 20 93
			set /a x=!r_x!-21
			set /a y=!r_y!-3
			if "!previewonly!!showsplash!"=="falsefalse" call :progress !x! !y! %%l !canvas_height! 19 93
			set "status=!status!."
			if "!showsplash!!altertitle!"=="falsetrue" title Draw Batch !version! - !filename! [!status!]
		)
	)
	set "color=%bc%"
	set "c_b=%bb%"
	set "c_f=%bf%"
	set update=false
	exit /b

::For reloading data on a single line
:updateline
	set y=%1
	for /f "delims=" %%s in ('call splice.bat !canvas! %y% !canvas_splice!') do set "charsx=%%s"
	for /f "delims=" %%s in ('call splice.bat !canvb! %y% !canvas_splice!') do set "canvbx=%%s"
	for /f "delims=" %%s in ('call splice.bat !canvf! %y% !canvas_splice!') do set "canvfx=%%s"
	set "last="
	set "line="
	set bc=!color!
	set bb=!c_b!
	set bf=!c_f!
	for /l %%x in (0 1 !canvas_splice!) do (
		set "ccx=!charsx:~%%x,1!"
		if "!nocolor!"=="false" (		
			set "cbx=!canvbx:~%%x,1!"
			set "color=!canvbx:~%%x,1!!canvfx:~%%x,1!"
			if not "!last!"=="!color!" (
				set "a=!color:~0,1!"
				set "b=!color:~-1!"
				if "!a!"=="0" set "c_b=40"
				if "!a!"=="1" set "c_b=44"
				if "!a!"=="2" set "c_b=42"
				if "!a!"=="3" set "c_b=46"
				if "!a!"=="4" set "c_b=41"
				if "!a!"=="5" set "c_b=45"
				if "!a!"=="6" set "c_b=43"
				if "!a!"=="7" set "c_b=47"
				if "!a!"=="8" set "c_b=100"
				if "!a!"=="9" set "c_b=104"
				if "!a!"=="a" set "c_b=102"
				if "!a!"=="b" set "c_b=106"
				if "!a!"=="c" set "c_b=101"
				if "!a!"=="d" set "c_b=105"
				if "!a!"=="e" set "c_b=103"
				if "!a!"=="f" set "c_b=107"
				if "!b!"=="0" set "c_f=30"
				if "!b!"=="1" set "c_f=34"
				if "!b!"=="2" set "c_f=32"
				if "!b!"=="3" set "c_f=36"
				if "!b!"=="4" set "c_f=31"
				if "!b!"=="5" set "c_f=35"
				if "!b!"=="6" set "c_f=33"
				if "!b!"=="7" set "c_f=37"
				if "!b!"=="8" set "c_f=90"
				if "!b!"=="9" set "c_f=94"
				if "!b!"=="a" set "c_f=92"
				if "!b!"=="b" set "c_f=96"
				if "!b!"=="c" set "c_f=91"
				if "!b!"=="d" set "c_f=95"
				if "!b!"=="e" set "c_f=93"
				if "!b!"=="f" set "c_f=97"
			)
			set "last=!color!"
			set "cfx=!c_f!"
			set "cbx=!c_b!"
			set "line=!line![!cbx!;!cfx!m!ccx!"
		)
		if "!nocolor!"=="true" set "line=!line!!ccx!"
	)
	set "line%y%=!line!"
	if "!nocolor!"=="false" (
		set "color=%bc%"
		set "c_b=%bb%"
		set "c_f=%bf%"
	)
	set update=false
	exit /b

::Check if the cursor is within bounds
:boundcheck
	if !p_x! GTR !canvas_splice! set /a p_x=!canvas_splice!
	if !p_y! GEQ !canvas_height! set /a p_y=!canvas_height!-1
	if !p_x! LSS 1 set /a p_x=1
	if !p_y! LSS 1 set /a p_y=1
	exit /b

::Fill everything with same character
:flood
	set "canvas="
	set "canvb="
	set "canvf="
	set /a rc=!canvas_count!+!canvas_splice!
	for /l %%a in (1 1 !rc!) do set "canvas=!canvas!!block!"
	for /l %%a in (1 1 !rc!) do set "canvb=!canvb!!color:~0,1!"
	for /l %%a in (1 1 !rc!) do set "canvf=!canvf!!color:~-1!"
	exit /b

::Read input from user and perform requested actions
:input
	set "placeblock=%1"
	bg.exe kbd
	set key=%ERRORLEVEL%
	set "movefrom=!moveto!"
	if not "!l_x!"=="" set /a ll_x=!l_x!
	if not "!l_x!"=="" set /a ll_y=!l_y!
	set /a l_x=!p_x!
	set /a l_y=!p_y!
	if %key% == 335 set "moveto=w"&set /a p_y += 1
	if %key% == 332 set "moveto=d"&set /a p_x += 1
	if %key% == 330 set "moveto=a"&set /a p_x -= 1
	if %key% == 327 set "moveto=s"&set /a p_y -= 1
	if %key% == 303 call :changeblock -1
	set /a xy=!p_y!*!canvas_splice!+!p_x!-1
	set /a pr_x=!p_x!+1
	if %key% == 213 call :saveans
	if %key% == 120 call :pallette_view&call :initial_draw
	if %key% == 118 cls&call :screen 1&cls&call :initial_draw
	if %key% == 116 set /a p_x=%random%*!canvas_splice!/32768+1&set /a p_y=%random%*!canvas_height!/32768+1&call :screen 2
	if %key% == 115 call :setsmart
	if %key% == 112 call :setplace
	if %key% == 102 call :flood&set "update=true"
	if %key% == 63 set gethelp=true
	if %key% == 57 call :render_animation&cls&call :initial_draw
	if %key% == 56 call :displayreference&cls&call :initial_draw
	if %key% == 55 call :makereference&cls&call :initial_draw
	if %key% == 54 call :recolor !p_x! !p_y!
	if %key% == 53 cls&call :initial_draw&set "update=true"
	if %key% == 52 call :changefont
	bg.exe font !font!
	if %key% == 51 call :changeborder&set "update=border"
	if %key% == 50 call :changefg
	if %key% == 49 call :changebg
	if %key% == 48 set "showabout=true"
	if %key% == 32 set place=false&call :placeblock !p_x! !p_y!
	if %key% == 27 set exit=true
	if %key% == 26 call :undo
	if %key% == 20 call :makeundo&call :textbox
	if %key% == 19 call :savefile
	if %key% == 18 call :rename
	if %key% == 16 call :getblock
	if %key% == 15 call :opendialog
	if %key% == 14 call :makeundo&call :newdialog
	if %key% == 2 call :changeblock 1
	if "!place!"=="true" call :placeblock !p_x! !p_y!
	if "!smartplace!"=="true" (
	
		set "update2=!l_y!"
		call :placeblock !l_x! !l_y!
		call :placeblock !ll_x! !ll_y!
		set "movedelta=!movefrom!!moveto!"
		if "!movedelta!"=="sd" set "block=!border:~0,1!"
		if "!movedelta!"=="aw" set "block=!border:~0,1!"
		if "!movedelta!"=="wd" set "block=!border:~4,1!"
		if "!movedelta!"=="as" set "block=!border:~4,1!"
		if "!movedelta!"=="dd" set "block=!border:~1,1!"
		if "!movedelta!"=="aa" set "block=!border:~1,1!"
		if "!border:~3,1!"=="|" (
			if "!movedelta!"=="ww" set "block=ø"
			if "!movedelta!"=="ss" set "block=ø"
		) else (
			if "!movedelta!"=="ww" set "block=!border:~3,1!"
			if "!movedelta!"=="ss" set "block=!border:~3,1!"
		)
		if "!movedelta!"=="ds" set "block=!border:~5,1!"
		if "!movedelta!"=="wa" set "block=!border:~5,1!"
		if "!movedelta!"=="sa" set "block=!border:~2,1!"
		if "!movedelta!"=="dw" set "block=!border:~2,1!"
	)
	exit /b

::Change font
:changefont
	if "!font!"=="1" set "font=2"&exit/b
	if "!font!"=="2" set "font=3"&exit/b
	if "!font!"=="3" set "font=4"&exit/b
	if "!font!"=="4" set "font=5"&exit/b
	if "!font!"=="5" set "font=6"&exit/b
	if "!font!"=="6" set "font=7"&exit/b
	if "!font!"=="7" set "font=8"&exit/b
	if "!font!"=="8" set "font=9"&exit/b
	if "!font!"=="9" set "font=10"&exit/b
	if "!font!"=="10" set "font=1"&exit/b
	set "font=6"
	exit/b

::Change background color
:changebg
	if "!color:~0,1!"=="0" set "color=1!color:~1!"&exit/b
	if "!color:~0,1!"=="1" set "color=2!color:~1!"&exit/b
	if "!color:~0,1!"=="2" set "color=3!color:~1!"&exit/b
	if "!color:~0,1!"=="3" set "color=4!color:~1!"&exit/b
	if "!color:~0,1!"=="4" set "color=5!color:~1!"&exit/b
	if "!color:~0,1!"=="5" set "color=6!color:~1!"&exit/b
	if "!color:~0,1!"=="6" set "color=7!color:~1!"&exit/b
	if "!color:~0,1!"=="7" set "color=8!color:~1!"&exit/b
	if "!color:~0,1!"=="8" set "color=9!color:~1!"&exit/b
	if "!color:~0,1!"=="9" set "color=a!color:~1!"&exit/b
	if "!color:~0,1!"=="a" set "color=b!color:~1!"&exit/b
	if "!color:~0,1!"=="b" set "color=c!color:~1!"&exit/b
	if "!color:~0,1!"=="c" set "color=d!color:~1!"&exit/b
	if "!color:~0,1!"=="d" set "color=e!color:~1!"&exit/b
	if "!color:~0,1!"=="e" set "color=f!color:~1!"&exit/b
	if "!color:~0,1!"=="f" set "color=0!color:~1!"&exit/b
	set "color=0!color:~1!"
	color 07
	exit/b
	
::Change foreground color
:changefg
	if "!color:~1!"=="0" set "color=!color:~0,1!1"&exit/b
	if "!color:~1!"=="1" set "color=!color:~0,1!2"&exit/b
	if "!color:~1!"=="2" set "color=!color:~0,1!3"&exit/b
	if "!color:~1!"=="3" set "color=!color:~0,1!4"&exit/b
	if "!color:~1!"=="4" set "color=!color:~0,1!5"&exit/b
	if "!color:~1!"=="5" set "color=!color:~0,1!6"&exit/b
	if "!color:~1!"=="6" set "color=!color:~0,1!7"&exit/b
	if "!color:~1!"=="7" set "color=!color:~0,1!8"&exit/b
	if "!color:~1!"=="8" set "color=!color:~0,1!9"&exit/b
	if "!color:~1!"=="9" set "color=!color:~0,1!a"&exit/b
	if "!color:~1!"=="a" set "color=!color:~0,1!b"&exit/b
	if "!color:~1!"=="b" set "color=!color:~0,1!c"&exit/b
	if "!color:~1!"=="c" set "color=!color:~0,1!d"&exit/b
	if "!color:~1!"=="d" set "color=!color:~0,1!e"&exit/b
	if "!color:~1!"=="e" set "color=!color:~0,1!f"&exit/b
	if "!color:~1!"=="f" set "color=!color:~0,1!0"&exit/b
	set "color=!color:~0,1!7"
	color 07
	exit/b

:: Toggle smart draw mode
:setsmart
	if "!smartplace!"=="false" call :makeundo&set "smartplace=true"&exit /b
	if "!smartplace!"=="true" set "smartplace=false"&set "update=true"&set "update2="&exit /b
	set "smartplace=true"
	exit /b

:: Change block
:: if argument 1 is passed, select next block
:: if argument -1 is passed, select previous block
:changeblock
	if "%1"=="1" (
		if "!block!"=="ç" set "block=Û"&set "preblock=ç"&set "nextblock=²"&exit/b
		if "!block!"=="Û" set "block=²"&set "preblock=Û"&set "nextblock=±"&exit/b
		if "!block!"=="²" set "block=±"&set "preblock=²"&set "nextblock=°"&exit/b
		if "!block!"=="±" set "block=°"&set "preblock=±"&set "nextblock=Ü"&exit/b
		if "!block!"=="°" set "block=Ü"&set "preblock=°"&set "nextblock=Ý"&exit/b
		if "!block!"=="Ü" set "block=Ý"&set "preblock=Ü"&set "nextblock=Þ"&exit/b
		if "!block!"=="Ý" set "block=Þ"&set "preblock=Ý"&set "nextblock=ß"&exit/b
		if "!block!"=="Þ" set "block=ß"&set "preblock=Þ"&set "nextblock=È"&exit/b
		if "!block!"=="ß" set "block=È"&set "preblock=ß"&set "nextblock=É"&exit/b
		if "!block!"=="È" set "block=É"&set "preblock=È"&set "nextblock=Ê"&exit/b
		if "!block!"=="É" set "block=Ê"&set "preblock=É"&set "nextblock=Ë"&exit/b
		if "!block!"=="Ê" set "block=Ë"&set "preblock=Ê"&set "nextblock=Í"&exit/b
		if "!block!"=="Ë" set "block=Í"&set "preblock=Ë"&set "nextblock=Ì"&exit/b
		if "!block!"=="Í" set "block=Ì"&set "preblock=Í"&set "nextblock=Î"&exit/b
		if "!block!"=="Ì" set "block=Î"&set "preblock=Ì"&set "nextblock=¹"&exit/b
		if "!block!"=="Î" set "block=¹"&set "preblock=Î"&set "nextblock=º"&exit/b
		if "!block!"=="¹" set "block=º"&set "preblock=¹"&set "nextblock=»"&exit/b
		if "!block!"=="º" set "block=»"&set "preblock=º"&set "nextblock=¼"&exit/b
		if "!block!"=="»" set "block=¼"&set "preblock=»"&set "nextblock=¿"&exit/b
		if "!block!"=="¼" set "block=¿"&set "preblock=¼"&set "nextblock=À"&exit/b
		if "!block!"=="¿" set "block=À"&set "preblock=¿"&set "nextblock=Á"&exit/b
		if "!block!"=="À" set "block=Á"&set "preblock=À"&set "nextblock=Â"&exit/b
		if "!block!"=="Á" set "block=Â"&set "preblock=Á"&set "nextblock=Ã"&exit/b
		if "!block!"=="Â" set "block=Ã"&set "preblock=Â"&set "nextblock=Ä"&exit/b
		if "!block!"=="Ã" set "block=Ä"&set "preblock=Ã"&set "nextblock=Å"&exit/b
		if "!block!"=="Ä" set "block=Å"&set "preblock=Ä"&set "nextblock=³"&exit/b
		if "!block!"=="Å" set "block=³"&set "preblock=Å"&set "nextblock=´"&exit/b
		if "!block!"=="³" set "block=´"&set "preblock=³"&set "nextblock=Ù"&exit/b
		if "!block!"=="´" set "block=Ù"&set "preblock=´"&set "nextblock=Ú"&exit/b
		if "!block!"=="Ù" set "block=Ú"&set "preblock=Ù"&set "nextblock=ç"&exit/b
		if "!block!"=="Ú" set "block=ç"&set "preblock=Ú"&set "nextblock=Û"&exit/b
	) else (
		if "!block!"=="ç" set "block=Ú"&set "preblock=Ù"&set "nextblock=ç"&exit/b
		if "!block!"=="Ú" set "block=Ù"&set "preblock=´"&set "nextblock=Ú"&exit/b
		if "!block!"=="Ù" set "block=´"&set "preblock=³"&set "nextblock=Ù"&exit/b
		if "!block!"=="´" set "block=³"&set "preblock=Å"&set "nextblock=´"&exit/b
		if "!block!"=="³" set "block=Å"&set "preblock=Ä"&set "nextblock=³"&exit/b
		if "!block!"=="Å" set "block=Ä"&set "preblock=Ã"&set "nextblock=Å"&exit/b
		if "!block!"=="Ä" set "block=Ã"&set "preblock=Â"&set "nextblock=Ä"&exit/b
		if "!block!"=="Ã" set "block=Â"&set "preblock=Á"&set "nextblock=Ã"&exit/b
		if "!block!"=="Â" set "block=Á"&set "preblock=À"&set "nextblock=Â"&exit/b
		if "!block!"=="Á" set "block=À"&set "preblock=¿"&set "nextblock=Á"&exit/b
		if "!block!"=="À" set "block=¿"&set "preblock=¼"&set "nextblock=À"&exit/b
		if "!block!"=="¿" set "block=¼"&set "preblock=»"&set "nextblock=¿"&exit/b
		if "!block!"=="¼" set "block=»"&set "preblock=º"&set "nextblock=¼"&exit/b
		if "!block!"=="»" set "block=º"&set "preblock=¹"&set "nextblock=»"&exit/b
		if "!block!"=="º" set "block=¹"&set "preblock=Î"&set "nextblock=º"&exit/b
		if "!block!"=="¹" set "block=Î"&set "preblock=Ì"&set "nextblock=¹"&exit/b
		if "!block!"=="Î" set "block=Ì"&set "preblock=Í"&set "nextblock=Î"&exit/b
		if "!block!"=="Ì" set "block=Í"&set "preblock=Ë"&set "nextblock=Ì"&exit/b
		if "!block!"=="Í" set "block=Ë"&set "preblock=È"&set "nextblock=Í"&exit/b
		if "!block!"=="Ë" set "block=È"&set "preblock=ß"&set "nextblock=Ë"&exit/b
		if "!block!"=="È" set "block=ß"&set "preblock=Þ"&set "nextblock=È"&exit/b
		if "!block!"=="ß" set "block=Þ"&set "preblock=Ý"&set "nextblock=ß"&exit/b
		if "!block!"=="Þ" set "block=Ý"&set "preblock=Ü"&set "nextblock=Þ"&exit/b
		if "!block!"=="Ý" set "block=Ü"&set "preblock=°"&set "nextblock=Ý"&exit/b
		if "!block!"=="Ü" set "block=°"&set "preblock=±"&set "nextblock=Ü"&exit/b
		if "!block!"=="°" set "block=±"&set "preblock=²"&set "nextblock=°"&exit/b
		if "!block!"=="±" set "block=²"&set "preblock=Û"&set "nextblock=±"&exit/b
		if "!block!"=="²" set "block=Û"&set "preblock=ç"&set "nextblock=²"&exit/b
		if "!block!"=="Û" set "block=ç"&set "preblock=Ú"&set "nextblock=Û"&exit/b
	)
	set "block=ç"
	set "preblock=Ú"
	set "nextblock=Û"
	exit/b

:: Converts the 1.5D canvas to 2D lines and saves that as a file
:savefile
	if not "!write_access!"=="true" exit /b
	if "!altertitle!"=="true" set "status=Saving"
	if "%filename:~-3%"=="ans" goto saveans
	if "!nosidepanel!"=="false" set /a xp=!r_x!-20
	if "!nosidepanel!"=="true" set /a xp=!canvas_splice!-17
	if "!nosidepanel!"=="false" set /a yp=!r_y!-1
	if "!nosidepanel!"=="true"  set /a yp=!r_y!-2
	echo [!yp!;!xp!fSaving...          
	if exist "%filename%" del "%filename%"
	set /a cnv_h=!canvas_height!-1
	for /l %%a in (1 1 !cnv_h!) do (
		set "ln=%%a"
		for /f "delims=" %%s in ('call splice.bat !canvas! !ln! !canvas_splice!') do (
			set "data=%%s"
			set "data=!data:ç= !"
			echo.!data!>>%filename%
		)
		set /a x=!r_x!-21
		if "!nosidepanel!"=="true" set /a y=!r_y!-4
		if "!nosidepanel!"=="false" set /a y=!r_y!-3
		call :progress !x! !y! %%a !cnv_h! 19 91
		if "!altertitle!"=="true" set "status=!status!."
		if "!altertitle!"=="true" title Draw Batch !version! - !filename! [!status!]
	)
	echo.–!canvb!>>%filename%
	echo.–!canvf!>>%filename%
	if "!nosidepanel!"=="true" call :screen 2
	exit /b

:saveans
	if not "!write_access!"=="true" exit /b
	if "!altertitle!"=="true" set "status=Saving"
	if "!nosidepanel!"=="false" set /a xp=!r_x!-21
	if "!nosidepanel!"=="true" set /a xp=!canvas_splice!-17
	if "!nosidepanel!"=="false" set /a yp=!r_y!-2
	if "!nosidepanel!"=="true"  set /a yp=!r_y!
	set /a stx=!xp!+1
	set /a sty=!yp!+1
	echo [!sty!;!stx!fSaving...          
	set /a yp-=1
	set ansfile=%filename:~0,-3%ans
	if exist "%ansfile%" del "%ansfile%"
	set /a IDX=0
	set /a draw_c=!canvas_height!-1
	for /l %%a in (1 1 !draw_c!) do (
		set "cline=!line%%a!"
		set "cline=!cline:ç= !"
		echo.!cline!>>!ansfile!
		set /a IDX+=1
		call :progress !xp! !yp! !IDX! !draw_c! 19 91
		if "!altertitle!"=="true" set "status=!status!."
		if "!altertitle!"=="true" title Draw Batch !version! - !filename! [!status!]
	)
	if "!nosidepanel!"=="true" call :screen 2
	exit /b
	
:progress
	if "!noprogress!"=="true" exit/b
	set /a ypb=%2
	set /a xpb=%1
	set /a ypb+=1
	set /a xpb+=1
	if "!resplash!!showsplash!"=="truefalse" set /a ypb=0&set /a xpb=0
	set /a current=%3
	set /a maximum=%4
	set /a width=%5
	set "active=%6"
	if "!active!"=="" set active=94
	set /a perten=%current%*%width%/%maximum%
	set /a rem=%width%-!perten!
	if !rem! LSS 0 set /a perten=%width%
	set "pro="
	set "rest="
	if "!nocolor!"=="true" (
		for /l %%a in (1 1 !perten!) do set "pro=!pro!Û"
		for /l %%b in (1 1 !rem!) do set "rest=!rest!°"
	) else (
		for /l %%a in (1 1 !perten!) do set "pro=!pro![!active!;42mÛ"
		for /l %%b in (1 1 !rem!) do set "rest=!rest![37;42mÛ"
	)
	set "prorest=!pro!!rest!"
	if "!nocolor!"=="true" set bga=!c_b!&set fga=!c_f!
	if "!nocolor!"=="false" set bga=40&set fga=37
	if "!showsplash!!splashname!"=="true" set bga=42&set fga=97
	if not "!splashname!"=="" set bga=40&set fga=37
	if "!nocolor!"=="false" set /a width=!width!*9&echo [!ypb!;!xpb!f!prorest![!bga!;!fga!m
	if "!nocolor!"=="true" echo [!ypb!;!xpb!f!prorest!
	exit/b


:: Block picker
:getblock
	set x=!p_x!-1
	set y=!p_y!-1
	set /a pos2d=!p_y! * !canvas_splice! + !x!
	set req_block=!canvas:~%pos2d%,1!
	set /a attempts=0
:trygetfromlistblock
	if !attempts! GTR 30 goto finallyblock
	if "!req_block!"=="!block!" goto finallyblock
	call :changeblock 1
	set /a attempts+=1
	goto trygetfromlistblock
:finallyblock
	if !attempts! GTR 30 set "preblock=ç"&set "nextblock=ç"&set "block=!req_block!"
	if "!nocolor!"=="false" set color=!canvb:~%pos2d%,1!!canvf:~%pos2d%,1!
	exit /b

:: Toggle draw mode
:setplace
	if "!place!"=="true" set "place=false"&exit/b
	if "!place!"=="false" call :makeundo&set "place=true"&exit/b
	set "place=true"
	exit /b

:: This code is used when placing text characters
:placeblock
	set /a x=%1
	set /a x=%x%-1
	set /a y=%2
	set /a y=%y%
	set /a st=!y!*!canvas_splice!+!x!
	set /a else=%st%+1
	set /a else2=%st%+2
	set "old=!canvas!"
	set "oldb=!canvb!"
	set "oldf=!canvf!"
	set "canvas="
	set "canvas=!old:~0,%st%!!block!!old:~%else%!"
	if "!nocolor!"=="false" (
		set "canvb=!oldb:~0,%st%!!color:~0,1!!oldb:~%else%!"
		set "canvf=!oldf:~0,%st%!!color:~-1!!oldf:~%else%!"
	)
	set "update=%y%"
	exit /b

:recolor
	set /a x=%1
	set /a x=%x%-1
	set /a y=%2
	set /a y=%y%
	set /a st=!y!*!canvas_splice!+!x!
	set /a else=%st%+1
	set /a else2=%st%+2
	set "oldb=!canvb!"
	set "oldf=!canvf!"
	if "!nocolor!"=="false" (
		set "canvb=!oldb:~0,%st%!!color:~0,1!!oldb:~%else%!"
		set "canvf=!oldf:~0,%st%!!color:~-1!!oldf:~%else%!"
	)
	set "update=%y%"
	exit /b


:render_animation
	cls
	set "prefix_name="
	set /p prefix_name=Please enter prefix: 
	if "!prefix_name!"=="" exit/b
	if not exist "!prefix_name!.1" goto render_animation
	set "dest_bat="
	set /p dest_bat=Please enter destination filename: 
	if "!dest_bat!"=="" exit /b
	cls
	echo Initializing...
	@echo.^@echo off>!dest_bat!.cmd
	@echo.setlocal EnableDelayedExpansion>>!dest_bat!.cmd
	@echo.set "rate=16">>!dest_bat!.cmd
	@echo.set "repeat=true">>!dest_bat!.cmd
	@echo.:A>>!dest_bat!.cmd
	set /a rend_id=1
:render_loop
	echo Frame !rend_id!
	if not exist "!prefix_name!.!rend_id!" goto end_render
	set "zero=0"
	@echo bg.exe locate 0 !zero!>>!dest_bat!.cmd
	for /f "delims=" %%f in (!prefix_name!.!rend_id!) do @echo echo %%f>>!dest_bat!.cmd
	@echo.for /l %%%%a in ^(0 1 %%rate%%^) do ping -n 1 -w 1.1.1.1 ^>nul>>!dest_bat!.cmd
	set /a rend_id+=1
	goto render_loop
:end_render
	echo Finalizing...
	@echo if "%%repeat%%"=="true" goto A>>!dest_bat!.cmd
	@echo endlocal>>!dest_bat!.cmd
	@echo exit/b>>!dest_bat!.cmd
	pause
	exit/b

:makereference
	for /l %%a in (1 1 !canvas_height!) do set "reference%%a="
	for /l %%a in (1 1 !canvas_height!) do set "reference%%a=!line%%a!"
	set /a reference_height=!canvas_height!-1
	set /a reference_width=!canvas_splice!
	exit /b

:displayreference
	cls
	if "!reference1!"=="" echo Reference frame not found&pause&exit/b
	set "ref_edge="
	set /a rr_x=!reference_width!+25
	set /a rr_y=!reference_height!+3
	mode !rr_x!,!rr_y!
	for /l %%a in (1 1 !reference_width!) do set "ref_edge=!ref_edge!!border:~1,1!"
	echo !border:~0,1!!ref_edge!!border:~2,1!
	for /l %%a in (1 1 !reference_height!) do (
		set "bline=!reference%%a!"
		set "bline=!bline:ç= !"
		if "!nocolor!"=="false" echo !border:~3,1![40;37m!bline![40;37m!border:~3,1!
		if "!nocolor!"=="true" echo !border:~3,1!!bline!!border:~3,1!
	)
	echo !border:~4,1!!ref_edge!!border:~5,1!
	set /a hintloc=!canvas_splice!+5
	echo [2;!hintloc!fPress any key to
	echo [3;!hintloc!fexit reference
	echo [4;!hintloc!fview...
	ping localhost -n 2 >nul
:waitpressdisplay
	bg kbd
	if "%ERRORLEVEL%"=="56" goto waitpressdisplay
	mode !r_x!,!r_y!
	cls
	exit/b

:: the rest of the code is used for unpacking binaries and other data
:: after initial launch of draw batch (this is also why the batch file
:: itself has to be 200+ kB in size)


:makesplice
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [splice.bat]
	set /a IDX=0
	call :progress 51 19 0 13 20 46&echo.^@setlocal EnableDelayedExpansion>splice.bat
	call :progress 51 19 1 13 20 46&echo.^@set "a=%%1">>splice.bat
	call :progress 51 19 2 13 20 46&echo.^@set /a b=%%2^&rem>>splice.bat
	call :progress 51 19 3 13 20 46&echo.^@set /a c=%%3^&rem>>splice.bat
	call :progress 51 19 4 13 20 46&echo.^@set /a d=%%b%%*%%c%%>>splice.bat
	call :progress 51 19 5 13 20 46&echo.^@echo ^^!a:~%%d%%,%%c%%^^!>>splice.bat
	call :progress 51 19 6 13 20 46&echo.^@endlocal>>splice.bat
	call :progress 51 19 7 13 20 46&echo.^@exit /b>>splice.bat
	call :progress 51 19 8 13 20 46&echo.>>splice.bat
	call :progress 51 19 9 13 20 46&echo.::>>splice.bat
	call :progress 51 19 10 13 20 46&echo.:: This batch file helps with finding certain substrings>>splice.bat
	call :progress 51 19 11 13 20 46&echo.::>>splice.bat
	call :progress 51 19 12 13 20 46&echo.:: Auto-generated by draw_batch.bat>>splice.bat
	call :progress 51 19 13 13 20 46&echo.::>>splice.bat
	exit/b

:makeansicon32
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [ansicon.exe]
	del /f /q /a ansicon.exe
	set /a IDX=0
	For %%b In (
	"4D5343460000000085180000000000002C000000000000000301010001000000000000"
	"004800000001000100003400000000000000009D4EA8A22000616E7369636F6E2E6578"
	"65009FDF391E35180034434BED5A7B7013F79DFF599641062732C14E9CC649363ED19A"
	"621B8321E5611B1BDB80AF0664C99668437084B4F24AE8D5D5AEC1373425277B1A5771"
	"9BB9329D4C2F73934C3377ED247793EB308DDB263D1318202D9D92E639D35E9BB9C9DD"
	"883A69C94C4A9C3ED07DBEDFDD9564032D6DEF9F9BE97A7EFBDBFD3DBEEFD76FADDD9F"
	"7E54940B21EC68F9BC1033C2B8BAC41FBFDE42BBF9EEEFDC2C4E54FEF09E99B2811FDE"
	"33A444D2524A4D8EAA81B8140C2412494D3A284BAA9E902209A977AF578A274372CB4D"
	"372D73993076FBC7E72BEFBDED69AB893D134FDF843EDC957DBA8AC76E7DBA9BDF5F78"
	"DAC1FD94D94F9BFD17B8F744820AEF5F74B9FB841828B38BFA0B67F617E92E2F5B5EB6"
	"4C881ABCDC658C5DA8C7AD1AADD5E49E9E6D42548832D1BDC7DB4F3D5F295358B820B7"
	"495E486B0B7DA1E3EBFD6D4284E8E101E0B0DF80506FF4029DAD65D79F6ED1E4231A7A"
	"DF4A93A09A22DDD62581AA163514D00242FCA2D6E4FD56B4BA85EB208DAE166399C19B"
	"FBDA38B16EB6454DAB4161F20A9EC51222E66A78FF8792F8EBF5175C83BEACE6AAF6E5"
	"6BEBD7750977BE5632BAD6D62E91395D3539AB6DCA0EB9AAB22F4EA76C73E5D3FD229C"
	"7564666DE1C997F45F47C59A33D3032EC7E0CBF36E4FB6B6CADD253CF9DA09EC6C9B3D"
	"F0A953D95E57950FA05CEB089483C7CE9F7FE89D265846F611D70674DEECE3DC677B1C"
	"C33EBF7B50A96AEB12D132100320D9E6134C4475FEB5ACD7E189D64DF5BAEA725FB805"
	"CB2F65AEE4F5BE6CC7335890AFFD3A2DBEF4D0953570072D91B952E79C3C4ED1ECB535"
	"BDAEEA8E0B4B857066321800E03780C9EDCBF55940B49360A066D0D7966F7BF76CAFAB"
	"BE11C4E4EEC1ECE4AC73E211EC79747AC8B541B9B49E59AB3138999CD5B76763AEC6C9"
	"FC9C5F39BDBE4871BEB68E56CC76B91505C3B927AEE4F3A07FE4C0FDF73D749AD83EE5"
	"53BA3071D10E4AA77B01B8713D4BBB08D8913D0AC0EFEA2B0DBA725F5AC1B44CEAF97C"
	"1E4A7A1C58305BAB384AD062E7C517406BF6846B17904C5ED6EE9ECCEB5B94B7D72D58"
	"5342C6645E6B50CE5D777AE6794CCD55CC3C43B6C0CCC32E5A4D12B5E1F2DCE465E7E4"
	"31607CD285D169B7ADC428D6BC985D19B5BF3CAF50A498D684CD1725D13D463A9A0759"
	"9B0D7DB995630BD05795C8AE150FB9D0EF4976A55431B2ECF2A8F0B9FD83F9DA67E96D"
	"655444857F9891319E47D916A224AB47F0688A2CF33C4B46E82BB2E58A38466BFD10FB"
	"C3982A41709E2E58AD1D4C3A32F3655A79DBECA9198AB1C6145F833E3F0CC541AE635A"
	"5E07119EBD947F838977C38273FFF23B26FEA12B27096927545DED8E0AA8B47A10E447"
	"8522D6D1F6E7C966DE807F3968AB2797C2B62C16612B189C61EA3E758A583421F0D695"
	"D65690B902CB1D00503DE851BA80796E39E8AFF6B915A98D4013D87CED39A272C05507"
	"532C016BF2F36413CD8A87DED9876CE61DF66537CE63C00FD8356EE5ED0D5D447563D4"
	"3D987F1DDBE796B6FD383C35E4929EAC231D62CA35A81CA345C75DE7C1AA32046979F2"
	"AFC3128F019C6F7ABFB0E56B7FC752126CE3756D2F8533F31178558D074CD58029659B"
	"700A62D279FC24DE5A012E6AF34D0DB8BAC0C069C7076FDE315B81447C0C9C54195CFB"
	"B3CD24F3FC6B2CF11C497CE36FF3F968998F7654634583CF40EB7CEE5CE6B47D5079A2"
	"CD5A6E88830CCED8FD18EDFEE037AC2F925DB6C341364DF445992AE561AC7043E74DAC"
	"F337B0A8068EBA6633A29173E2001826F97BA71F719DA6701A2D73F30ED8A21D802E76"
	"6041F929A0B59395002CE8C95E62D67D2C3F138327FF86126A638B75D0CA7972B6BC73"
	"628A1CBBB98A9CA5C14F34DBA20D6EA35F6DF4DFFE289640B2E1CD0E7D39B921FA72EA"
	"339B84FE91AD57C66E0D6FDE7B054367AFE0A5B2F0B2667E3AE482841CE1A9AAA5A6FB"
	"BE973DB3D89D5F9E9FEE1536C4DE9A393BF19E39EAAA13DAE732F336FD763256EFF404"
	"73EE8E9699AC0CCE6D754FB7DFE5F3E76BAB41B717C671010B3CBEDC77AB8438B3F3CA"
	"4701A70914979F02807A129FDB579403CB0D62686483219CD5109F28F82A19EA2942FF"
	"224D19EA0126CCCFBD74FE3CA7333FA268151C7549130C2717ACA218AADDEACDEE77D5"
	"6C3EE0D096FBFCB95D3CA85FBA6FE4408977737EC21E385AD496BBABCACA35F75851CB"
	"B57141D4425243F0C0865360F618C738A8162906F652CDC8FF673923AFDD7CD455AD7D"
	"82D3A52FF7031ED4E7DA0A313DAF7728551B1706E42270007815CC4A304B8707F9EBB6"
	"3CD92B65E717FE83E2D3DC0C12EA269B618A53838EEC7157BB8D534C53F6DC9A970D1D"
	"DB0A3A3E3B620136E45595BDD9F95C59665ED22A32F3957A45E6A46DEE97EC0CC037E5"
	"0867360BEDE0F4535CB29B0BDD58A87D3233DFA0B7389FEBB6614718D47464F3F48461"
	"4D0A4FD968ED8B34A15F6C9BC5FBD4CD074EA1C318AFDA2CF47F2F8C63A4F05CAA0F90"
	"E1C85288B3676D83D0F35108A77441F62607EA0E842FD499FEB6FCD61F69773D69C7C8"
	"E6F6879D9387C1A3BB6049531DB4343BE152967005125A625420D4BB07BDB9F790AE95"
	"5E28C19BAFCDB10E6AA80C580D20C3D96685AC120AA8F378519090553827AA303505C5"
	"5E462CB8455F9BAF2004907A2F9CC89497E94B5B7FA4FF9ABC85FD69A8AC0C41B41A0B"
	"EBDC3080184735FD3B784C91096D24285B3F704EFC6B19C9BB7CEA4E4174FF20BCF5AC"
	"760F84BB5F5B82FB5ABD727AD036554B73960AB69ED57F4E7A9B1E48D9CA5F1A34820E"
	"3837C8FE1AC965FAE8B3F6B34C2787B3D7B2CD1AE1BCF308EEE4E4CC8A73F20C851D86"
	"4DEC901115F4BFD0968EBB624B0407CA683935056B8E794C09695B38752193D0D10321"
	"52B351C5997FC5347B32570FE247CC4620A0A977ACB253DF658A71512CEA9AAE128360"
	"6797C70F6AEB731164E22759AD37117753ED0F01663D40747D8D75D1EE877DD72C94B4"
	"73F236A39A6269B3FDB0C9284FD4C101ED83EEB3F6878DFC7EA9D5029CAD34A481F402"
	"AB26233E69336DFB578638C90F119F4610A020905359FBC3C68EEE29C6B0E6C2F43F2E"
	"921F6CE23D6B79C19E671C3895E5C24BC934EF7C00F887B3CFB86A3016CE7C5634FB9C"
	"936F087EB609E724A5DCE865849A1A429E7F05327FDE558FB5C2AFAD32EA12AA0124B7"
	"72B413596EC5FB609BDFF3B56F1B828EFE1ABB58F751237491AA00803313F4C43EDD1C"
	"2231C0ACF0D6133572A31B6B5D6E24242E6B6A068D5D432E978777E91740355162C4CD"
	"CC7C5CAB1CCECD5EA6B0654706A91123FA52D30838A813D7A71659D17021E9D6B28DB2"
	"CF4DDE0E268673BA01AAB8D7925FE61DCDCB255AB5B1B39D0B955E57A372691B278AF3"
	"AD5CD3B40E46519A5CE0D2E455DCBF4B22F422BD6F7C9345530766972BF409C04BA58F"
	"03AB515B506958C5A378E7E10524CF2A6F6DEB32C9FD1A9D87F2B55DA65FC194179F9F"
	"D89EC98A3BE83C90AE9CA18EDEA76B380D7259C9951FE8AD47DA70A34C818CEBA9726A"
	"441AE8E2B2A53E9CE914CE897780FFDB6F027DF64C385B1DDEBA42BF2B3CF963AD369C"
	"85136D1DB4E9CECCAC3D73D28E41FD676DB3731577CC66DECC53807B94769EE39DD9FC"
	"9FB457DBF7ED137F3A46BDD72AF661996EECCF1D7E0F856F2F55A828F8EFCB9CD64E95"
	"AE4044CE0D5FB5224A51ADD1D3F692B20920C2A8175BF3B5BDAD1CB05CD0F34FD977A9"
	"BA9D2ACBD636B152ED992D42AB8A528037932C64D73C3CB5DF55EF9CBC874AB9E65D5C"
	"35EEB04DEFFA6EE6C356E7E77F493EFBADA9D90628D335FD7574D30FDAFD8C33FF9ADF"
	"44C3E061046553B6426970F10415456D3FC97D156E471009FDBCEE9C789CCAB5F961E7"
	"C497D993E753FACDE1CC83765D5F6AE4725B5B1E2CB4FA686FE2032E4C21E975C81E9B"
	"06BD4ADE7937AC6A806A743A9AFA3C3098F6DC3F5F62F1B403AFDBF0AAB94D2527AA37"
	"C9FD6FB9C4B0AC7031771B6115D33BEC7AC5CCAB9D54DC3CDF494CF13185CDCC97FB19"
	"E3AF22293927FE1BF91185557538B34DE8B74FFEC439B90280E656D2181D9EC9E13267"
	"6CA8B2EA8DAF0151238EC0374E7416BE0D60DF445D19710E28EB15B2799FF2146166ED"
	"C13CEE98791CAFD9D71132FBAFCA3757A2BD9419DCB92FDB84E1C720B5D7ACD5A904C5"
	"D12E2A408ED2CBFE3F6484FC098AE86C19D8B3212A901B1B0D3D211AB984FEF1689952"
	"BD9288D867E4A5D668DE639C2121F8568E8CD8B3DF9CCC6E2419D34907A778377735F7"
	"5B860920AF1AE646B9E65D486D86BEC485A796B4FDE4E27FE1D597FBD67B1CBEB0850E"
	"93A40EAA7378BBF3B9256122F8F76C26B273E29BFCD0E79CF8061EDA5ECACC0FE1A034"
	"CD99134277FBB21FE63EB86CA949E877CE3C664A8FE3CD62F9DDF9167F5A21D3E0F9C9"
	"BCE6F229C748FEAFF87DB9CF7E88F0FA5A3167FCE7BB04B96E8E8EDDB9073E640B2A35"
	"90CF96603E512A05E7733BED99B3F642518913872D7B27A7A45708BC3FF7F70C9A3C50"
	"D6571A8306CEC8BBD669AC002D9BEF919029EEEE12EBD17E8BF639B45B30262A2A2ACA"
	"2A0A97287936068C795B7945859DE7CF2FBC06C18D7DCDB93B663FB8F037E7B2A75709"
	"78C9D673EAB2ECC94F1DCF8A29BBEB54337D5C98147317CFE757BD4F27F6554FF0FD29"
	"BE6FE2FB2CDF8FF3DDDDFAFFE9E3E657FA84780AED5B68DF479BE833C6BFD72DC437D1"
	"9E42FB2ADAEB68DF477BB8DB983FD723C40358BB076D03DA47D0AAD07E07B7FB05DA8F"
	"D19E477B06ED09B42FA23D88A6A285D0F6A10DA0DD8B560558F5684D68DBD15C184BA0"
	"3F86F645B47F427B166D166D1FDADB68EFA309ACBBA5D7FC1CBE5D88CB68BF407B0BED"
	"55B4F3682FA2CDA0FD1BDA53688FA3FD03DA04DA11B418DA41B47D687BD07AD15C68B7"
	"A255A1FD06FC5E426BDF6EE0E9167B8457F48B1EB1174F5B50F6E8222102E2A0880919"
	"6F9A48E21EC15814EF41BC1B6FC6780A2B558CD37B8B5846DFE0A51D81484C0E495A52"
	"0AC462C9604093A5B188AAE981981497E349755C6A5CA5AF26DC03C940682072500DA8"
	"E37E7ADFA1CAB2F90E38F45F8A9EBD7B00459503A1712986D532FFEB41928613818331"
	"99709818CCC51F4B4BBD0303D7597348561372AC6D7D4B28162BF0DD26D683F210B88D"
	"89C5FB82408C7DE944209556925A81EE6BCBAD541624A334EEF78A0DA219B28CF05823"
	"649B66A91EE199FDD891C04804724DE269754186FDA389A41A498C4AF76E683E18D1E8"
	"5F5041399D961AF5B42C1DB977C3FE40221D092613ABC521C053B15706FD8B79710754"
	"39A1491DD22A6F81F655C047D4F661970AAC2A9E5761BD6EE2B6E6A9BF369F027C4444"
	"98D72C9C1D113EC0F5609CF6E96C231EB6276142172C8514D3AC80FB144BC9924A3376"
	"0645139E0CBA54DE2B615D9AEF211167DB5B7D4DBA48863A3809E13981678D21A7F01E"
	"C033C15F4C135D5EBC87317AD8D4DE7EB19BF541B2499B73FB812509DC71D617C177F3"
	"7C10EBD3BC4A2DC49FA26CAE2F9D55A2037F07FEC01A63CED042837927F9A498779296"
	"C6FC2CDC3B807E2720AF028DF411ADE889A607A4D8204AC6AF6DE11F17DBC4B5ED5C82"
	"2DC337C5DFB24E92AC9D5DE8932C9576C408D25212F61D105D5819809669B685B51347"
	"1F80EC3BD91A7C6C0564FD069C7518DD2436B385ACE7BE1BFCAA988FB14DAC17AD58B3"
	"99BD44C2DF0ED6975CD01CC15420170DBBB688B5F85BE85D2D25B4B58831F177BCC7A0"
	"6B2DF62E5BA4D5A27C251E09B2BD921D91FC3F033EC8D78DD5464C94849F7BF243C9C4"
	"4A523222698AA18FE21E00C634D3BB6C118D92B80F5A8E41937D6C0903E27E732C5278"
	"EA2F3CE985A7E1C2531CF76E31843F0FC6ACD114EE3ABF2F63D995FED1BC2C8E029B04"
	"6E695F3FF8DE89B7A36C731AFA215EB7033344590BFFDD6FAE706307D99D077877F3BA"
	"6E3CEF042C039F8191B8AAC49F65BB1A74455289B14C46596EA3FC2E433714CDC80ED6"
	"C19A530BB462584207F8249BD3793D8DB5612CCC7E4D39CAB0A9A6126E09B724D620EA"
	"76709C202BA17B138F6EC2286937C53A0D99A3EB10A53B002B8E71F271CDC4BF86354C"
	"F8228C3F0D9B94F06644AD85F2B0B88F300511D6B6065C31E6B0D98C6BA1ABBCD9CABC"
	"3D80D12B3E66DA6369FC92CC5CA3B2473632CCB499AD89E2187AC3368DB86151A23325"
	"04E15AD49027916CC7CC88B990A630EB225EA2BFEBD364E1EBE7FBB089355DD07A90F1"
	"4A1C55838016E12C2615A892593212C760F2269D3396955F0D486A014B7C01FC515E39"
	"CEBB131CB5628CE5104BAA81394C300D8AC9918CD1D585CC637990957B42980F73EC8A"
	"31F6207B75B2047F8AF11BD1EED0821AC992D4C2FA60A15517A114B5538475B5D46F04"
	"96CC9064E631B9C8B7AD357D7F604D13F34D72FA186329F50F897575986D8C9E2C781A"
	"C30B71F59362998F33FD969F18D26FE66C66F90BE93A64E6F52653B671AE990872A824"
	"FF4B1C29294EC4CC38ACB114289E5A140CFD110A9A98F6006BDC1857194E53C14A122C"
	"F358C11E0FB2EE938C492A540001AE0C8A16B8D0EB2B0BB58BA5B134CB2EC8D541C4E4"
	"6B614630E018958B62F2595952035932B72454AC4652575523C51A6AB1248AD296CC4A"
	"45656A22DC0799A71047EDA20F18B56CD2948701972A26B218E2EE087BAAC15DDCF46A"
	"8238CA756F5A6C651A63AC29C33F2D3F6DE0C842750BE1598BBAA3D432429C2B02AC3B"
	"235FF6B325C64B7809705C96404D84E526C15A9BD1ACF8A99AF94435315A9A1C6599E9"
	"056D1AFD41334A2C9C6DC4B8CE58ACBAD2A2D088AC566D4B77AAEC3ACDCA8D2A227AA7"
	"F166B42028A7038C514D7A4D8B10E20EE4CCF855B5D608E27E1F72AE109FB8E17A3709"
	"4A0D89256E305A58B45FBB96BCBAFE6BE4DC679D6928628EFD05759C81BB197F0BA118"
	"630AD701295EB3D6AC490D3AF6229F0C09FA074ECB2AD4F8251F28DEC6D9B6AE15E78C"
	"EE928F02385B9FC3D8A325EBC670B6DF84B17D25633FEDB37E2FF7D7EF0A7FE9778572"
	"D19FEE4926D2C998BC2B9008C56451267A63B13D81B82C6C62A7ACB971A4F5F8584ABD"
	"7DDB87777A873CF4E33AFAB1E5482AA029A242C4F01893C7E498B00BB771021E1A4FC9"
	"FCFB45F3180F0B0AA774ED709AFE8731322A6B23C97458311002E34818279D44123846"
	"4622C98323613D01875B2A460E07717E8EC3B4AA44F8700A476D2D2CC472115665EC5B"
	"21E2723C9E1C93C5AD020B838A4A3E8AA7B486A79B459C3F6C08719388A40F07352249"
	"D40A2D7938963C2CABC4C5483A51805A4DD082A971E8407C269D5435E1E41182FA1182"
	"9A3AA81E42A40F87637A5A818685B5D5013AB56404921849CB1AFDD2947EF238124907"
	"346D5CAC1418A4831D58AD1169734F3C3D1654354336AE0ABF1AD164530D7EF1AEDD67"
	"7C88A10F2D7D47C487767F20A2ED48AADE48623426EF3D1895839AF886E8E153A1478E"
	"27357948A1AF2FF0330396A986DDFC2107566441EC26890024E2784F2C99B6747E7FF9"
	"EE64488FC96DEBF7C84734BFB8AFF0BE23A2A631206C36D8C24020ADF5A96A1212F9A6"
	"DD1B93E594F89E49C550321953E458AA6DBDD73CA40AF165DA3314091EEA49EA38CE8A"
	"5DE5032406E24A1C28033FF180B61B540646C1B478ACDC24DA22427CA538629271B20C"
	"107B74958EC7E65C7F48F455C4A0719849C42F66CB3D90C38E08D9D5974CDAE8CD2F5A"
	"CA76441221E65AF4F133A131E636F33B233106C42A438E0C28447C78B590292CF173A2"
	"A2EF4844EB81AA4D321009ED5ED066E8B0475363C66A557CDDA4C25C08D8B7DB3D5AEC"
	"D3B29A34D573AC7C6F4A4E5880FC04A72F311651938938F8F405D4087DE9F28B9F32DE"
	"6BCD7C9EE5928CC781732092C0C8B3C60853B357D7E07B3D6E213ED9E7D9D33760F9E4"
	"2E9B471EED9563B226FB02311DBB5A698445F449795C3C486F208627FB8E80F2048D0C"
	"EAB23A5E1CDBCC7B98456CA2A1EE5E5FB7BBE0F93772D9F8F7BD124224FD047893A0DF"
	"CA955E65FC6F6EF775C6956B8C57DAAF1A2C8CD33F1E9F780071D5569C398638D15FF2"
	"BBE6B76C1BE857CCC8A9D6B71ECAAE46CEA5BA7B079EE97AC1FEAB2B04D7C1945416FA"
	"E265178B7F2EDD69A31D5EAE8A8DFA718759F7F6E38D6A16441C5ED38A73702B7230F5"
	"DB39E50D89BB306E7DE7326A8534CBE0CFFDA2829C85886AC14CF1DE717068D4DE745D"
	"EB2B125DDB1159CB0AB4F79A5F5F88A754E16C5F5AB3488CA3F8AD85AE8FF32FDD2D18"
	"BE45D585285429C64FCF49BAFDCCB3F135956AD822A50BB926BE2AB17E80AB485A49D8"
	"53E04DE59A972426AEFA3A65FC4EBC0AFBF69AEB22261E8BC6C475F0B570852D17E834"
	"BE52D1B70FAAD64BE5B9B056A36FAE1557AD5F2C895239F4B225FB98E2AB2D07F9847F"
	"703FC4E715A230C65F568B32ADB43F6B6FDF76241E93C664351D49263A1AD6B5B43648"
	"7222980C21C574340C0FED68DED420A535C493402C99903B1AC6E574C3B6CEF6403A2D"
	"C70FC6C6256C4FA43B1A7435B10599578E07D2CDF148504DA69361AD39988C6F09A4E3"
	"2D63EB1A24C4A448584E6BBE525C9DED9AAAA7B5FE4438798390DAB0272D077544E5F1"
	"CE7655FE8C0E9872C8AD46C610A347E574C960DF112CD4806C80AA12896B938E8640BA"
	"3F31963C24AB0D921EE90E52B0ED6808076269B9415ADBD9BEF69A30D71671AE2D908C"
	"674B0E9D7FFD29FF9F75FD2F"
	) Do >>ansicon.exe (Echo For b=1 To len^(%%b^) Step 2
	Echo WScript.StdOut.Write Chr^(CByte^("&H"^&Mid^(%%b,b,2^)^)^) : Next) & set /a IDX+=1&call :progress 51 19 !IDX! 179 20
	:a
	Cscript /b /e:vbs ansicon.exe > ansicon.ex_
	if not errorlevel 0 goto a
	Expand -r ansicon.ex_ >nul
	Del ansicon.ex_ >nul 2>&1
	exit /b

:makeansi64
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [ANSI64.DLL]
	del /f /q /a ANSI64.DLL >nul 2>&1
	set /a IDX=0
	For %%b In (
	"4D5343460000000054740000000000002C000000000000000301010001000000000000"
	"00470000000200010000E400000000000000009D4EAEA22000414E534936342E646C6C"
	"00149D3619C5490080434BE5BD797C53551638FED224DDC32B4BB02C95A2518B152D14"
	"B03514F26802AF90220A4546A8A0D5888A8090C85A292651E223800E6E33A8E8B8CD0C"
	"8A0BB605D12614BAB0967D7329CBE08B4181514AA1C2FB9D73EE4B17B699F97E7EDFBF"
	"BEF049F3DE5DCE39F79C73CF3DE76EC97F7019A7E5384E071F45E1B8728EFDB370FFF9"
	"5F3D7CDAF558D78E5B13B7AD67B9C6BEADE798C94FCC4C9D3E63DAE3331E7E3AB5E8E1"
	"A953A739531F792C75866B6AEA135353ADF78E4E7D7ADAA38FDD6930C49B54181F8597"
	"341C7BA9FE83C8E7E77FCFFCA09E9E8F7CF017F85EFCC7F00F4ED0F7BC0F8ED2F75CF5"
	"BB98BEEF7FA26832D6BB168DA36C1CF7E80BD15C5A5DD58448DA69EEA6D484A8788E7B"
	"0D5E96B0B492F9F027891E57D15F7C8EE2383DFEE15ABEB9491AC62CCAB6682295225F"
	"57BEB3C7C0F71C170DA52D751C97460CD67016647C868673C6B42658C36569FE0BE65F"
	"FEEF338EABD35E3BFB4EE763B39DF0BD6EB94AD06B5C733B22FF52A17577CE78F461E7"
	"C31C57752783C965C0E72F6DCB816E58EE64C5B8AC91AA2224C267F315E502774E6705"
	"A98DD0562E16BEF75D05DE8C99338AF059CB7843B4FD70B5728F4D9906051B348C5724"
	"96A357941BF27FC0C1FF27FF65062AB7B6FE27FA2698920B44F7C954ABA4D71EE23851"
	"FA59948C29F47450319E7C87E3BC01972133204A134C16D1BD31B5B0D2AC3F7890E39E"
	"75D825FDEF07B1A0E193140D97B92B1F4AB6B34A817C6D4031FE036A8613AD524DBEB6"
	"56312E8737D11B709641E112286C970299BB449F7E0DD4578C533157327E042F505D94"
	"B6F8F4B328E369CA302C412C3EA72943F4CD3765652A0E77764FE99C855F5EE56D7026"
	"38B2E744B9F4FE619AB0452CAA12FDDD0547B6D9D997EF61C5CABBF932ADE8AE8C72B8"
	"1BCDCE18C871FD1AD6397CF32E89D23668DFDBD83E67774CDF2D55891222910049ABE6"
	"7A1B0053B5541D3EB275AB6F8C29E9016497E81F03F9D279C5780440B8E79BAC806B87"
	"73384B07AE66545B210DCDACB10C4A486310E60EC5F81EBCA895774807B090860ABD82"
	"852A116D06A29D58893514E34C2C4EEF242FCB68445E7E3754910E22982C87CF0A2C09"
	"887EC3E97F02FBFC161DA6DCA318FB404DE0B1DF6ECAB2FA8724C9CF3C8FDC3D003232"
	"3A80DEACDEE5E7154511BEC69E6AE5AD076CDEC30B7A7A0F3B5384738705A952701FE3"
	"838D3A21784CE7AEE785844AA4627C25E4B007A63F9602D13FC5F47771E1C9951CB6CB"
	"30BE9B061AD3FB6DC495F24388E3106C67C818421989D89C851BB17061A53B27B01F1B"
	"62180B79A2A47F7C1B8A7985E90D04E55B635A06DF2E833B6728A473BCD70D7FBDB5AE"
	"05596247D7DC92D9ED5133EC50D3992F19EDF11ACE7DF49262FCDB5B8859FF688814A7"
	"3764DBFDF98F8B7EE37B5022B301B5285531BAA09464BC211ED11A6289B22721293418"
	"9891D9A0D6980ED936682EAB3204F37BC42065EB4D8B8014C1DDA4E3FD5B8828DE5B89"
	"C651ECC87BD7111F5232A17296D8DED959327E164768DEEDAA92C8BD85482A50ECCB20"
	"DDD795D16895AA415B556C7B5670D047520AB6029EAC99ED5D46D062D06083B317FC8D"
	"75DE0C7F639C29507B04D416FD05A714E39B50C591EDFACD15ADE8E33015945E318C97"
	"81876F0273E30194256B7A7BDE737F3436BE2BA32AA12B36FE69A81BBA07D289AACC06"
	"5B2674CFB5388E59A51D76DFFBA6128EF5C0543BFC99AE184D2BB095053F89BEE29F44"
	"A9C62ED52BC6BABF12CFD776895014B30235ABA2F0145F613BCF57E45FB4F265F90AFC"
	"29684AAF71587D8531F05CA5041D3E579C60DEE26C6FE3CB820E5BFA0687A00420DF16"
	"27E9FFFA137080AFD8AC0DBC299C6B82A79DE93BCD75C571A0E81A2AE2B041FF4D940A"
	"62F2A4AD8AD10334F065B6DF00A401121C3E5B825490A018EFF82BF153BF85F1D3C94B"
	"FA33307C9D3BD06D97FB6854B86B76FFA3F0EAD249FBC3ED24E3A5180DD7B041E74C74"
	"1F6D22B0F97F25AD6AF713C9F6815855ABA4DD906BF74D31CD56C596F257620BA32596"
	"F8617C19000BDFA6E2409535A323EFC984210F187216385360E02B86778687FC269B5F"
	"1765D5D6DACC417E497B2821E043BE868A2A5673805FD204439F1DDE4E018F7392D1DE"
	"E605EBA314A3F0176C9A0CD695F7EC8FA2E61B80C5A7F8B2ED0E5FF1333ED72C87CFBF"
	"10D03B7C05D31CE6D3FCD23AEC7485D3A44B8E650ED45DEC8D8C69B6050E65B3C3F7AA"
	"9B9418DE7C7E2F9A07698755AACC93F642BB44B02ED0D28E7F41D996159E056AAA6FD0"
	"50E9E6622098B7B01E7E2F24CDA13AFBDF54EB38ACE642C5190762AE443538CB971181"
	"48B903D581916BAE59D00B1B127A00EC14087401A4F0DEF1F00205131C4A8DC3473621"
	"743F240119694046BEB4297397627C0C30910CC6C083AFFF85CE1A2E94477C1FD229BD"
	"C66ADEC92FE9CE787B4A0966EEE257D7D88B8200E25F50907135FC460B57176AF0595F"
	"538324169CB24ADB05BE4CEC0CFC9C85EC12D2C54E2ACF884A25082CF0B9A6397CF973"
	"40E10D52E12C958F50CDD209D82EA45B3A03A71CDA20E9A877A1CA6E954F656F20A2FC"
	"2650D83135C8FDED5018EAE67642DE6A836A0D4CE90CAF40B70DE886546F5B388FBF41"
	"1D32A973335FF2DF50F932909A9772B69A7AD788CEF0271738E333EC3002AB6E043592"
	"7680685CD3E497CE23BFF39BA8693EDB33C0FB530E542AA5C64E1A42320003F3F76AA4"
	"7A54278776277083C9D3D2D9915E606034BE6B441A0BE658A5FC592DB44E83EE12A1F7"
	"9DD7997E18A0F44C2C6DED5578562AF84D7EA11168A8B0618FD6E87B1BD162CD83B2D9"
	"FD53E059D27783BFCEA760609B06C4A1420E306207B545D0A8FC02EA8BE133075B8058"
	"5B340852E7453A00E996CFF61B9089EFB38846469F024E74E86534F8A0143E6C6045C1"
	"596D1D507646A931D73D3727C2B3B18DA490AB3B618BB1FF31B611BF941AC44DCC24DC"
	"90718651E28D74817307904CE4532BE4CFBFA63287B802D0EF03E8C89C27CE2132FDED"
	"55246C33A4A299775A25E3DD5A75C459F21A99AF7B8F5291E44ECDE64B355B8ED77044"
	"88D5D28870BE23F2773C2485BB40A5AE50A96DE9ACD75077C0E8D9253630D8C16B9A2E"
	"4A6C5884A1FE0180E0EB7FE408BA35DD5E439C6C2C1725756C8F3800CCFF8C45B8C9CC"
	"AB920EAE6D80DEAC18B5546F8B289D568CA75E25BA4500AB0D88457576BFEE95751858"
	"B0AE6AA1EC46742F67C0C0E5B0666B9D4345BFD87D1D0E660EFAC7F7F090FFEBF0DDD7"
	"089FE30E5F7BF83A09A3AAEF3ED9E113A2E1F36F1C314577304D7007C05D3473AE9D76"
	"F49E4469BF286D578C931819C10EE8BE566377BAB41C53D063030E585AB9692DFEB5FB"
	"E438296895827CD9CEA00CDE949CE408FE1C9B19B4F2A59BFFCEF33C74BFD200BC04D1"
	"51CB7075425FCB7D8407F723EF3DF431EAF9700CBCDC012FA807F253F390C550540E5E"
	"02B9BB378E6B8391F98762D14194F34688FF30001317066F82F84A7E15E463CB3CDC9A"
	"1FA03867C07511AA3C5A2CA2B16B0FE72D6CC24AF38F43DE5EC8AB2AE98939CCEB4379"
	"258930E225933208638402612C787F25CC21950C5FB7D7907B9B0A9E6DEA24F26C390D"
	"26197AAEA08E531AB6FB1F3559ECBCF5085FB625184EB24989264730146B95BE073E84"
	"6CC00BB06CB5B6F40343FC563D87596F0AC1501264FE96BE812FDD69933659D337EC6C"
	"14D02ED601FF82EB143058367E7520BD4648DF25F89FC730915FBD53E05757C257F042"
	"2C3E051B63B57543FCFD9EF736B8623203A17739E6CCA12E662A79FE09269DD53F51D3"
	"465FAC92D62A6DB3497B014D8D35BDD6AFEB05C4D5303902614410E6ED6CB40266695F"
	"FACEB5484C7A0DCD20004DBB0075905FBD59FD022282E763B53543FCBA97CD55C571A0"
	"B4F748A705A909C642D03F1D789549F37DE80A32C2ECFE15D4C7F2A4F16979D2531979"
	"D2CCAC3CE998F09050284C406F3CBCF7F2782EF681D602B93D09B9BF9C3A9E62ECF70A"
	"E9B0B15562B5079D398E452189AFD0B8F07D107522B723EAC7CE20B2A7CA82FEB67E23"
	"BC54593A80B5387489206DE1C1C66C8EF2E5BC020FD5FA378211485D0993FECF90E0CB"
	"D9F93DFE8D51F0EFBB3C5AC5D95D21F3D920F6C8D9C9F0F8147B6C573E9EC342BFB7C3"
	"42FA8950B6FC694AD9F03D16C8F9E725FA5A435FFA6720512EEF058A7598F7EC66FADC"
	"1320591695A7EAE8AD237B43152E1F8CADD5BBA08E964C817E2A40294FA7D4058050C3"
	"52454C9DC29E9310C103BDA8A9F5ED22AAADFF2A80D3678AD2A2E4DD2E5120D91F1CBE"
	"95018CC38659B09B8251D8D05DBEC94B00DEC1462956535FFCD38F4041DCD18EACEE53"
	"01ECD7C681E0AF08E5012D067DC10972C8C3ACE632663551A86D2D8CA560F403A27412"
	"3AFD28E93C8019483416C88AF1A56524C98E011A366CBF82928EE8E8A9E53DDF50BC57"
	"91FF3B8CF9A371E00F08DA9DE60DBCF70536FEC86021703C2ACCF28FD0C04034903C0F"
	"78CF7008E07B8067EEB3DD23A0A72E68C1FFF0D906B10298E9B3F52D4F65036A9A3CEA"
	"8CA2C02006C6D1F08101C569BB1DC6B334202F0BCCB43AACFD7329F04DE13D50004A14"
	"9E0C9D85EA9E5A6757F0116D8DAE8E9877063BE861CADDCF46DD9F916CFF70059C64EF"
	"E72AD9E08AA994170C0273737405913190E8B1FA737580B7BEDA9685FA896D010AAB6D"
	"F57793F0A297529124D19F5F9FB94B1E3693263D3A39DCC5F5BDCB313E5E8BA1326F0D"
	"7A030B3A9D3B20D580590E9ED705EB7560AA136AC251520D36141CBEDBA1B1E589E40E"
	"5FD6D00D4BB0A1CE346C46189AE58C664D8AC43ABF4A0527A1F23CA82CBF768A4CFBA8"
	"89E30B2F1B4F20DE66D286A2A3084F01445E6F2F2159DFF62D93F5491BCA1A5CD51336"
	"14F85BE42B827F077F6AB4357CC50673D0351FCAD567D612BFF253E1930C1C31812403"
	"285610B7ED26E65F0ADA0015B2DDEAB04106132FD0EC178F40621292DE557EEC14891A"
	"3AB2615D0289BA037000F85990DAC281809FA6324615560259CE788760AEE33D3B119C"
	"7717EFFD82891168825A698012C8B2FA051D9205E94741A43C04540EB71C556D4B4629"
	"56DBD2EE66BA766B44E99214E33D7E9CF6C0190F90669A3CEF996659A6FD0FB2046EE4"
	"7780D69C8C27595ED69286C591964091DA78ECD51035159C900A8ECB877E61B2639203"
	"51A5B51D6F0D0FE354C5667071B2FCE42DF58A477FAB0940CA9FFE0A75FD861B28E508"
	"A484776CBDC29F48CBDC2594735C176EED682B2A6F9FF3D4C28E2CB97D24B9EB79E60F"
	"12AC7C24B85A7F7BBC469D05040AD32A69BCC0092D1AC671D440072E5F3A62036F4ABA"
	"609742A2B7D665B04BBDBF8FD34007B94F13D6DA327795E73F882A906DE39C3781C93A"
	"08266B2DC29507CF25D00B37D2F4C8441CA126C210651B3864E1C0349C99A7F22F3797"
	"E7AF567E88B4380DCD5D9E765B9E791BEFA98761D43D2791268602E45FFE2991262168"
	"922DBFE8DFBCE7B3281CC857354F52CC6EE1B7940918F937D0A892C3A805CF79BB1C3D"
	"9D58765BD6D058D13F32D6D9C9EAB7E8A1E0AF1054C8A1699419FF35D218FA8E501ABF"
	"7B1D41249104B7CB55AC488EE8CE59A7CEF77C09DFCEDB9659A5DC5851EA085093E495"
	"54CA9907C37AB288EEE4511CD4CB39D5676CD0C76FE2B824DEB30BC34BBF21F43A617A"
	"E40D14C1C6B551911917599E0D747CA241959B97C4B972C919ED262118159CBB1A7C68"
	"305FEEC19CD3244A5A317B58A3ABBD28DD204A23A04BFCF412821A064454676019D777"
	"919A99871BF41E7013939CA940C12C4641FDEB9753E0988DC8ACE0E71685A5E93AE4A2"
	"7B10C77B8C44D48258783C4B6C98986A03CB96224AB9A7C5EC68DE5B83A9DE5F9CD1A2"
	"34AF31FC982899C39344295A34E7363AE344B396F77E881AE76D70F6B44B2364403E5E"
	"45AE25E43363E59F6741EB49B2D28858D0476737518AA3994FA13C83F997D03C7BF614"
	"93C53901D09C168182D12A34432B68F24A80446183DDBFD8F4198D0A43FE206696FAD0"
	"D3F3506224934A42AEE81BA4185FF561432B817BF3648EF7DE40130E11E657C51237BC"
	"FF46871C251BD68AD20128DE89541424CF7B9D17310F54539456B58E99984E976BD8F8"
	"DEBA1FB49E9F1F2B1440E79C0E3E8C201D907E868EA9188700496B9146A94EDE331F49"
	"3D2DBA1B15570FC578838FE4F8068450FE91515629207FF02CF6B4D0490DF378970124"
	"9CD57B037D24BFFE23086CBCBFD8FDB7BC86118E3FE7410CF0785B3D64D95F63B3D519"
	"DEC3C00B707732B2B00E6F6B94FF349F05C28FE0C8DD62DFACA671A259BF4AAF01A5E8"
	"8BF8CCFAD77F07D3EEB9055FFCA2C9FB8BEBC985D9C2C8D179AEBB1BF4D11BA80FC452"
	"A6D53409D490232A8CB5AF2297AA5535C4D8E74717A8022E12B9670FB4CC285EA753C5"
	"F5B10EC5B74131FEFA225699601A2754E79A1043384DC534F4CAC2C1E6C255B9B7C1B0"
	"6A378D431DC0FC4839F0C14C545131FE194A87E31131EF1E8AE207A64C025B9D0054CA"
	"A52714054805A23B212B03D49216C29DEDA055F1102BCA29D082708F7C69ABDCD185CC"
	"029C769C34DB9427ED95A75F5014B0170F11BFD1CC9C994B1CF67E448A057AFAC20BC4"
	"991797A3566F8D3047AE7646544852652BA9B205FD5AA923D522E5297C08472C0094F3"
	"02EA038C2ECDF137AD6A40741114D0F61F12A533F9383598A4212F5A1FA0E51B571EB4"
	"F8E5E518450630FEDDF7025BD5E902443D48B1708D629C83893EFDAE0A686A0CD4ADAD"
	"60750D3000ADAD607E73B83BEAAAB3B3506E2204FB20D457EAB0ADBB9939E59693B734"
	"509480CD7C19AEDEA43AA3E16F9C2B1A5CEAA870D8E1BEE726570214DDF96714D486A8"
	"082C68DE0020212CD841172781DBCB0D4C75EA06C6B9F4794A207C4A28C9BAC9150FF5"
	"DE847A9022B86B95CC5D99B5A0DB6904804D7284C965DF8D62F8F809D64A33B84BBED8"
	"703F9C706E1FC156A7186BA068F8C696FA76888B11682D2D7229C6955E6648684509BA"
	"BD08836FC6C4D03310D76C15A58DA3317E5E148521DE01D13739D9EE9B248BA0883518"
	"3F4A3BEDD26253000738E9DF30B058A52314FDDBA40DAC4F982FA1E735021C14A3E5CF"
	"28F9C05AA609B2FCD90CE82939F7E16CAFAB17086E1245647BE5D8E3A4679DA1CAC557"
	"2263B11B0A87381A893CA695880FC2C38FA3D8240C988C727894BF2D4288CA0EB43A8D"
	"2E8B7B3D95E49C0340724BBE66933FAFA858DE3B86585CDDEC7E3DFF32A9ED14C8F18B"
	"1A391951F939F2FB97E0A4D7DA015C3FAE3C93EBCBB99554DE5A034AB30A70F8607036"
	"8C0862EF2B06EB820AF32050E3562C2E18E4F45D3014E506C0134F41A9A69F283192E5"
	"2A7050C27702302A783A800533E1E944800AF66D2EF84B2114D4CB27C6AA8329B57795"
	"091D0AA161A38E26B8E019F405061FB02F6ED48406672A8EB13E18D460B0F7810F21C1"
	"D8EB1B9A84161C4A3F34BE9215DFFF3C824B508CDB9F67E69D655E11AF37F7BF5412F2"
	"41C5D8DF1D99D252EDA639E5FE5340C77CB0A67DBE446BDAC491691D432FBFD23894E3"
	"F892759E0728F1175A5F32E7263B6F5487AE58CE754AC4A90575C62A8BCD5881687ABF"
	"8CAA53C5C6C9D9D3113934E9F272EE9CAD9F1306FDA6CF118344348C4B8201DF1D00EF"
	"228B739DBE1A7C730E7AF7CE11F0B00A1F86A0DFF405A3F59F98606B193FCCF35279CF"
	"9368609B690E5F9DE63F2D6B45F3C669AD66E2B2B0029B8CBB82BFC05C0B8905E71517"
	"925E8A04A8926CA9D428CF99C6D64D0D9F7D4E2E82469ED5A828B874AB2C6C4652D58A"
	"96EBCA13F01D58A8E25BC0F09D5EDA065F5C049F25822F46C5B7F47FC607EE01586EC5"
	"F834D56C6CA87CC495AD186318DE654B19C308EF01F9E5A92ADE9ACF54BC4BCF01DE2D"
	"E03F50ED2B787E1D7CDB4A5AE37BBD84F065B5C5D733826F5C045F0F15DF4725D7C447"
	"F399907810EA7117D114EC5A8036CA38FAA43A0A41C6EB27D1786EE07B5838313B99F7"
	"D052B43B900451AAA86C10CDC1F9B2E0B72862118C30CFF512A5CD62F00838B19BF91E"
	"8056382D2A9B4577087AB0002A2F40EB8464D1BB6BC17168C2D9B06A00538E857196E8"
	"48986DA3508C1D4BD8D8EC25B7C26E1219315016E78458191E4895523E0FAB36168ADB"
	"0EFA52DE85F7F0033888D8F38A02488D368004E54BBA0DF9927D432C50D6CA9FBA367D"
	"769F3E3F8C8E9C61641811896132C007C134B88F6960DC798E7614C060D362732CA31F"
	"1068BB877408BC4839A71E24B03B0F77423C89A51B81AA27717AD7823216EDBE474DA3"
	"84F57AEAAAFDEB7FC6AFDE477E6EE3EFB50363AF18750B90E59B2004A94ACA53B6BA7E"
	"B29B7B7FD684F207086CD09300AA54ED4AD81906EA7C29333E611B1B84C289AD4C229B"
	"BFA689CB854D686C6B9D71142C272079A02B7F83EFCBE2615C0F6D42DD528CFEB6B994"
	"9F259A0D2990EF1A0E05EF6803B4B418DD2018A1BE028363CBACC521356D1DEE97CAAC"
	"6591BEFD39D5AB49288EF858EE8D59C8D42C51B9E5D6CBD145FAC7149C24C7450D8CAC"
	"8186498274D026D5DB71730D7497670198249B57D00C2F0442FE9C6518ECE76393B980"
	"739054E9AED70ED43AFB5382C5696AA88C76F5A0971267BB864A8D0BEB8CC13AE07AE5"
	"E4E2037800397D1793CFE5CFB9051ED0974535AC71E6C027033E37C3A7337CA0724A13"
	"18EF703A3C1CC50788CB53B6490C5C4AB9C4C0A57C243170297FC160D37D4971A1A3B7"
	"50622B1016705BE5C487D19BAE091B1CA0F696694F09D4DBD78EC65E015CC82A9FC9E1"
	"1690E3B8712703183D102AF3B62080B97D95DA2D16E907AEA241A53B0206FEA541EC41"
	"2EB485B93832F85FA8A1B867CFEE9F609A94278D4FCD939E4ACB936666E05CF865F152"
	"2BFE23DA54610C48C0823E6DC82A1D5D780159EACAB14AED05698321353595CB299A36"
	"9573F610166E86B75461E105789FE6EA26093AC8E6B81C97D3C4B912A16B3540A4896E"
	"4E00FD339A6187200ED7C5202E02677336AA0F731FBB03AD0DFA5E5F711C8C018DCEEE"
	"36692B4E1F497B4199A0441A90992AEFA0A090ECDE28EC1EE3B0A34CC2ED479341C12C"
	"C284CAFFBE3D45A2D43E6F5D2A87FF516537E4256CC85B57C44DE3A6E2BC877983B3BF"
	"58CEB2533931A14E2C6779D360C8AD73DD4286659D8B7372B85353345029F3066A75EC"
	"7FDDEA3BE761AB33D7A8ADEE01AD16D4C0A44DC3F7FDF11F1BDEBAFFA21FCFAF0BF550"
	"67DF3E9EA3F6C296F52E1A1FEA1BD0E87E01B9F26387314233DE79825861CB3C0CD9CF"
	"9C407F283BD9D98E8D0D9538309C0AB7CB2BAA440B5CADDBA0505C677883E03C328799"
	"7E5CF682AE9E3087BA7ACBF867453F9F82261804F9B20BD0B1E55F0F611C081A6A65D1"
	"64255F864B87766CB4624C9ECB86F3564140E5B5E09512BCB72F8767E14B5B01DC31E7"
	"4A805BAF6A8FAE41EFA0EBD23B7BCE35E8555D1B50C0F372D3411425C4493B5AB6AE01"
	"BB126733CB7845F92D572FFFDDF156E55BD94F16941EA4A0145CE3900C0E1523D92E6D"
	"A11D53103A6E8BF0637633C15370C07182765DC694FF083FFD3AF067FDFF007FCB816B"
	"C3EFF17F043FB50DFCA7087E0B68D5A99A824E71648D1AF8BD7ED635F9DD165EB7FF0E"
	"9EB3353C52352B7456D67E55F23BF7B755362BF67D5404B5F5D9B322AD6FD5E6EBC05B"
	"F81FE03DE3BA16BC2BFB8328517FB8F33290956CE95F05B8F2D9FFBAFFAAF07ED8773D"
	"78E3FE67784BAE0B2FE9BF8497D70C6F501B78F6CBE0D5B8FE5778BFEEBD1EBCC0CC2B"
	"E1E1F243C484CBABA13ADB270B8EDEDC99CC3FBC4ABCDCDA9ECCDB7B557BD2E90CD3C7"
	"36F0EF6D0DFFC1FF009F2F23F8DDF6E2F6A72BE0AF71B6E93F91780858C138717C0F72"
	"A2929A7F595C03B59F7346FCC66BD57FFFBAF5EF3CDDA6FED5FBC7C37BAEDF3F34CEFF"
	"ADBFB5FF0FF0CE3FF33FF7B76F775F4F9F27CFFC5FFBC7D4EBC24BFD9FE1DD785D7807"
	"665C05DEC29332CDEE0771E96C4A66C0EA17B4E053E0D23D394CE82C41A481AB46018C"
	"14D93AC70A533D458CBF3CD3BC39BC46940E28C68D6CA5CAE01FD5997C6E79E7A3E496"
	"40FF98CEE677EB2900056759E02B4625C11F4B22FC11DBD9E04F547A1D26C4C333975E"
	"A36C5082D01FD2C0312A0072B0BD0873927CC3030C2BCE67A797201DFA193461854DA9"
	"DC7ADDF98D4300EDAE125C9868A4D0E6305B6FEDEF5674338DE53AAECDB40C85F5D5DA"
	"3E59D95CB9F62A59006BF702750EF71506A89F5B890240515729ED00489179EF2BE0B8"
	"23708633383199B5F2449A2BAD66D3BA57F6AAE46758FC7145FB662D6869DFD75309DC"
	"C06BB74F2CEFC36571D92457EDB59A991821EF29062FE7DACD0470B8B6ADCD0C387CB9"
	"51D76AEFCCE754805DA736B777DAC5EBB637094A32FF795D864B3DEFF1FE54A60ACC46"
	"76061D03CDCF528C774C631687EDF70F809AE3A11D77CEFE306DCDBF14855AA34CA389"
	"72DE732A8A29F5380D5BAF40DAFCF9013CDBE15B63C22355D5FABF84D94E219C5C9E0C"
	"0FF2CB637046A7D6EE2F0CD8FC822E731776B334D15D4BBB6C4C8988E1D569B4B670E7"
	"217CC9984A2BDC3D0FE18EF59C325CB3EBC1F19C74C9C2BF5A0D9068BD9EE292B1AC5A"
	"CC5B6C25E21EC5F8FBD344D937C5B844A6C125B2E7C713B4DD07B13BA5FCBE0A03D894"
	"BD2B681E070BFBFA9743169D96C03D2949EA524186D59FFB07F49B63F3897AEAD718E7"
	"44FAB662EC3235D2BBB04F3742C624B665486667679E59419B4FB24577B0BB37E0BC41"
	"F41794C8A727D1568E09A6290E2BB0410CDF0CD4FE08165BDE37A9E5FC08C86B0A495B"
	"EFC042008CEDCB379E75B6D946F4DE24B6D40525F451AC841B4A586F3E2CF0A5891D17"
	"C56288258A4159777325242441B1C37F85C85CD4F0A576AAB5155E4B8EC42E12A32229"
	"EB28A56491A82542C24FD1E4D39439CD8B439F3FC566C83673CD9CB2A0295C3BAF2DA7"
	"447FF1A8166E85A7B4B680A715E386A7D8068E660BB863227607E4891E1984B4DC89B4"
	"CC8EE69C69E5BD69AEAAF87E87CF368A2FAB74B88FF10E689723784CE770D7F38E844A"
	"3C1E235AF9526CB1DFF825EEA79476C81DEFA79DFBA380C08F672321514FABD31C72DA"
	"0575F92DE629B697759286995E526F89A92F584BEC1157EED7193D56DDA0351908F5FE"
	"0537B91C74F80CA3F7E35E96F3F1BCF74D0D12DF9E73DE2C16195695D20A6CC13A4559"
	"174FFD7EF9BD2B53341C586EC332C893A5AD8AE2CE59F43E2EEAE066A31132D15DA318"
	"DF7C923601DD042884927900EF4687BB782BC77BEED2441679B61FA4BD2993273E341E"
	"4FDF1CFD89534F7CE0868A5156E91CEF69E0D8290360BE61FF4F9C7ACA0027022729C6"
	"7D4FD0F118A99E7AF9D76C3F4BED4F6CAE671CE8EBD33582DF06FED20FA0B54FE31EAB"
	"817C990D8F21F4B54A367C1F849BC744BF2DCBE173DDEEF015A659A5FCB43C690FBC66"
	"A9E1FDDA276823509DF0B5BAA9E7763C239026D9D2846C9DC9D5C7A1543A04F3F7CE44"
	"91AFD802498B9DBF84BB3BB25D5B9D1D71BFCB4FB40B7FAB54B055BE7733DABF064835"
	"FC44FB00502D873FC1762F8FC3A9C949BEFE3F9CC009AA06670C28C1A714ECB0B08B31"
	"898E19F97336958317E83D8D0D2E32C47E45477E96E06ABDC3BDFEDEB7413E0657B1C3"
	"DD647056C93F6F4601BD780267F68A00F53F4E4404D43899B6F56FCF6C70A41B1E3F81"
	"74E66F9F132D6DC76F508EC96FD0099D8E4E1E9ABFC761AE71F076DC9DB55DDD573689"
	"AAB8D2A48234D959AB28BEFE379DC0D353B3D7201D4DB1AE3FC94F13F278426EC3F34F"
	"CDC8E74DC642A00FAEDE00BDC6A1204A830141D2EE2E62D88D0055316CFD1779C68C01"
	"92A1CB1A34F43FFF0B6176F2E7BEEB7037F69895007D8B2F5B316C4619B22488873656"
	"0C4345F519425F72DCC2F3B88598F7AE8111573E50DB4AEBB65EA57FB05DC4C203A27F"
	"952919A786C089D221B9390F01D6F1BC77516734190A247CBD87E3068340D600129B7F"
	"96C6E67F1C9473BE691CEF4DC6F31D65FA97F6E086B280331EE84CE7BDA3532855FC12"
	"E1354E76E6C3DF29CE61F0F701DE3B20059BF638E4E9796FAF14DC043FEF389EBDD9C3"
	"2FED8AAF865190473B8704F33EDE5AE3330C8604F9B55D8A123ADF1D2C6876CE70AC00"
	"3D6749A83B76871F2BDCB4B3649AC6EA1F56BD4C4A7087B46C6B2A3DE0CE12A5D639D5"
	"1DEAE0BCD57D7E28EF15A3A8A51F7EC17168218A5E037A9707172DC2FDABA1745A9034"
	"388EAB4388629CE9A0E2B3587183FD382E12FF28F0CB2BA9000E168F2A469B03EDFF70"
	"DCC0246BA8C250AC20194DBB91DA6A7E79C0A73F4D7B159C7A21614F58EB3E7A11C05D"
	"3C86A66F624BED7FB0DAB12A759B5E65D4891D42CBD8CE802F21C5BA6876472874EC73"
	"8E9BE2029F49FF36162B5BD41D85E8F367E01774184F0C5409C7426FFE2443C7CE751E"
	"53779780DFF818217A07604CE6CBACA68134FAF545637D3FBE5BF0692C1E28EAABA383"
	"45F34DA35CFD01575FC2653765F065FB1D3EC289AF8320EB06C872A4DB4DF740FA8D44"
	"CB18D398702AB67339965AC812ADA631006F2DAB0925F80AABE91EBE0260A4D3664934"
	"85C78F72DC7337A39F3D4A90F629C6F5C022E955B519D547916B71D082704F96A8189B"
	"C84F37AC3ACABC7356EB8566C602757380066B16ED5376DE054DAFDBC971E9BCE704ED"
	"701D631A68368E8612AE4E48495FA46980528BFB5D6BD8C1AA9CCFA1BCD577CB3F3EA3"
	"57BD03BE952ADC426EEE5F7A04602C2EC1E9657F8E8F0A64E72CDC893D32B72B2E15B9"
	"70094EEA3DE3332232E6286EA0264108BCF5079BF7171B6FFD55310E7B143962CCDAA9"
	"FA227DE1AFD364B1227F073ADC17D25D3304BEEC9CCD9F8B87FA8CC75743EBFC4302EE"
	"C6FEFC8B87BB60C36F59FC25D0F00678191EDD466CBCB4D833C181FBF0B62A47040CA6"
	"0C2F1D4119BC7A0F93EA37B8BD487A15FFCACB3682F9F6E5E41C69D6C6EE7860952F3B"
	"63E3CBAA1CDE5D4E1F10D1D3751B30EF71C03D9DF73ED685FA64693D36755C175CC791"
	"4375D059ED5D50BD2EDCC17B87D053CE00A8F01CEFED076F92FE857AECE01BF9C5B7E0"
	"6BCE78C8732B19B3129E5064302AC153FA70FC5A4B0F8E339FE7879D87822E03BA3C19"
	"20F0D06FC9806AC92FC9B4987DEB6AF2AD5EFF02468B1E25747E203B276E356E20A0F5"
	"63E067F806B128C17DBEEBCC1869F14B2BD703BAFD8AF107C810948D283CA83E0EAA5B"
	"CDB79CF991E3E657845E49460A8FFF4867096DAF34AF250A9FC70A6525BC35685DE447"
	"7659177D839AE7D3AFFD91FCAE254F6BD10E3D1C65F7F77EE95314467FE953A2B284BE"
	"66FD61CBDCB54C2CE2FDC2517763CCAC8E7C69CC1D372E8A022C3FBE0C0DC3E3867EE1"
	"006675C2ACB4454334905789793F52DE87CDD5EEA76A1F63D646CA5AD15C6D02ABB618"
	"F370CB85FBFCADBCE7258C1DCE67B09375EEF37DF817FD78B8D1AF2FFC1C055CEA8935"
	"3D4ECA52F207294B8D720404C955D2A92A01405509D1EC2CF39C76907217A408E70E43"
	"A2C63DB80F80E90C609CC9022EA3C50CE14B1773CBCAA9CB4543C145B1EEC1B73953F0"
	"1C73B0517759817F2D23AF17F7488E72E74CFD01CFBD48FA1D90EAEA06746D01175828"
	"39064E2FB4575FBE0CB93E4E1BE6AB2C5158FBA365B8BD448B8F2BE851878F2FD3A31E"
	"C5F702D6E04B495E76698C695CE8556040D5902870C08D4F4066C84BEFDA1278C7FD0D"
	"2117BDEB908579F8FE18BDEBF13D1BDF0B587D04DE0BDF6DAC3EBE77C1F7FEAC3EBEC7"
	"E1FB2DAC3EBE9F5F0AEFB88313F4FF7BD4BF0DA482553A54C33CF8CE736F82E76A9DD5"
	"5CC7FB4FD2619818AB34080232C1DD18E51A6435D71777E64B138031D1C1FAA4E091D8"
	"841A78B671F0E5DEA015DC1BB5002E11C0250238F86C4AB483051E073013C336800183"
	"2E6E03BA1E6663F83BF42EA156F16362518CBB3169BE3907E3C6E2B192FDF9EEEEF38A"
	"335F7E7C0B2A86316DE965DC158B6A44BF3E6E35F4C6528F06458C7B885204B7722BEF"
	"C5737CB6BEB5A4B9BF2E4149B26EC497523FBA2E51632344F18BBF067F05ECDCFB9F42"
	"9FBD697894F5A6B9DA92B97ACE39AB64AE8E738A7C693CE897A76709201F12EFE939BD"
	"9C50046863FEA7B8F593BC486B4220B4920852587F99B0A4B947879EC1FDEAA5C335D7"
	"00A4389F6806127E88D00EE04B876854D4A9D3D51A252DA89D71E5256A0DACDFCB21B8"
	"6B62C3372112BE340A3B848A6731D516E27708F1B57848AD642E04593DF10494038FA6"
	"D17181600822AB231065D5EBAC782A0480429FFCF2301D50AD538C3E88D7425B3BA2A7"
	"9502891A7E69454774ADCEFC9DDC688F1EE70EE0FB5D0D7D7BDFED48762B150718DE83"
	"3EB78DAFD84983CE00E0FD2050195707017D7FBE22C886C42DEC84C33EF8D4C2A75248"
	"DFA5DD6CAE296EEF10B43B1D38B33710C77E4BB8185D093C90D2E9309D62D882CE2FFA"
	"4C168735FD10BA027676B245A97508E9955475240E8C22E60DC7DA59366987C3E71D4E"
	"5B67BDA28EE25D823190BC12110631F20B309A81940F44F2072A27D050BBE210F307EE"
	"59C74E49391FC2D1DE49EE0E3839BEFE13175339E7216A51235F5195DE88837F864385"
	"AB543B7C5FA10F24BD85AFFCEA4620C3425B83F758A56A2BEE5661715421F367B200DC"
	"2D84F62D0BED7DC5C51C750AD35B8883EF57AA4B45F09BBD9A3307610C4EFC86C6E0B5"
	"F01C8AED80B4821480A84869F49090B8D624ADC3B88D5F4D39FD009D7FBE4683E77F0F"
	"12C7180DD52A919D0A23148587938F038D3E907E80802A95FC6A7AEA977E002760FB01"
	"90092D40080DCEC932489B27E09B1D3156AA4DA546465870135D28B27C02DEF2D01E95"
	"71D90152C6BEED51191FFD88296315F3CF1F46454C6E8F0C049AAC448EFF3EF41C0F1F"
	"A0F3C47D75CD743433EEAD66B15B71F22C7B029DB3427D63052359A127E8087B043036"
	"CBFB1FA00A4A406D6E44BA87C7ABD0FB45C4AF049A11C422828A09A68CD037973020FC"
	"603F3575581234FE0B4891F4CBF7D3AC4A67F2E2BAC02815F6313F3E7453129AC9287E"
	"699724725F467EA8F6B7EDD8DFD26B7026E29E0F69B42CF361F4B8C5E11BD7892F33DC"
	"C212DFA3C45A874FEC0C766CB94F2513BC46509D817CC590CE825423A443BF7D2EC961"
	"4B077BE11B82259FF421B7877476640FE9C4FB57F0384E75C4D1F73E049135BB83F306"
	"BE42EC84B0066A2162F523B342432F624BA97FB384FE17B1C16BF65183C7F24C8219AC"
	"6746784A112F747500FEFB2202DED1D99D2F9B8E67D8CE387C4EECE896CEEC409BD534"
	"329C40690E5C11190976EFC21867D4B9C3C27A9A9ED0FE20F8EDA6238EE6B884FABB3C"
	"661D4E3DF8D5AEF4E13E126F2B9B81364024C3A2CAF36FE380F80FDBA1629EDB4BC4BF"
	"D94E251E3578009E7F5EC448676D017B369C5A116995356B4E47673FBE42E804F63208"
	"EC3E24680356F3017EF1BD08A922AFB3E0D7C562C2D241EDD0FA69414860DEC2D12D2D"
	"B363CBC8CA39B487D416B66D59E85605193C9AD178D6D04C23F43CE2AB9DD94A3B2938"
	"F18F4C2742B7B8F40EED96B0D691BE8570441050A7C5FA111CB5A4B5A7F6108E970D6A"
	"F831C02EE9AD2FD2B0B2DB91BEDB8662BB09FE767075C4150F3CDE16D4D6A0FD3707E7"
	"C709CD0235EF8388D7C1DBF7210D439D7AEA35200E5205DFABA436D14D88B19861ECD1"
	"8C11F472D70BC4ABC3D6ACB91D9D3DE16F075707BCB5A335B6057156525D1B688C603E"
	"80E804FEDE0388CF76393EE266E8B50B88CFC0F0AD4E44459A60EA87715F0640A4938D"
	"CF69FD0F2A2A17DF6275C940841EA4BA3B7763DD258760F40C4D4D44BDA9A094A50F27"
	"52AF0C7F21193F8514F705E8CBF989D40D013A0C6DDB04800F846F027E4F31F5034CED"
	"20753304553F43CA18533F65B3CF3873375DDFC4974109C9F8180102E0BA44EAE4DF78"
	"D56E7303F5CCF6C86BABDA69CE101BB43F44E27CB410E61F80FF3F206F1863542E2C3B"
	"8F2D896174FF3D015DD1C3EFD2A444BEBB51EBECEE6E8C05472D81500E4794EC206FE8"
	"394A32DCEDBDEC80FB9A3C9A02EDE1C5D3CB6E3AB61EBA9F954D208AD7629AAB23CDE8"
	"4835F2F6004514A73C4C8BFB09E5080DC80CF0FEAE588FAF085817AD8F45E0A1B80464"
	"F283BB88D83FE209EA576ACD01AA6C540CCE41D86723E0DADC3FA06C009523B608E6BA"
	"E20CC0B0C19AC530388F2A5BBC87177C17EE4AC4A096BBEB1B1DC1A35A87B64EADC506"
	"14A824F845D49144901C5A046F9BA17B001029DFF715C4BD63E291E80F7632FB4F441B"
	"390F9B22E967CD5A47D4E636B7BB66BE16AC339A6F6FED73A344B42359EB9388B89F89"
	"B8E36A6BFDAD15B2F69CA23882C7B40D40750CF4F1F42D6032DD471AE1C1E10EC602AC"
	"393AE88E3BAE56D77F0E5540C708FC300E2933DC1DA0B9F158D74C6223797ED0E1E7DC"
	"474E608655D2F7C2B90CBCDF4B9002C000AB4F7FC34ED29B5B1DE6EDCE9ED800F4FCC0"
	"B20C98FD5D84E1EA08D10DA9F5EE9A032DDD7F59160759CA167ED18D71B4C515E0CB66"
	"99252530D256E0A9969F61581C5D87530C676389DF9F3E0FCC87C6FB84E4D0D1581A36"
	"33297F2FE5EB973CCFE67432243199351FE44822839E680531EAACFE21308E912D42D7"
	"16DCDA9DCFE904FF682522DB88A12A6C407EEDD941FC7A96E1FAE86DC4F5442CADC03C"
	"5F04547FB01E643F2E1665FF772AEA1D118B6E4E31DE5516D23BEF43FF262B56D5A701"
	"3436F7A393F00E731DAE7A4C17FDC6B422BA180C7D5041095AD30356DA7DA804E41359"
	"6C6D64BA3C10119D8A21CCF22380391D137E8841CC7731CC3BE9250A301B79EF462A9A"
	"BF6F9D96560CBF1FCD716BF1A87DB5ADAE1B578833E27BFCA2D63F4A279477C339D380"
	"1E07A7FCBAB513D8ACD77C1BF4047B01D0985F27577C0DB866C4A0E6BA2F4CB649D502"
	"BF3C00FC28DB8E73327F828C65124F1E4E7BA5D6D507CF312D442362490AA7B8435AA7"
	"0152BB81EEEC87F2E10E783EA484B2C19C1973BF4597AA9A057C398F4189F95F86A263"
	"D8DCD1B7B4E8D9188D0DCBDB4EAD0CE3A55AFA94B7D899B8BA68E64479AAE941E78C73"
	"374EE6BD55D1A42EAF6F67D39ED3ABADA6E96C2DF0BB6FC81FBB834FD39F074F804F33"
	"44FD09BE7AD996414A0C3DE6AF84D44496FA19BC06DC399FACE0381DEFCDD66310725C"
	"F4E75CA4C53D9A3EB38187112F4A3B04E97718565185E45399B8115F94BC7486CF5CCD"
	"7B74D158D069D2D8FD3947DEA13D93373E8C8A1E0BFDCFEC8CA3EBA13641E9854D1874"
	"F3FEB534492AEAEC45612CC17B2E46A993BBBFC383B7C109AEDCE608BE1EEBD0BC326C"
	"FE715123FDFD3EE9AEDEC8D26C0FDDE69B55825DC578FF4AE490ED1659C8C46FCAB222"
	"D51BC4F44A7167A3082383EB6E41FA0DEFCC2839C6077F8D0D9ED2594A7EE22D7C6955"
	"A05E67893F0D4FD5F4D428F0A595F0648D3F10AAA6C3AA8DD1BC5783C77B0840F0D7A4"
	"E0A9D8D02A9ACBD68A667DA749B49C4DFBBC2B635B8859D3B7991887FB9EBB78EF3754"
	"65B398BE45DC795E749F8F727684BF208CF7090DBC6B8372ACE87F304A6D5E332CBEF4"
	"B4FCD8E5E0A65E0B5CC17F06D728776E01C797C58360EE70F2AD04D8FE72E0BCA7945A"
	"88087E674F90F61E3C0192105EFF2994C7AB2D5FD7A735A977F05E889C399A82E1DD74"
	"FED53FBC8526AC84EDF35E5EE9C3964AEEAB576A9447F5B9A21509D40A3DB4C2752F55"
	"9F892BB70740BE3B50B2C123B1C1FAA4841A947C424D9EFB6252319FCB977A7270AEC7"
	"67F72EA35E9D540C587C89D12AEC3C65134EE7205DAE0E790B2F2258DC12FF6054682A"
	"461374D8D0CCE6269739B0373FA361270C459F4A1C95701D0B3DA4A1DE00AFE76FE7BD"
	"D5EC005C10425AD954D6A2FA742BD4A4283909D2DC4D49C5A39050DE7F899DAAF81443"
	"F0E6FED04CBD04D4CBDF96D186E4C7A188BB891779EB76794BA9A2400B944A0432BF2E"
	"8422501BC1FBFF092FC3FD03A99701E8D18534FA24CD07708931F27406AD4B21766705"
	"8B20C0B9A5B83A57AD532AC5850AAE81CCDF1A76408306F3DEAD38D1DCE0EA0895BE03"
	"FB2BDF5B8A93015F9193E1376CC2A481A557B633AD94B5936FD3987022AE7FCFE3B821"
	"92FDE3EEF2B1968A78075AB6A8E35F0D825114235C06F9985D16D13FB7ADA2E05AFD6D"
	"7701482243F856C3B5B6697EE3C409CCB479B3C0A30F1B24955AE3B009D816DED381F5"
	"05D98DDE919EED61C1AD23AE81E0199D984BA3D332A1DC42BD624377F9F1C164B2B752"
	"8EF1ADD16C4705DB5B210F87CC10BB9420E7793A3C4FEE440BA5C577A2434A03B81DED"
	"ED72769BC0B37FA195997B47533013DBA2E4B3D8DCE6747763527137F10DBE7479923A"
	"333D622EB27159779FFDD565E12E62511DA4DD4D69AF077C90AE628191308B7366E481"
	"B9BD8C982DF2E9DECDC4000DFF7E5351ECE64ADE3B970EB3EB8F56B353AEB7406B1BAA"
	"D153B53D0F1F0F0D544A5DD800227FFB351CAB52ED6C73988E0EABD34544B4B43B1406"
	"AE7FC0A73B8C518BE153039F43F039099FC1E341B1EEE7B8B8028E7BEF018EFBD7588E"
	"FB1D9E7F87F45741349B4029EF7A90E35E81CFBE8738AE349FE34E435A34941B0ADF4F"
	"429A03D5D9815715456975511A7D744C6C5C7C7C972E5C972E09095DBA7449EC62E882"
	"FFF4DA767C525474FB0E5D749A0E1D3B418AB1F30DC98E656B4772DCF27B39EE7DF8AC"
	"81CF46F8EC81CF71F8FC0E1FDD288EEB751FC28F8B8B8A8AD3EAE25AFDD3EBE3A2A3E3"
	"0063F33FAEE5A9EDFEB8247BF3FEC982568BDB917B5BF0A842FF2ADC8F70C626C976E9"
	"A862BC24E2154BA239A518D29D69F287FF0091F852A655E146A9D026B651CA9753FD15"
	"FE7DB80AFFDE5C8563D85918B77BBDA12836EF2FBCE7663D7608F4E4856F709B129E87"
	"031F01AB83967537F15EBCD7CFDDD4CD95E9F0E53C42C0A6C35FF9B643A401F22CA8F9"
	"75145D5439BBBD8DB77D6F051AA07AE82B769752F52C96E534F0655BE49EDF430FFA2B"
	"2A81F97BDEBB1A952C3BE7FD35D095C6420B6FFE53F346A0CF44DA7D252C670A7603EE"
	"4F1AA71EABB2B3BCA7D7506D07D64E16A46D62B57EEC1A76545C5EFB1DE0C9A4D3F839"
	"564C7419A084FC1E26A3BD827A6337E1A8CDD3BC8AFEE03A3ACBA51EE3C2133369E8B7"
	"2AC61286AB17B6E8981639D1CEC557EB0D2A7F433B288D77B597F4856B7025EDDC4648"
	"5D4BA971BCF735B66CBBE1596402C5A1BCE779DC55D3F8314591C18D9C7A1D0F3F8CC2"
	"D0379EA5FB228F0B15145D513C41F15FC17108B5F617B7C3E06F48D6FA648AAFFE054E"
	"B8AD1E5240A4635F531435C08B53033CDB71A9E03860190F58E4673F827C9274A82B90"
	"979D63DC88D43870DAA429CED91177A2B47337C582DBD914CF7B47E22E8CFB3FC6B16D"
	"8B2F275409101E3D0C498321A99AEE7863ED47EDC82986D728DE3B919A9D5A3C48EEF2"
	"316E8A49D9ECA22BC1DA6BC42243F42B68697C2B9AB7269D7D19609EFE880ABE8B0517"
	"CD6B1F7291B6DDB5A083A28FC3ED17BE945FBF003493F17249FDB92F285E1BE66EC4E0"
	"84ED81D80E6969BC3787EA65B8DAFBF47BBF40394C039242B751EA10A6C4BE9CAF3127"
	"A700730C946373C5FA476C0A35A1496FB2BADACB0F033999B5F2A135A0273F536ABE8B"
	"974740AA5C0A834F681FA589AE3120D45F9CCD4245300179CD6750ACC7472458794344"
	"B0036CB43509C557C5FB71ED0E4488C7D53F81FA551E0D5DA1172A26C077BB26C93F7C"
	"48003E6A067096AEA4D6E3FE6FAB5478DCEA1B8757264D835749E31362F832BCEF4848"
	"E04B85E84582014A8E71D29E21D9E113DB49FAAACF911D1E5CC84B2624596C3B80EC62"
	"880635235A6C2515343AE9BAAC7A41CA4DC65093AF08802661C419871127E915DE0576"
	"140A9D10FC790A849DB182FF3E056F330280BF0429EAB259E07D88546091FF789F107D"
	"3313B9FF37CCCD9ED38EF7BC84A3B010E3D3400B12A0053A68816191002E97FE15DA75"
	"6DC0B27CD9A8768A718E8DEE86FE1657EB7C29BF7D465F8B213B3CCCDD54E48AF78F78"
	"5BEEFF390CDE43DC4DE3790F7AA3EEA642DEF3323D8C72CE71378D733ADD4D0F39A7B9"
	"9B263A9F5C8B81A2FCE703A4DEB27400751AEF67439DCE736F8C52B6439C7E01A7639F"
	"1E65975CE3407F872E653BB8AAB5248E5333C8AE25F19E87B43484AA7BBA78CF481CE5"
	"933F006D59A1A57BE7562C45933C16C043E4C485DF919BDEC7BB69534A03949DF219F2"
	"05E72F445F4ED2527C99BB9A728AA8624A80DD3D172AA259D4F6F8CA2C8B3FB7CEDD18"
	"37CBE8D31F5C82257FAB6077E287B2B16493D9D5A55A7FB882B50AFA6C24B71BE5DE03"
	"7E0D3CF873374270342B11E8590E5843972E615ABDBB919F057DD04B84A43C8939C769"
	"8275C66A9A45D8062FBE9CE72B28BB0760971D3020844AA9CCD40A0A31F7B790788F58"
	"642CA8C0D1C7F37AC91F909C58E2B78EA8137CEC35475980D1F7F3505BA8664998127A"
	"E6126B87D99DD3196AF3C5D18ABE5D05F5FBD9F0552816E9158CB97DEB5FC43ABCD772"
	"092519FE167F8C01EAF7A1FAF7CC079336985F72739BA6FDE353A27DE9A7384D4764BF"
	"FE2935EDDFE0D02BFA8FBE2534ED110DBBBCA75AFF67156ED8E0CE79E95BDA00E6A16D"
	"5EDFBBBA02291B3F210BB77E583DD0228F3D08FCF81057169A26B8A0FDFA0F3E41EBF5"
	"DC5DA82BC37E8022DD5C374BFAA59FE0715B9FFE453CDAFC464BF51BB0FAE3B81BA748"
	"FFD427C8225C97704F24E21E64985650D1D0085ABE38FF0DE8972B0D0756CF5D2ADA76"
	"D082143F60E23DDD2F92CE25F9D1FEE31EEFECDE3550C3750774181CD1CABE61BFBB10"
	"BAF887A2B0EEE1DC8B50A0EECF9014DAFD0762F9331673DDE26ECAC44ACFC35B1C56AA"
	"69AE34182AADC5FB18C377B9731EC37CDEFB0FACDA3485F7182E448A25478AC9EDF029"
	"139F742A3EEFE43F3066E89DF60D4E53E3DEBEEC1C0B5D46661B97547A5171DD0623F6"
	"FE2FAE31626FB7D088CDB335518401D66D1CDBDA8DA544566CB5C0EE908AB6A6FF6AF3"
	"DD09DEC7DEF5E8A8BE33B8E5CED9C825FE78355B8BD75A788DF392ADCFC34DCFC3E3E8"
	"FFB64B9BF3F00C4008CF76F88D4F8D8A6CAACD03B75A3E5E870666399DB81669BF977B"
	"B3CECE56EB443C371BA05321B4EC69C177760DD83E7CCF12D5ABA7F0781D1DAAF5D0C1"
	"709C8B4F63AB437B2D343D94A618CD83D97D64F7AAE8AD52403A206FBA839D8E2F1C4C"
	"F7FAA4E305273830488B8922DA8146E7DB71BF35B42E5576AF55143A4B8027AAA189E3"
	"93F2A4A792F3A499A979D2B1961387FF353FE6450892B3811679CF8EFFABFCD83638C2"
	"8FF441C48FAD23DBF0E3AB74C68FFC41C48F3BAFC60F815D94D3C292E9E5FF9925E4D5"
	"E3153FB1A3C7D2D9FE8527719A355F3A2248A745BA54A1DA6AEAA7A153EF01DE23838D"
	"91EFFE06AFC2E13D87F5748F389D23F4AD322DA2095BFDC15CD4DE009E831815CB62D5"
	"5174E9F75ABAB28AB706ECBE352631961D4E49B543390BBCC83B6F87B6FD225D127DBD"
	"473E8B152E422B321463ED207C399DF33EEE87F57C03CE51CEC7F4F8053E7E458F1FE1"
	"63293DAEC0C7D045B4B88FE11A82D1F02C72A077D4B314E58F1C8E6F399F8178BDBB78"
	"0F6E79E74BB5A6C0C012D700ABA4FFC345EFD2666583A8542A3B862CD2F5F219C95734"
	"D7390D5EC599A316771EC02B3C86E301F10ECFE298E209A240AAD2AB5D7FB24A1BFC22"
	"6E7D4BB91779B94D3EDB0BCCC55FD95D335BF3C8ADBF13B2DC973450E800CA3AC21B79"
	"732F64DF71DE33024311DF1D26699569197AC6461D9ED470DD0C1EA655DA9C2F554371"
	"D4D467A0BAFF5E9D9D64BE186A87FB133428E7EA04944091CE2319195331F706A80D69"
	"9BF349B958B5825EC8A9634EA6DC1682BF2973D75AE4235E04C5E99A2FBD7FCF8C8ABC"
	"D85412AB1E6C0020D015A5D3A8D9F2D63330F6F6FE0B000A474967F16089A045F21469"
	"6783AE4B09EFE985DEF239B168078B1F94EDA2523B3B9E2FD57521A69EF236F08B7007"
	"8D58B45DD46EE14BDB7B76F1BEDF35B4C7C29A5E25B81B75BCFBB886E6663B8057A640"
	"B500BB7310E3436553D42E5FEF01807FF6EFEE8B3AFE45EC148259E65FF88C264A76E6"
	"49DBAC3EFD7970E2E40977A2F00AA0AC4EE5B17489F72C255CFAFD3355A158CD9B5C37"
	"035A9094BEBD48FA3CCB4EB26A0419C8DDD24034E31109F2BB3DE4F6B1E37881C95676"
	"5CA8710424FC761B2464D2FCCCBC997831B5BFF7F499A491EB21BA722D00AD62774DF8"
	"9F53403BD6401D5040AFA20A79FE08DC8B9A17B5486F9EC98E27A4CA2B6F53C5C52A92"
	"C404BAD4AEB5BCFE9D7D557991B46E3C8DD23A39831D015A892DF72F5004FC3D80D24E"
	"3D14E350339BFEE721C73FECD23764608A4E7B03B37BA8FB41A1DC8D02DDDF48459D31"
	"CA2651D93E47B6346CD2382D9271D90C9C122AD5F580367D0C9D05FAD3EDD0B5FCFAAA"
	"A16851149F71EA0C62D2CCE1AD3A812029F2865B411E4C2C56092FDBC08B066319A5A0"
	"95DC42051BC9BFB8987A156EE39576D8A54A62011B4BE9A8D46F5974B71C9862683708"
	"5FBEFD14B4194C1A5EEC68008AE3A0B3397536CD4013BBDFD87C06E7FC0DFFFC8A2EFB"
	"C1785FBE9BAD862127709E39247197D114E9A293D80F374CFB8AD4357317FD70D03377"
	"B3CB0CF1ECD038BA91C138360F6F0ED3C93FDC824856985692C9DDCACEB6E5359F9FAF"
	"C8A64BD2FB85BD2A82704244519DA60CA4FB76C1D7CF840F3D85EC3B4C7895A4F11075"
	"62C3615055F9D7D7E866341D991100649798ADB54BAA0196541B2DA9D67BE146B4FEE8"
	"4BD0A55F9E16CAAA1865AA52DD927D79E1EBDE17108A9CBF3F88D70465CA0DA544D7ED"
	"C00A33DA63BCF8BC9AA42F6F31E1FBB6C8F9FC2DF2DC5FE87A3DBC33A375BA4AC8FC01"
	"D7BF62E0EAF49C217A7E067ADCE7CF3AF5EEF3BFBBE214E324827500F4221711DFC788"
	"BC1B94F5C4403AE245DBBCF49F4F63D7424EA24B401821F21AFC8504304951BE4134E4"
	"3653BC9D28DEDB427154D6F528BE1ABD747EF767B1E83C320F7F74492EFD8A48BB0348"
	"CB8D9056495876345FD784E7038152B92B5EBE55196EC74AE0B6ED45775F9B023A3F39"
	"090F971FADC2E906C5F8086ABF3850D4D688DEC3AEDBCBED7882221B22620FAEB4B8D7"
	"629491386BB0DC3719C6DD288822676402B449E32BCB859154D2EAEA503E3A8F1E87BA"
	"621877A2C0DFD52F62574E79F007EBD099C3DB3839B6E6F09815D7F1046DE45831FDE4"
	"5CCBA1BAD7FA5F76ACF8E97EE43F25AE8D5137E0D0613ADABA63087D4EDEF6A122B233"
	"781E58D2F8F4FF5C89F13B4E4FE8DFC7C7520CEEB72CD2BFB992CE0B1302E3DB2BD5C3"
	"C9DB32D5873D99749668D2F8CAEBDE8F344A205B090EA51D3DA95F04F35EDE8B333EEC"
	"52631D879C9D3E80DA2AB0A0E09ECF1171A77E84B8908C760D24A7133D6733A968BB3F"
	"93F9D87137CD3C8A38344886B89554FF492AB89508359C7D87C00CBA9BB2F6E3510AE3"
	"E799C8539B162F42547FD8A26A1847BF21A5FF04CF548057B688D85B8DCB6FFEC5F426"
	"1FEA4CB747E9EF7C1A5EFCDD68C7FD0B74567BB750AED3D0720740289A4EE759FBD3E2"
	"E670BF75FCEF9058FA1CD48933122D4386D1913501ADDB2D85804FAE4FC5C9CEFE3D41"
	"304E30BE29C92821090FBD0D7887EEC1CD542FA9F5E5D68BD999AE6300E5380C1BEC92"
	"D0F752E996E1E72C047DCF236C7AB656BEF001AD0A55AA09BB64DFDFD128EF9064B907"
	"DD4F642C9F468D9F03A0E4AD2F43EF30C4D3A95381B76DF3192EB1839FB9439184C798"
	"383A0F55A7779F26CE1886AE26BE963D8565DEECA76242997AFA514E3E160043D24E31"
	"3ED90FE7B89C50341C2DE9A73C456D2E7E0AFDD377A2D889D2D7A3D45FB119006543BE"
	"28724DBD740A533244AD462413FA00B11349FC869A4FE93C673FCAAE2C6617801971A4"
	"3AC1A4BFBA180BF4EA83731ADB800C572AF2DF06109EEE41055E502B75528C997D715F"
	"14E477C0FCFC1ED4BE171EA62609D25E79C4C70A9E53FB1BEEEDE63D6FD3AF69E1F97F"
	"0BEBB3EC1CEC50ED55CE099FE943A76D9EFC34A2CAD389EEE17DD1D57C9F6EF8351452"
	"524506BD8CA2731CC65E6F61DA689636900A3C948153AC8DEC37C4DA4F42BF58CB97E9"
	"C32B68AA2157C797EA8FACC059DADC68D19DF323FEFC83B32BD43E31116BD7F465E73A"
	"E9EC734706772B4E6D183F849C501774CA2E68D9DDB0EE9CDA27A8A5AC277C0205CCFA"
	"324872CD558CD3085023D0430F60770AFB223FD07045A9F7E659300844ABB49B6E8722"
	"1FE4B6BE4838E6F9F5E3838AD23C31D05CE2AB0C55C19C77110F0A724976F23729209D"
	"79D0A6114895F319C578AC0FFB45373CF3EB1F19EB1F1B47CC65789E202B38829D7E36"
	"EBF743F3C12730EB2FE1430778D83691D686CDFADFE1C185B797EF1E12E950F7A590EC"
	"5F9A8827F0C09594477DC8EE7F9E8E6784E99EAC4D3862CCA62907F58EB2AB8C579360"
	"BC42FA3284B5199CFA038C6744E982625CDA87AD98CC3D07E12A4EFD39ED442A5EAC62"
	"AE9C61C5CB7133DC358074737AA598BE4D34D72C18292EDC803FEC2AACE532D8B5B30B"
	"F1741A9DA1673719F761505DB7B2666B1BDB20673F756354CBBCC07EF7713A6B87DA2C"
	"B4E71187C132962D6A9D81B1D6154BF7CA8F7A886ED59884AD9C8C63B1F650E62F3853"
	"335DBAB84C94DAA9E83A11BADD4A3505DF8AF11F1964BD3A654F310D741D40849311F5"
	"24548FF9B81F49572206EBA31882EBDFB7B7F024062F36C08A3315717CD905C269F3E7"
	"67A0BB7B5631F6CF506F2AC069866FF03E7B613D5E9CB68C582A9AC798B25C33452901"
	"EB4D12D65AD4EBEC804C6D06F9ED631D40E724D7BD62D172FAF5142ACBA629442D9EA3"
	"5B8B375AAB7576DC45756E5AC87ED2056FC277191D56EFFB26748F9DF18EECF5263CD0"
	"ED2C10B5745322E1CD00C78D4945317AEF62F47A273087B84088CCB66CE9CAAE305C61"
	"FA8CC696ABDC8C4737B787BF6BE6576AE4077BD63D8A57354B67E452BA60FA0071E413"
	"1684E50AEC3CBF0557906935DCB78A7E86443E1F87971762D1B96471DB81AA61FFDC65"
	"938278A9F84AD5F54825CA2B69051C0F8CE3CDE4C57710F052840A9D9F2E5E88EB8AAB"
	"3B84D550F804BB1082FD58CDB974824FB79BF8E77351A003E9A84AF05A0EC31D873FD9"
	"43BF7F39A1BC920EDDE6D39B0342AF3C694F356AB7FB64167CDBD1D2C0F7A854B02858"
	"6432BC8C4962848E536F7F7EE807F6832E8FE0DD720ED0D727417A539061D35515ED41"
	"6D49499A4513129F4F8646546BF1EE6220D28A1704ED560B36F4663763E2844C3EA08E"
	"253706F041429A5A663395A9716F56C832A6A7AB1ED37BB747985A42830AB404FC84DE"
	"2CF8788363977B939E49AB9A7F55EBE396DF8779E8B2FB8C9C78AB8D2A6F3B09ECBC5C"
	"45F7EF5188E5F132798FA67945C3FC4128EF548EDD0F8F68E4388A28EBB1EC7D549F6F"
	"2570D48A37DA087CD71D74FB340A3C45312EBE9DA06F02B0FE7C1277D764F5A269C036"
	"F571764FC832AA194B2DE7D3CFFA277051E5F78D51EFB5417959FCB64EE08DC353EE10"
	"BFF5D6D3990DB8C5DC9F7B096C7A773AC1EBB775AFB29A86A060873DC93DC9C1CB0819"
	"45FEA74A0A0AC7E195116323F781DC41821CE6A209E5EE2045BC7C1A7083580F39D463"
	"1654F20E6A0D4FE3368453CD72743607CC5177B49163512F558E87D222BC6272A46B52"
	"B7A5B7FA3D1F69D565F25CD35A8EEAFDB7EC7C3C9E8C4F55E8647CBD067FB641C45FFB"
	"89B3FBBDCB48F14758305C6451F0C380C35EF4C15602C9DBB527C898801A319BA49632"
	"432977F19AC45937C91F27442291CE182C1D6C423C1B118FBAB1C32AD9021445EEB083"
	"B893F0A826F4D13ABCB4E58FF3E80F0E7D0479D698B96B887F42B609DC85B73EC0AB67"
	"E9708E370DCF7519FF7A5BE4F7145D9D40217E1FC8EE024FEC8C8738E8943B4F11D73E"
	"9CEC3C80A07736E272322AA92B4331E6A69122CD1F889683DDD8526724D7A4CF075CE4"
	"E70DA7E2A4D169A89C5E95E72F8C85F227C147F67953B1DDE5EACF6C97E0CEBE3C9F8D"
	"13AB731BD96F7CE9BD0FB32D3273BAD1DAE4B3F02AF9B1569EF67066201FFAB64FEBCB"
	"8DF50B49BE1149BEDC44A92040DA92DBC996A988DA7D76B61071A21736D29FC6BA493E"
	"5EEB1FC93AC67E43CAF37E33B1C15B6911788DE06E4A7C3649946CC982B91A6214E0B5"
	"CF962CE9CF4C8A10012512FCF6D824C9962450D42FF0C3AA7DF948820F7F9AC68B8BC1"
	"42792C0D007BD4B8796E2F267F36DAAA792A31637B216A7FB2462DF2561B0091FBF87A"
	"9186B4E35F402F56B2A5A105F833D32AD1DF3DDAEEB75930A8592B92B520C0FF4AA336"
	"8D121A2A35CE2749FDE98A249544F7B14B10A582DFB2DBEA2B1CA512BA334DA5C26661"
	"B0205B05F769DA55E96C2E4474BE9CC626680ED0AF74AAFA2931FD6CABC76DFB5306EB"
	"4F756DFB53C915FDA97D1AF5A7F557E94F8D5C737F0ADF86DC7A1FFB13CEF2B4EA4F73"
	"2E507FAA6BD39F3E6BE94F9CDA9F02A8F4AB1AB03F353CD4AA3F7507B5C97FAFA53F25"
	"537F1A616AD39FDECF66FD697D07E801032EEF4F35087AE15945B1FF7F8B7CC846382A"
	"0064434BED7D7D5CD4C7B9EFB3EC2E2CAFBB2218AE9A6455D6600C6603F8FE1216175D"
	"1210222824B1C2CA2E42BAEC6E975DC59CB4C5A207C806EBB5699BF6A60615154F7302"
	"F5E6AA352F5DD40F2244A5495A6C9A1369EA6931A429C9F156939AEC799E99F92DBB80"
	"94CFFDDC3FEE3D9FA0B3DFF9CD3C33F3FC9E799F797E33BC3ECDC510FB448867E359C1"
	"1C3A102898291835D398309CCFA686BA0E51212ACAA6CDD4ED7E4331BF0BA3F87E191B"
	"B2299AC43511BD834B9358FD59B4998AAE669CFAA392EA4FC778F5E7C85C567F92C6A9"
	"3F87E632368D236CEE9CC3CA5A6BA0FEA844FDE9C0FAA3F22A7FF10D8909517F54DE6C"
	"08AE3F1DACFE50E154B162750B82EBCFB2B9C1F547F80966A6B1AADBAC0A94CB9008A4"
	"F3F074AC4404EA4FD2D8FAA31F5D7F0EEBD83B658EAD3FAA31F5275330FADF7552FDD1"
	"8FAE3F76DDB87C86D69FC774BCFE748BFA03A2FEF878FDE90BAD3F851B3662F5D9F9B1"
	"89517D68A2B342874F2B64E2564A43FD2DAD47E54F4CD0D1FCDD9FA8601C5CF1FAB802"
	"7F53AE516F685E2DA3A15233DAFD89BF4F966E29C7797116DD733A3B307E58E04FCC9D"
	"CD9AFDD4C56CFCC00E22ED620B88EFA8C5DD51C48861D3E66FD0DD94AF273B195BDD54"
	"AF6A699560275D42EAA73A5027AA592653FE36ACC86D8A5DFB246D29693D11595EA3AA"
	"764895E5DDA56A64B74475A6FB8D5EE74CA3B7526BF4D6261BBD254979F24FF3E4D7F3"
	"E49F1BFCBDDEABB5E57C3FC6D0AC9891E37DEB27741F656E79DF5AAFF1879027EFCC9B"
	"7F8EFBAB4F4CC95A9620F3449BFC9DBBDEF60C7BCF0F2967F8EAAFD072E4D41DE1D9CD"
	"4FF8871486E6276486E5BFFFCEF1A1D8D5EA9331C506EF8A3DBBFD1E52944B5824AD27"
	"F3E1FEFB716C5BD49FF8F3593C9732C378EEB1D7F3F2B7E6B747922842E433EABC1D6A"
	"0381B7811026D6DE303F3F65F75E9976BFED89C96D3E5C800FAFD5B13B9A7C7418F41B"
	"26C9219BCFAA714695D794916C6C5A8CED6776F33ABD24E36CEF2738DE992DE6593FA4"
	"5AF72B9A6805CDB0368BC17D6086C506540766B3D992A1C2B8F4199C622D35956F7891"
	"1166B7844CAD18B19B1327ECFC760B9B56459FA2695CC5EEEC13EEFC5C395BAE8D13ED"
	"F56FA4C9D412C1D4EE6FF1C9D40B0B69B37870672C9B490999A2E4482A41EAAD627D36"
	"FB9A4723D667B3FFE451E2F47BA8577D32FB362D58E8F39A62922BE8C38FDDA4E97B9E"
	"0EBC2185B1D65FB25560FA54FD0A2D027F3B015B05BA7ED4BBBB515C27CC1B86B89CE6"
	"0419F642342D951A06F69ECFCDA27AF433DA35676DC316FC0DF36C322E5DCCD2C5B174"
	"4F069B95BCC657E05ECC60573875E27B1D8B016037655DA711248650EFA60F90914DB9"
	"7A572917417606FBE2D147FB07487EFDC657D457509D5CBA98C6E93CEE52112906B89D"
	"CE6446DF15B2D9C2F57318E297349FC4B7F4A4F2608B79B0949160FFCA834DA36094E5"
	"D79BBF62E957A707D2FF0247A3D7DDE83C721F40269DDF8D43793A3FFE49BE51B7845D"
	"AD45D7EC9CA66DADF40BECAC40714EAF9656108F17032CDD945CE0295F49ADD3F64DE4"
	"CB83999AEF7EF771C6DA5F68E63F1209AD9C2B46C6C8C55AD69B5516539F679CF1B9A9"
	"49D94A019A57CBEB076E3729F38BD9624826363DCDCA7F7E9CAD64D6B322AEFC981DB7"
	"B56491078700CAEDE9CCABEC715A9573E1C350027DD7CC5D1F61AEB9E9C4F39AC749B9"
	"EBC646801890A21E7BFF1FE9B7E8D9FCF81E69AB417DD290A93E9993D539A08AEE94EE"
	"F6A3BFECF4B751AE91866603E96E6DBB0BDB670D6DCF5ED0A2D34BF5B794DBA7A1E518"
	"9D8B119BAD6EEF33CAFB4CF59D61433D06EF196C03DC725353D47F04F1801319F5C929"
	"F567FAEABF88DC3EB5FE0BBF3B6E35ADCC601863B3226BE84383D717CC7276FA858AFA"
	"A5A9D9D84DA89F3F9B537E36B739C110F4FD8F417D324AF096C078D3226B82B3C420C6"
	"BA8DF2EE1CBAF7E912E32AB7293E7BF7EFDD72C34DEC7E3A8312549F94D1E15FB3F0A5"
	"C3687F9BBEE5744FAB589E15E6D6A090E87AE73024F0FC39DD8783A3CEB3D8ACB9334C"
	"F37B02F7FDAA4FC44C519F08CBF1771B9775BBA7AC303F93B4E2E9EF2618EA2E68D181"
	"DAF133D414F6637836A1189D3F74E0702E29893025703AFCAFFE630D46C874437E4D2B"
	"7BCDCF2467EEC21ABF8715345BB2CA547FFE96A93995D6E5F69AFC67D56F76B3A25AFF"
	"B9CE1D6D688CCAF19FB9BE9EB6EBDF941BBDF92A76D99FFF2C2D8712D1AD347754FDAD"
	"0CB7B2FED6124F5CB3A90FC9D05B78967836EFBEE0B9DF7093742D86DDCA6653F7D003"
	"7C0874B37318EBBEFB9EFA4E058AF09D417CA91B439ACE3F84857CAF5A7F5D91E3ED44"
	"164CEF0CD60FA8D527142986C62C3F46FAEFD7E922D9FACFC33C0F9EBA886F6EB8F987"
	"CE8FE4CD597A436398FAC419DF87616167C27CC6FBBB0D759D7ACABAECC647FCD7E9D6"
	"74C3CECFA1E7A7CB5D2AC36B8443CB7978D6EFF058308BE7FE923E5BD86BF4FE2EFDED"
	"E69826F90564F2E6A7C8E45F42F8A3F53C62CF70F33F704A2818196048DCC4EC33DCFC"
	"A3FC82D1FB9E717EA7A173486EA8F3E9B3F105B0F478CEAA4FC831237637B2D52FCC88"
	"DCF9BFA5625F7F4E532AEDD08ECE4FCA4E95949D17282FF59497CFB3BCCC48E659B9B0"
	"E24149DF7B243F53283F632B0C4D91395806AF174A395A2CE52827BA95E6D11BBC3DF8"
	"4CAC740ED2ADA41840A17E53A167141883E1363E3D4496AFAE47D3223CE67389E1E699"
	"913C4E11797C86E5F1F4A0FCA4DC3EC3739B7D1F40F97B863812198CC9B0883187FF78"
	"FD15A61653EE99964DBA3FB4485191DD3485F1FF0396915F8464645648467EC8333295"
	"65E4C87DDA23F979E60EF9C9D8996C865618EA7D7AE4CAF01565A94F64E96E96A519C9"
	"E93E7C19BABA5C252E9919B92F025F701ADD3FF5188D8859A3EF7D07C7ABD3A9C39ECA"
	"D66B7AB12DA353C6E6857CAFF8C526F5C9C7C2D85E226B4BDEF60CD11ABD82BE70C490"
	"182C8707BB8FB53FF55F2C18973ED2B4FCAC5B51616CC274CF8E9C43CECE2BC7111A7D"
	"3052FF7141B6F7F31CEF15A3F7335A60BFE09967C2462F19E38E634B4CFDD3D8347128"
	"9E0EC9258EFFFED92BA69BBFCE6DDE8173C83D0500D8347FB739019A8D69AAE59DAED5"
	"B95EE52E522D6BCE8D52E15CEAD60FF8A539B712C5204DC7BF1E1FE0F7C8E1A8BC4959"
	"54401DCDA544EA9D5614301514F56E76713A4A3BD5AB7C8BAD7EC5A6A25793224E7D52"
	"F9AB07D8917A718AFAAE706F97A46D49F5A97EE547F9B4C83D8BCEDF435B97226EB6BF"
	"8BFF8EA6A4CF7200AB959CFAC6329EC6857C298D42290DF509650EDA1B8D71E1F55D11"
	"A19148EBD57474A98916E233FD89AFDC85F1A5EECDA7F75E3EA8DEF5121B0FBE40AE83"
	"4DCADA7C7612A87A175D847D8A3651E8ACEF667EE789491E6BCAA764C563B37261BE34"
	"149136E269F8C03A6E7605201BB0B38185F7E279E5547A23A665A41C5C47A97EC17851"
	"305EB01ADCD59478631D79275E40684AEC5FC7B6FDDF367A535F2577EF4A72CFA6BB54"
	"BB14AB4864679AF8FDEDB9CDB169F3D968E65E8BDF6FF05FA6D34CA3B0039C43DFD30E"
	"45609736879A93FADB5AF573B5321EC9ECFA9525EBD857CC156C62797BB6478DF16EF2"
	"77191B93575DFF9D8C8B62F751A6C8F817F5AEB3E8B2F34BD2297427EDFC92140ADD9A"
	"9D5F9236A15BB5F34B5225F4505F1A29981ACA34A84FBC4B1395B4698CFBE875ECC4C1"
	"C13C7AEBB8756CD43E134B9327E6BCB2378FEBB50F459FDFC542CBA454F3D816E32B79"
	"AC34D0F9BADE4BA403733F4D2FCE99E497079FBBE5F7CB87AFCFE78751EEC9A39C8959"
	"452BC36294481FDD27FE346FDCCC21F66AA6510A95796CF8BDD2CA94FC52B310DCCB91"
	"83539BE936239ABAF2F1EB2FE7B1941B15ABFC5D58044ECFA346F03670C6D4B97DC4D2"
	"E774AB59EA7C1613D7104006E90389A6C43FE572E93BB8A851EC33B6E7E7949FA323EF"
	"E099FDFCC8BBA2FDE2C83B24D20FADC75FF3502EFE6E195A83BFEEA14CFCB50F2DC3DF"
	"6D4319F85B31B4007F5D4329F86B1D9AEDBD840CE6E0500359B1DF24E90C69D0673326"
	"57772E937217CB0E17336D4253B9F9B399CE308BFD3845D4EF535FD2E8DF4293275E87"
	"90673A32373350F6426ADACB3F03388EE6149A37D19C43D383A60FCD6FD1BC8FE643BA"
	"849C7F2D475FEF29C323823FAE8B54DD61FCB48126A9BE2FD92435931A83C4FE47F1F7"
	"4CFD807C79E7B7A3E7FCFA6F6714EA5D76256B20EA1EE5BB094BE47C132945CE76EDD5"
	"BB5FE6AFE94BE1EDDDA904560D1F7B54DC4B9AEE6F5A4961AF4FE3F10CEC117A272AAA"
	"A71F6A98632F73CCA513CC950F3F4A1EBFD4306DDE9FAE633BFB86E6C764A4F6711729"
	"2F2EFAC2EF6F52AA18D94FA7900EE0DD7F7F845F27D49CF8105BD4F461837213DD067B"
	"FE37D3813B8B76F995A6BBDF413C7D832DF1D1F9532BC3689CB0EB19F6CDE686619AE7"
	"DD277558B4AAA19113E5075369B6F04609ED4B7BE2FEA6FC0546A26287C9BB95EC8CFA"
	"749C64E50D6773E57ABDB179AD8CF23E9369DAB34524F7147A197683B07AD76DB6069A"
	"1F26AEB4EBF6277AE8C4B62B586535266F3325C3E4FA27F655E2D24758655E456B382E"
	"43C7CAD3346D1D5CABE0FBFB05ECFB51C3A9756C6DECD2F9ECD3B151B151745B983336"
	"4AE8EFDF1BCF578F4AFC89B7E3F9D9246574F2C7667628DA13EC281E0B59B7B003404A"
	"D8816D54BDB188E84929DCC80FBE529ECE6193DFAD73A5E329AA6F50C996B8C821ED32"
	"1F4B94B66ADA286702AFE39991433BDF73D42CBB337248AE15B49A7A0BFD97DF4D337E"
	"3ABC5E2FE75B635A862F27D3A9C3EEFB441A89D775943961FC5DC5DB194692519F98E2"
	"BDFB53135F8852510CCD87CBD8C2CD5F77E1006B3A5BB75D3860621F2EDDCA6D5E99B7"
	"D9EFAFFB42E7BEDB7BD67FB631412FB1EBEF3435311B6BA9F1B169E54113654623FBC6"
	"9179D52D9DED4940AFF34A87493A6A5F78CC111E4F8DF65861F45EF6C4A25F36A92E0A"
	"C7FB3D53B3BDB9C92AE4493592B2FA4D591E0D9A856BFD6081F0A8BFA55337B0B3C1D9"
	"B9AF11CE56D6AE3514B452BB76D9FF07560B5E4B666A1326F9A5C1EECFB095BA729DD6"
	"3C9897F69E80D7BF72AF1F72755DE6FB3406CCE91CD4A2373239E8651443DB98DFC691"
	"486BB8FB66E6BE60C4FD49EEBE26FD6D16E1A0F76F54FD16DAD652011F7A901DCB3774"
	"8DC4DDA5D0EB02F9F698DFE4BFB0EB6D4FA478C9A198C684741CB3737F6FA216C33767"
	"7DBCFC8AEB512C3DFB9FA50AF42CBFE79BE9C43E1FC3553996513BF5ECC8F8EA06539B"
	"B2C78C9444CCFF3534DABAB48695172C17BBBFC00690AE525E484AC0C41A2B6EC85FAC"
	"91ADA5FE160B5B97225DAA4E7D71ECD8762ACD3F53B392D8A47C9EA5B386A5135BCC1E"
	"9AD47C059195432F2FC9B417A995F3BD4856D2BDBC89A13D4BD6AC7A45B3BAF31C35C7"
	"DF38FBE94100ED218097104FA3F91D9A487CA6C324EE438488085904FE85458CFF2757"
	"442823C2FDBA9974BD83EE1EF66B62BF8FB0DF22F6FB491C7CFDF77FE56FC9BB1C8D02"
	"0B046E16F894C05D025B049E12D827F01381B705AA7EC3F11E811902D70BB40B7C4EE0"
	"8B025F11D825F003813704C26F3968046A05EA05AE115822B052E0D302F708DC2FB043"
	"A04FE0FB023F13A8EAE7982070AEC0450273056E126813F88CC03D025B04BE22B047E0"
	"15818302FF26507185E36C819902370B7C4AE0D3029F15B85FE07181DD02FF2450F13B"
	"11AFC04C814F0874096C1478446097C03F0984F7384C173857E032818F082C13E816D8"
	"28F04581AD025F16E813F8B6C06B026F0854FD5E942B81F70BCC106812F88440BBC0EF"
	"09DC2BF0A0C05705BE257050E05702A7BDCF314DA049E0468195029F16B847E07E81AF"
	"0AEC11F881C08F04C2BF719829304D60A6C0028165029D02BF2770FFBF85D6E7625795"
	"DBBADA61AF71D8ACF91EB7D3E35E5D697699CBDD5657F13FF0378CEF6F70BB5D555B3C"
	"6EEB1DE22FBE833B8B0E0AADEED51E97CB6A770BCF350EBB3BBB96B97387E22ABBC5B1"
	"3DC75EE190E8B97B91B53628ED11F7C27297D56ACFF25454585D85554F73B6EEE04FB1"
	"626221FEC84E8DC355E0A8A9725739EC92DC3094C3661B278AE27FE06F10ED9AD56C99"
	"40EC13F81BC6F70F15FB58FFE23BB88FE527C73E423EC6DD30D6BD78D4B3417A5E5365"
	"B34AF25AFB0FE47D677FD14E5705A439AEBCEEEC6F18DF7F94BC56DB1C355693D96E11"
	"2CAF7659CD81021ACC92781FEE4F6F583CEA59A4872172ABB6B8CCAE1DEC39BBB6CA5D"
	"E072945B6B6AD873A96D3BD5005E0F8204155C2F8A473D1B42CA659EC38281721D668B"
	"4827BBB678D4B381C9959235582C2E96343E67DBB755B91CF66AAC631BCDAE2AF3164A"
	"697C7783782FC17931843E1B42D26382087A668268818AB9FB7491C931C9B1C951C91D"
	"F00B484E8E4E4ED2697431BA04DD0ADDE939AFCD01DDEB73DE98335397ACCBD03DA00B"
	"D359665B67FBE465B30FC149EC80C2C2654A79842A262A2E32365A0D99DA324D81DE59"
	"E76B19D8DBD7313CC69FAB68B1FF5057C781FEA1C5E7F321928B9FFD07BF9F03FDF3B3"
	"D362442E94A269404387D2F4737A722AC59F52742F45F752742FF573B206746F404B03"
	"BA37A07B839F076D47F776746FC78776746FF7F3E8484FBC1FDDFBD1BD1F1DFA257E48"
	"7D1EDDFDF409423FE38F25CBFE35A06947D38FC6CF59C19F52E4A714F929457E4A911F"
	"C61EF2538AFC94223FA5C84F29F2C358467E4A919F52E4A714F929457ED86B203FA5C8"
	"4F29F2538AFC94223FF46AA5C84F29F2538AFC94223FA5C80F7B5DC60DFD6B47D38FC6"
	"CF4580FC3420030D98580346DC809130B1A067035A1A909F06E4A701F961A2427E1A90"
	"9F06E4A701F969407E98F8909F06E4A701F969407E1A901F126903F2D380FC34203F0D"
	"C84F03F2C3C4CC2443DCD0BF7E347E2E7AE4A71DF969477EDA919F76E4876507F2D38E"
	"FCB42313ED98603B46CEB20803B523413B3EB4233FEDC80FCB36E4A71DF969477EDA91"
	"9F76E487B2B21DF969477EDA919F76E4A71DF961D9CB72A98171D2CFFEF97996233FFD"
	"C84F3FF2D38FFCF4233FAC18203FFDC84F3FF2D38FFCF4233F57919FABC8CF55E4E72A"
	"F2731519B98A895EC504AE62645731E055E4E72AF27315F9B98AFC5C457EAE223F5791"
	"9FABC8CFD540F9A61243B94492E9E7E59D8A1AF2E3477EFCC88F1FF9F1233FACF8213F"
	"7EE4C78FFCF8911F3FF2C38A24F2E3477EFCC88F1FF9F1233FAC98223F7EE4C78FFCF8"
	"911F7FBF549FD01D23F463603F1252FD52A954101F1F0F3367CE84B973E7825EAF8765"
	"CB9681D1688475EBD6414949096CD9B2056C361B6CDBB68DD5D7679F7D169E7FFE79D8"
	"BF7F3FB4B5B5C1F1E3C7E1F5D75F87AEAE2EE8EBEB83F7DE7B0FAE5DBB069F7CF209AB"
	"BD31380DBE9F5645D0D8D13C8FE6349A6B686832BA0A8D130D2D46BF8F669A02A008CD"
	"8FD0BC8F66AE92D6BD702C8C461B0EF01D340374F26604CE63D02C50017CD3EAB25B6D"
	"E9690B2C363A7E14CCCEAAD4EA9AD4ED55F6D47287CB9ACAF67AB0594F152D4A396FB4"
	"A54770F216D45D89EDA9A526557AB68EB4C19CD4C6DB521B36AB56173A55B22E2A1572"
	"B6DA1DAE2AD27F96C61B66BB3DF8F99B554E67D0B3C9E1F8263D6EB0570A1BFF33C03A"
	"28841C580DF9682B05236403CEEE618E2EAD84FFE774737425F40FB45A5D8D0EFB1106"
	"5A5D8D147F4EB579AB555B69AED1DA1DDA7545DA4A2B313C2BD4DD985F18F0107F2C9A"
	"7247B5D366755B2D63F9C98612B40B3A5D21302571EA5FCD285C8BD6EDD096B31E495B"
	"63373B6B2A1D6E6D8ACE330FE72B34D763E79104C61FA2D3621C518FBBCE5C6D2D0EE4"
	"07D480197FAB600158C00694A9DAA0F71BCDD75AD8804F44935D5B6EF3588877F63E85"
	"9C81D07E7719C6A44DA91279360F601C7F313F0CEA3FB5BAD981F483FB59742F1CC71D"
	"FBFB9110A1E3021EA298BD07FFABE0F263BCDAADDB814B11C05A5B55E316C5C3E1B406"
	"C6BB6E97C75E6E7607C6731EFB37ED8EED76703DB81DF84806E78298B5AC2E94F361CE"
	"F6D455E4CDC747F9EBF23714250BF9E5A3F48A20798C5C517E965A1DB145407232AC2B"
	"CCC1B0B03A1721377F7D203FB87BE9C66CEEB41A72452CB968026463F26D239628F2D5"
	"9504C695566DB599D5156D9050B4A95A4F0DB959AC15668FCDADAD71B3B797D22DA4C7"
	"521ECB723474F87006E203225DFEBC3CC0870BB6C21658C6EC11CCFF49D04340BC30E3"
	"499D65B9CEA22B5F2F857F121E86459086713C04E501BA029B7947A1C363B78892BB1D"
	"4BAC1DAAF1DF48B965EB1CDA3541393C7ADCB68C0ACA035ADD9C40F90A1DE7917F21F9"
	"17DE498E062860E5DF64353B0D369BA35C08EF0121362CE85BABEC669BB602CB4DD0C4"
	"89EA940DCB8976CB0EB7F501ADCB5AEDD846C5CD6AB7D468B757B92BB566AD44E77661"
	"94A308B573B554DCC8A69B7D7F0D60B6B8DC4121B5DA9198741E6D20A99AA0B478FCC1"
	"298EC791C46FC04F171C87561B9C32A634C26CCD9DB98551E1CCDAC9BC23E763845237"
	"410A77A283C0FB54D9A5E656BBA1684DEA126D8DF55B1EABBD1C1918956A0D6B7797D1"
	"DBE966AFA8193B3F91BCB094E4D89FB2B27CC60AE3469BD41E16B8AAAAB10DD2F28E8E"
	"3CCDE595544CB0A1616939832645F85764755563B9919A20ECAFA8EB1B798175EEC73C"
	"56D70E9A18BAAACD946051A5D4EEB0F51B708B7A105A1F4697DF626C05A80C07FA4B37"
	"6B9AB5D53BB455D54E07E69058AF31DA6C3976CC33149076A556E7BC437CD4EAAC0DAE"
	"77D8335554D92D5ABB1B4708344A98155A2FD1DF4CF586FA2EECF3DD1EAC2BD5985928"
	"2B5165793B6E7151536EB4D9E0CEE179B8C9C6CFEBBBC36343E6B0BF645CEA3CA95BAA"
	"DC58E7A48E79839DE67F140BC93FE0CF7BB759948E3402D17AEC351E27890C53ADC6DC"
	"ADB25BB529FA5A5DC93CC6CFA20C11B536658BB9860B711EBAA7A78D71FFD6BC3BC55B"
	"E3D952B3A3C66DAD9684A3D51AEC3B56176C181D5E8CB360ED861C218F407C76873D95"
	"2F1ED58C943AFD4369E9190B172D5EB2D490B5DA98BD86DAF791511D6FEF1765F0678F"
	"2E83B5F79B6AF9B0A836303A025861AD76BA77AC8215768FCDB60A685CCBFE4A754B18"
	"8D0042E6A4F300C44605FA136D0A17D33CEDB687162C598A42DF4A9DE03CDE5AA00074"
	"96545D1A33685D86400623D0613F9A0D79589275B009473076ACB555D85F38D0B6004B"
	"BF03447B47725BA61D536E2D60C57EC98354A55081216DC0BBF859A46BE2C69ECA120E"
	"1A0D8E9FD12475A37B9402A2D05D39CA5D46EE192A884A0B2FA032943905C718B47149"
	"619461A0CC080F7193458641649AD249B405F1581EA70274102D707B4602C08B52D877"
	"D5ECB930116017B9C52B20FE5A1CA8CE6942695561A0724F09894F668E00B3251E1ECF"
	"980A71B20408A3EFA0D5E1A0B6A8408D3CA9D3A29D32850C1407D13D3C0CC2D3C2F4B3"
	"4871DB9D00993371BE7037C0CC0B9CAF90679656288D6C6614CCB4DC05338BA6C1CC8C"
	"4498F959E2C0D4BE293E59AC026233E221F6B370A72C5A01D1FB144EB93EAC80C9601F"
	"22A59FC5D3D0E0A0E8349A97459A64FF1D9AE7E999E2B1A84155A409759FA28029248F"
	"8CA490F0B2A9E1305536056286A3FA54BE7027CBD3733FC077DB071DF70184A500DC16"
	"E9843C6B14A0413AD5283A9926023419CF8346B60722FB22CAC203B28C4459A23CD747"
	"B3FCDC3B1FE02534B61E1E37D917E2C0A8A847925BF1283705E66501288A36868495C5"
	"282046F61828CB147A9637EB296F68D11B2019CDCB1496D23F170551C883B24815E227"
	"8B545019EB933BC3F4B2A42848C2729054340592323490743CA12FDEA771CAA647C174"
	"772C4CB7C4C0F4A268989E81CFAE693E96275B308E041524605949288A80042C2F0969"
	"18260111D34BC0774E588FCFBC2CEB791D08A73A80348A803FF15CF630C00FD194F40A"
	"1964CC0C719345844184EC6E21CF8840D964E50ECBC653685EA4B0FA70D0E3DCF01ECB"
	"0318C7FC103F599C1CCB780A2BE314CE990D70174EE612DEE2CF645F4C933BF14C76DA"
	"CAFDB857AA67D163DDCEC5848623B76B512171CB6294107346E9549451A916F540F633"
	"881D8E1EC072E2937C64B3A26016D6C359FBA60F270D4CEB4BF0C53BA794690AB88CE3"
	"51C65350661A48789BCB2C13DBE746342F50BA592AC8BAA1922DBC16299BEE8E92A98A"
	"A6C882FD657785C35DB26899A62FCE175316ADE77146619C41F94465E8B85416B00C14"
	"A9B12CC441D23E511658184C1FDD13D03DE138BAA5AA20D51D07DAA25898911103E1FB"
	"C2CA6433A261866505CC285A8E6ECB60866C11F018B85CE97E9C65689EBBC89FC95E8A"
	"A6563C93FD101ACB45A93E4C1DEB762E21341CB915C587C4CDDB95446A57CA28DEE1DD"
	"00F7FF3380E2124F87EC05688645BA64DF87E67D293E6C93C6B8154D0D0D2778098E9B"
	"A56B61E9B27CEA680038D888EDF025417F6D79889BECA56878E9C632F8F1BB59304DB6"
	"02464A84909717E03334EE40F8A5216E3CFC120C9F89E19785849775C541D70D13BC79"
	"AD00DADFCD8756F73A8895E540B80F290A30AF9F8A86A7D07FBA2C13424BA368EF5DBC"
	"4D29FB21C0F7D1DCBA24CA78912CC44D364D01D3E2597965F4FA1F033C8926E532D22B"
	"C2406109759325CA21316C8A53A3A7770C077817DBA67391D8E0C543CB4F003EFA29C0"
	"3397F9FB873CC787433CD2C622AD6A142D6B1BF6450F470E4438C3CB94C8471CC00D33"
	"C0356CA8DEC539E239648226A9960A14FC5668D90F308026A34FA433EA99EC6FBD847D"
	"977826FBCA03002A7A5EAF82F5187712C6ABC178551867883FCBA72DA17150BF81E9AB"
	"46A52DBB570EF7CA2A418332AFEC1BD97B7C85F6223BBED633F85ACFE06B3D83FFEA7A"
	"06254A5B8DDB555EEDAC2A86F7C368D588EFC5BFC7ECEBAD6C0D09DE090BAC27C11F65"
	"77DAAB7C5871E7DDF99563FCF81EF211D9DA71DDE72926DAC95F1FB22FDCCFB8A39D5D"
	"9487723CCD069F7CBC7DF742C544DA08FF34C15EF329D944FBE2E9CAD0DDE24715A377"
	"8797CB73ADE66DD6D5B4AE536EB6155AC552DC67906D775B5D63DC534362941401CC2C"
	"EF6C563BDABF19861C15BA2DD256F97D8AF56EDB135697238FAF2D68E939CFB1CD2A9E"
	"55CA6273957B8D035FD6BE1565B2859689E02BC546BE2451E072D06A111610A57061CB"
	"3BB477337AE77A06B9E06B796C223F0C383A927387F4B475D65A64F51B81E73555AE1A"
	"E25D45A172CD35EE6C97CBE102784348BBC8E1B0555A6DCEF4B442B17100709E499B6B"
	"9F489B0516A892E7796CEEAAAC1D14A8B8CA6225CD02D8CCCBB373070A25533E7A177E"
	"9A62BDB5C6536D95D6A63EA598997280A475407BE975945F41BCAD9287EE9E1BE4A1BB"
	"EB0FCB47EFEE1F0F2A1F3CC7EF95056B1A54C982F4100C760BF9493C5506FBC1AB925C"
	"846F638846C3F743F41D1E904DA44D912A9B481763816C224D8EB3F211BD9193F2509D"
	"924E79A8CEC929F958DD94D7E463F5585E978FA7F3F2867C220D9A37E513E9DFFC4A3E"
	"91F64E8A6222DD9F22C59D34968A15E3EB382D508EA72BF5A07222CD2BBD7262BDAD87"
	"9413EB7D59899771DBDE0F6577D214290EB4F006F833A3C2C2B61A0BA528528FCBF3CC"
	"CE8D55D6EDF9152C839F0B2A53797C0306537E23A8447329609F162CB32A37CBFDD783"
	"E824B7459065B5E21CCCA728B491E53485A3E687182CAAAA26E59DD6311A2C6D63745C"
	"E62943B56E64F29C1A63D6EA426C4B2DD40C90C6D289A0F485FC70749BA11CD1E7C957"
	"4A3A3EF78C6EB9308D8FC1E871DAAA68795634A53D41AD8F540BBBC6B648F05BD60B19"
	"AD286CC70EF877C5067B75885C2F2BA4357449F26F83D14AEBFDA39BFB0FC15855C364"
	"C3E84453B0DA6CB3D540EF186EB02984B342562142C5B7F9282CC78E719B6DD8A38D4E"
	"65FAC8DB07EDBAFE86BDC56AB1EBF8B9D41FB0AE9FE42B0BE90FC8A58BD53A2105D1BB"
	"DC96C251538644C7047FEBD17BA42D5BC973253428F847F54194C69352AB8E1C6E673D"
	"1D5B743656B990C0418DF0EE11D762C7F64519415EA0554ADD439123D067C04DA9ED67"
	"DDFD97F81636ABB9C69A87F514538C64FD9303E545B204B89BFA4F6A22059B6E2AC314"
	"BAC051455D36C01C6CE19D5864822A61A19B16B8B1E8EE17EFCF22478E1ECD5EBF2E3B"
	"37783D9BFEEEEBEBDAC4E6081FF0AF37A28419C4319B06DD967CC0E78AF0098EDB6EE3"
	"986F0F9FE377D0478A7BF9FAC68B1F613D43538CB465682AD1B8D17C174D139A9FA039"
	"8CE6389AD73F00F64D5E18C841014A9C0D47800A2283D7D68DD9591BD61616AD07A3CD"
	"462544C2A21D4EABB457BE7EA3416C3319737321A746D43E517D44EEB2003CFBA9B35C"
	"940136C7D6529B759BD5463A165B4B9D6677E5D76AFCFFC77F32E0B7AA6987E165364F"
	"7F83A36A149D49B8AB47B99708F7A9A3DC9DC27DF4871A0F0877E528F73AE11E3149BE"
	"47FA1AB6A3793FED7E4B6644CB62840FED298EC30B38DEE94FA2D708FAB20727A697E4"
	"02825EFBADC9D10F9FE4A8774D4C2FC9F78AA0CFCC9C1CBD4FD06B0D937BDF0E41BF37"
	"7572F42D82BEEFC1C9D1EF95F8D74F4C2F95BF3A410F6993A3774AF1D74C8EBE4C7ADF"
	"1D13D34BE5B54092E7D313D3AB04BD4992CFD3932B0F4B047D4BDAE4E49922E887D326"
	"C77F92A01FC8981CBD4AD0772C9C9C3C074F08FA4513D34BF5FC8AA0EF5B34B9F84F09"
	"FACCC593A37F41D0EF9D247DADA01F9E247D89C4CF92C9D12F11F4CE2593937F8AA06F"
	"9964FC49821E964E8E5E25E8CB26493FFCBF44BB3249FA2B825EB36C72F43E415F3649"
	"FA3641DF3149FA46410FCB27475F29E80B26496F12F42D93A44F11F4C393A45709FACC"
	"1593AC8FAF8AF23F49FA6E41EF9B247D9BA01F9E24FD5E41AF5D39C9FA28E80B26495F"
	"26BDEF24E94D82BE6F92F47A89FF5593A3D7087AE724E987FFA790FF24E9FB04BDE6E1"
	"89E9BFFEFBFA6FA2BF609D1FC28C29D418705C8566F07CA8EE0FE1CFD16474737C0D0D"
	"DDA4E7437C241EE0FDEE50FD9F607D9E609D1FC227A663FDE8E6B8054D5937C73D680A"
	"D0BE97DC67009C43BB13F15D32681F98C1757728AD607D1DC25FA0515DE07819CDAD6E"
	"8EEFA2B9466111CFDD8BBC204D1FE2F1591807DA7D88B639388746BB13F117688AC81D"
	"313699DB83757182F575089BEE0378E602C71FA1B15DE0F82F68365D08D5C721FC641E"
	"F2738163D8FDC8DF058E6A34AF535A88DF9F8FD813AA7F13AC6743383B15F9EFE1B804"
	"8DBE87E32E34DA1E369E87BF2E40D9F6B2B90F143DC8ED38AF8173C28E637858A1E776"
	"1C9FC3CBC24EEB03B71EC2B6B827544787B01ECDDE1E8E3F4653D7C3C6AED095C6F3A5"
	"0FF15A1A971B8E51617D3A1D6D82F122BE9781E3B91E361685F68548DBC3C699D0B648"
	"D8112F2EE2F4383E84958B455E2F66E33950F472FC83B0E3988DC661CC4E684333B397"
	"8DB5E04561C77114FC0D4DDB5B6C8C041B97723B8E7FE084B0E3D8066296617C3D6CDC"
	"029B841DC724F02F68527AD97803BE10765207C7F1014B97B045D80987859D10FB6CCE"
	"DB0AD61F73FE115F4593D0CBFA5CF87805E77398DC567277EC2B21772577C77E109E5D"
	"C9F305FB38E81176ECBF60FA2ACE0FF64DF094B063BF437D094B8B10FB0966272C13F6"
	"607D25C2DFA331F6724CCFC43AD2CBE69B34876469116AB2B89D706596C897209D25C2"
	"C7B3B13CF472DC82C6D91BAABB14AC7F14AC9F4418BD16C78EBD1C67A0E9EEE5781F9A"
	"53BD1C779A30BF480E881BB76279A47C449CF22D2CC76FB13938A4B8B0ECBDC5E6D740"
	"37FE913D58BF8870D30E2CDB6F716C4253F9169B0FC27F7B9A97079CEB41AFB0E33C0E"
	"F2FE89DB0B109F7E06EB29DAEB10BFB313EB12D9111FF91ECA846810CFA319A6B0887F"
	"AF47995F0CD5250AD6070AD617223CBB1BE3B8C8B1174DE6458EEFA0D15FE4780D8DF6"
	"62A89E50B0AE4FB02E10A1B701E57991E30FD09CBAC8F17FA069BBC8F165342F5C0CD5"
	"0122BCFA2CA67589E39768349742F57C08E9AAE8B24B1C57A229B8C4D71A6F7F1FE57A"
	"89AF35FE7C1FC68DF60EC4E33FC02280761F229D1F486D45B08E0EE1DD3FC6F7BCC471"
	"3E9A772F85EAE510FEF5052C579739DE46A3403BFC04CBE34F78F90CD6B921CCDC8FE9"
	"5CE648876B155CE6F802E9B75C0ED5AB09D68709D697217CB015DBA8CB1C17A3B97299"
	"E35A34DD9739D22137A72E73FC119AE72EFFBFBD1A4877A024F1AF6D43DC699D503F8E"
	"7B241D4445E3EF4C190C848D8D7180AED9828D5018F85687B495B9AE720EFEAE817C46"
	"F786E2AF5F517C2A9652640047FE14303AFA556114A210DCE0625FCD6CC5D8B8C6730E"
	"3E55007D6A3E9DD1E82103CD528659F41E5004F7A0FB6AA4A16F6DACEC3B035A36AC44"
	"74831396C183F86FB4FEB5192C68AB455C00DBE0690CB780F955232DED574507E274B2"
	"B03BF00DCD2C7EA6AB82F61A16931665E6C07FFC33872C88C57012EF463435182BBD93"
	"1379A9622182BF51D0B234EC2C2E49BFFB7E5006C5B1118D8B712E857D08395D421D1F"
	"FE2D8008A4CD61EF4C7476E4CB16C4A994CE22F60514BD5724D2E7A2DF564649A93BF1"
	"DD88C3AD4C628029BBD0DF0ADB91C225785AC5E4912FE8AA443A128FF671D30BFECA43"
	"CF4A4101862749795026EE10798EFED66C01934128FD684904CBC1C84AF046C6F1D892"
	"83FD0AE957634971897260430CCE8F484587E2FFFB09C0008E17B1AAA95A342D292D99"
	"2D252DCE96C6968196C196E116CD81A403DA0399074C070A0E380FD41EA83BD072A0ED"
	"40C781BE03570E0C1C8083AA839A83FA834B0E661E2C3B5879D07970EFC1170EB61CF4"
	"1DEC3ED87770F8E0AD8370487B28E590FE50C1A192436587EA0E351EDA7BA8E3D0A943"
	"BE430387060F0D1FD2B426B56A5B335B4DAD05ADCED6DAD6BAD696D6B6D68ED6BED62B"
	"AD03AD7058755873587F78C9E1CCC365872B0F3B0FEF3DFCC2E196C3BEC3DD87FB0E0F"
	"1FBE75188E688FA41CD11F29385272A4EC48DD91C6237B8F741C3975C47764E0C8E091"
	"E1239AA34947B547338F9A8E161C751EAD3D5A77B4E568DBD18EA37D47AF1C1D380A6D"
	"AA364D9BBE6D495B665B595B659BB36D6FDB0B6D2D6DBEB6EEB6BEB6E1B65B6D704C7B"
	"2CE598FE58C1B1926365C7EA8E351EDB7BACE3D8A963BE63FF75E68DFF09"
	) Do >>ANSI64.DLL (Echo For b=1 To len^(%%b^) Step 2
	Echo WScript.StdOut.Write Chr^(CByte^("&H"^&Mid^(%%b,b,2^)^)^) : Next) & set /a IDX+=1&call :progress 51 19 !IDX! 850 20
	:e
	Cscript /b /e:vbs ANSI64.DLL > ANSI64.DL_
	if not errorlevel 0 goto e
	Expand -r ANSI64.DL_ >nul
	Del ANSI64.DL_ >nul 2>&1
	exit/b


:makeansi32
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [ANSI32.DLL]
	del /f /q /a ANSI32.DLL >nul 2>&1
	set /a IDX=0
	For %%b In (
	"4D534346000000006B620000000000002C000000000000000301010001000000000000"
	"00470000000200010000B600000000000000009D4EA8A22000414E534933322E646C6C"
	"00AC7EC78D60470080434BEDBD7F7C54D5B5287EE657328449CE00931820E018478C26"
	"606A82829368C010030D38334966507EAA30774C29503C47A33760D2335333390C857B"
	"B1CFB6D69A86B6DCDEB47A7B2D09D4924902F981160354A06A2BA8F59E61B0456D2101"
	"C9BCB5D63E33F901B5F7FBBEEFFDF33E0FDD39E7ECBDF6DE6BAFBDF65A6BEFBDF69EA5"
	"0FEFE4741CC7E921C4621CD7CEB17F25DC3FFE370021EDC60369DC6B137E7B53BBA6E2"
	"B73755F91E7FC2BA79CBA67FDAF2C8D7AD8F3DB271E326C1FAE87AEB1671A3F5F18DD6"
	"D2072BAD5FDFB46EFD9CD4D4149B5AC64F951D173F0C9EF9713C9CFBF4891F9FA1F7B3"
	"3FFE3E3CB7C796FCF8637AFEF38F3FA0E733EA732B3D5D8F3FE6C37C719C1C8B38AE42"
	"63E0A60FF4AC8CC79DE1B4374DD4A4705C2D7C6C6371E1C7E18F19C24EFC6A65EF5A8E"
	"33701A4A8F3FB97C0D230E259718081061134FF6D8FC2AC71D86E7853D1C9743911AAE"
	"44771DA25935DC66D37F83B8E3FF019E1F69FE7EF21C617DAD80CF2755846AB904DE89"
	"AA396EED9C2DEB1E111EE1B8B937A96DCF865037160EFABE640E03E31ACB9158109220"
	"BC740D5C78CE9627B63C86EF3AD666AA73CF75CADBB27EC32600FC452AA3019706CFBD"
	"D7C02DFC5FA0CCFFFBF7FFE35F41B8CBC8BD39F2AF39E7702B27A716C15FB72CD88C1E"
	"B9D8BCB3957338DDB15381B0685853105EDD6D3720D4930E0617B270CD1B8C3FE75C81"
	"7E31C5E988A59B204334C559C3C1BB11DE0361A14F4E4510470DE76CC13CB1743D24C8"
	"E9F8EE70B95BB0BCD8A966FC2CE8F74AF36EE27777CA438198C07BA55A2D271AD7B423"
	"F3AFEEF64A45B55CA8B0B6B25A289257DA32E5D91C16D4134D0A7D1FDBE39533A41EAD"
	"57BA6C178C5EE95E4EFC7334094A0C2E1B7654C6DE064C5229F6E8AA1572EF9AD5DDAB"
	"0AC22B02B135FC6E6815B55F3A6FC4769B43A536BDC31D4BCF82D2A53A9B9113EEAB04"
	"5A64C267A8C26672BA7B4B6D995861EC945C65CB7201A80511390D194D0E4AD550EA1A"
	"B97BC56AE990B15BAEB0599C2A1845507D5E192AF2429AD11B84B7E65AA0923758614B"
	"8252F52E87B221168B0170AF612D24E0BFEE37C7FC037C6BF42184F5ADFB7E2B07F59A"
	"EEC67AD3B1D76AA819D00FCAF3FFC471D22113F4E024A0A06D36FF7CB85C3AF399144E"
	"0E849F9D0A0D3471C2E44BA7E5BECE41BD749697CEF09D67F5133B136826FE55CBE7A5"
	"8F06A5F38ECA6AB7C7570248C5D22BB0E1A9F9A7A0A7FBF91DE9C950557129F424F4EF"
	"4A006836865B39718254CCC19313BF11382E7E7D9E638AE89BE798247CB5F9A34B981B"
	"DB2DCF2D476A9F19763863279BB13C165FC341032D2E87CF3AD8CA3963E9A5C43A988F"
	"C8E572C44E469E07F9D43C0AD849C08EC853102F0DE9F950075025709C0FB4C1136AE7"
	"03BF80177936D6781041119929722A61938E054967879DAED8DB72315537A3047B7EF1"
	"0846A5368BA346E37642FFA76303EB9F99C48993F9B62469305598250D1A859BA4C164"
	"218B6500F07C68D5092F90BA90139362D49FC0A931A29BB877A410DEDF0F5A66145920"
	"DFDB915F415C0D57A381C0F95024C7D28B10A32A5B8E7CC185FC868A0AFBBF90B8323D"
	"736782AC0CF73806C070F97C4795ED1EBEA30F79AE9CEF28B5DD9BDB55102BF106EB6C"
	"4BEC9D429A5C672BC9ADB3153D4031D415BAF0772F0DF11D15B622CC5C927BCC3EB0D5"
	"18AAD510841746AA090A2EC721330F6A438E2E2C388E9C5CE10D56D996416285233E48"
	"52A9AD4F4FE2E462A4BF6096D391372EBD33FDB8F481D6159D16E7157D8D269A4AA4D8"
	"AB1792A53357A088538CD5D42E60FDEC664C01D4288791788238AEBE760AD0F20CE874"
	"BEA33C83EFA843CC57DAEE42F497E9864279D3EC7FE1771C8074FBFBFC0E1CAD488812"
	"BBC2EFF83165AAB0E5CBE928B574FDBA7E90662E26D9E4C1408CF77F538BB20648B91F"
	"C98EEDCCC0362FC336035E0561687416BE667BEDC7F86FFF2B32DB4A9B453EE7853198"
	"4CE489F25E7BA76884815E51D08F520ADEF231CB2C6899D5515DE959E2C6820B9180F3"
	"62E98544D752DB5D8C3F410C599D00E4C22CF7E09FBB62E9F900C3B7C1ABD70E6D110C"
	"DE18BECB880662E72D5151EAE4773C01928549654F0D8EAABC9D44C71C788C489B48B1"
	"0E495162C9ED8366ECF894C32F409304FE02FE95232A6D1CA369E305925017F06D8E0C"
	"6FAEC3C2B7012DBD0BB11D19AC91200B911C2899A1194BE04F1621286F40AA55D96C18"
	"3F0BF25B207F469C1E5EDD3137A6DEC58811AFC382598B2011D3A0A125198C425E5DE7"
	"582231FA34AB6D768C69332B8C38C561C93D124C451244EE856E6E07BB09461E966055"
	"B65F8EC5888640D3C2727CCBA19C05FD8CDB6D884B092292E995013386D42C440AD081"
	"B459B915369774484F1D4D7C03255942A8431CCD6ABFE638E56320D5D26DD49BD86FB7"
	"5540B757D90A5581A7540F915A60E3075975998610561B2315A3E0E59A314AF81A70DC"
	"26621C2F1681154FC33F192A0AAC31F9D4984CFC6343E00A7C2B942B58062B744196C3"
	"C9040AB6280B258F8B3AC6C9108DB4A0840DF3FEEFAB4C72976E0047D49DE5F6017EC7"
	"B720727F9C90D029CAFDD08278E9D905E1C5543B22C9E89823333295636556EAD84BBF"
	"FFEFD28CF1FA789ADD34C86896903EC2FDA3B488F4C1306407618EC225AE495065BB98"
	"2651D5CE280501DAE154D4CAA4118B1923935C2C47AF01D3F19FAA2DAD10B96635D81F"
	"7F5A05BAD5096AB4E6622C7D39162ED82C6E5989A557514DC8A6217DBD2E8CFF396A8C"
	"CE913126AC022ACDCF10E6851EC8520550F920848FBC41B023CACFF36D69F04882F059"
	"6F898200A06AA42EAD14CE21F3E70DB2525C9EEA58BA2351D7881800F41E52F53E9A27"
	"D279AB5BBED0F967BDDC270F145CE88C183BCF992FF5F03CCFADE6F71DE7F7F58B19D2"
	"07BC8BDF3700B683135F7D8D608C4427621410B0EEFBA47FCC0E25F511B4432C2193CD"
	"A968C8B4B18D35306830F93823CCC0B2612AE150D67F0D2467854D5F10FEA5C62DC7E4"
	"B908D0B83B0953759DC50859778EF569E3AE9BF468238EB58F848406869E01FD98B596"
	"F4A369900CD314E0A242E02E7DD4D88B26DF77801AF0948D95209FEAAADDFCBE4E0FBF"
	"EF8AAEF7BBB95DF205F8924F749E33CA7FC955F87D5DF23178070A7446CDC09959B95D"
	"FCBE13FC2BE1CE881999F6D830BFEFF7F29103319021B9271B7A707A99FB06FFCADFF8"
	"578EB1BF9D978D9DC346DDC950DE37039F882940763047A5434277DCB88427CEA9B8A8"
	"31B48766CC3B91F1811C66D9D408A587F476C40BD1902FE57ECEEF7B078DD1DC138001"
	"FFCA71AC1E865AEE1BC7067F4D489C36200EFC2BBFE75FE9617F3B078D9D578CBAD321"
	"FDBFDA0F6F4D0382D86405EA30ABA3D15C022F6669D05CF72DF8CA44BE45FC3025FE3E"
	"DE1EF5317A57BA81E246140E6842B3515A6533BA0E627B1C4160F5B88D42E2F3DDC687"
	"A6301BA8F1E149C4048DCB278F31C7FAB54E577006CAB5E05CB40E62E9E523D9C3C119"
	"7930CC82333207F16F1D49A905D398680681E2C86485A3C25992D6BE02874CCB16802A"
	"38DEFE75F808CEB062C1334AA0106F30D538888F74333E5A6C10A714DEC871F357DA04"
	"DEDF85AA9CF1DB77AD7A3472E9FD7BC87BEDF7A198CB853F073650155842AF014BC5F9"
	"7170AE95108B974F25BF3393E3122C6A061635E8B175F00FB9600CB3DEC9EAAA2991BA"
	"B250F6CE7328153E4E2590572380F2833F36105B66104EE9BEB8F1ED0B43EDBE9DC0DB"
	"5278A543C9843CABA1EF7CDDD85FF9AC723793F0B1F492B8326C724CF18248CAF61FE7"
	"FD93341C49D59C4ABE63798687EF18D25DE13BFE687F7FCD0A3E10C179E47194D12664"
	"BF25F86626BD0CDA8FB47E1A59024C174E065D08299DA40D5098EB61025361CB74161C"
	"A7290CC258483F41FBAD632633A054C10C53FA1E8E4F6626A33D6D193B9BB9CE34263E"
	"BD4AA2591DF1A293E60999718D01C5CC036B11AD404A560D13688E1534C77F7D4A9A03"
	"666DF9DDFEE342B2D72ED8F2843750EFCEE43B4E2E06D328F01AB245A96D26D49545AA"
	"7432D90DA4D7B085A45B419F380AFAE3333518E21A0EE3AE69680536D4A9BCFFD0FFC7"
	"86D244506507A8374546314F7A2C131922D152E1CE8230A9F5683AFB4E56BFBD655E18"
	"9AD92836E24A4E895C1869FD3FE417609104D344A149C82F9671FCD2F365FC329A5B96"
	"FC037EF196FC3739E63BCBFFB7734C9C192678ED9FF2FEA3885BE0221FF819B20134AA"
	"A01F3035413133A5CE61C47AF235F82F49209F05785B9019FE1EFE273DFF67F0575965"
	"59A2D3A1BB2FFF795477BF5929CF4083C52DCF5D070F8F5C8C93FDE6E568ECC460DECD"
	"6C9A53CA9FFE128BB1F713D1B3A3F501889AA93865AD2CC556852FA11C132741EC24CE"
	"312AB2D98F13DDF8ECC3AFCE3E0AC25D7A6EBC7EC90302E473E2946601A08060465428"
	"D0D47CD2E046CC072DC93FB014A48477FE2421DDF73A90B946A334AF46221A0BC2D2A1"
	"BC6E794151439111578B01600F03A81F03E037D6736862C05CC9BF18D4A61436492823"
	"8AE11D8D8312B0DC503946F568F1CB3935465DC4D7FEBD56AE5A79CEAD76171F781ECA"
	"A8DF6AE4428B8C82A5C6E00B038043F1C601C45AEC7A6CC14543FDE156CE2C6454FBE6"
	"013A95BE171029AD125D451613F094597E46AF8389B9741F60F143C803E3AC54DAA687"
	"AF80062D3C7368310EEF724E4EE6FD27A04C7BD9201F588E69C03300F66BA4CDC62F22"
	"48B21AB3AF8F907DA73A8ECB1D07CD308CE71BF0AF901DDA8AE5C9657A39CDE1F428FF"
	"190713F2A51E131A911FA928F3FEC9505EB52F6F34DA850CEDC825B43DB71939712ED8"
	"9A022AEC3A40BA571F2C33423B841B65CF17F60CD12C27CBCBC858D80C20C1074C526F"
	"26248B67D9C08079E81F8661BA3027EAB4977D2118ED497CA081A3666572C25479D95F"
	"9D95BE9D58B12EB84DAFB4AFC4BACDD1470079C0779ACCD5E074C586ACBF015180FE9A"
	"0F5335A144DE3818F844982FBBFFEA8A17A03CC3729378AB81B1EA01458A9970CE03B2"
	"DDE982A8E01D2C52EAC994B6FD95E30301444FA09661F704D6E3375A4E610B300DB209"
	"1F78FB6A2C864613AD64228B213F379C2F04BB01EA68C455D61AA312028D2F0F06EB6C"
	"46291613ADB1F47A4CF0995F2416FDC30AEA8582F09A864398B1BB527ED156AA6796E2"
	"726840E05D118781D901EFD2EBB6725C8E771F34416ED170D0088F6A6A9807606C3990"
	"A8DCB096CDDAAA90A15A29835C8C6D63EBA940AB79F6541C6ABC3F0340ECA98760B8F2"
	"FE14780F2DB005DEE50341006B98B76059E562312FC112E72012C855E4F49502266E1F"
	"F722B1C58C158C2DDE40123C5D54B26536748CD98574C6C9179834BD25362C8AF81D3E"
	"992D53A397C2360060252A50A25219213105FDEB81228A5CC47ED1EFA888DC4EF9E2C5"
	"56D9E6F52CBCB59AEC667867761694D96573457F4668FC243EFCE6426291235216A3D9"
	"69267D3913E8AF7E98A47B85BBB2DAA57CE30ACD5F008307706D97E943A57335D133D0"
	"8D1C00C3CEC3841A5ACF0EB7EF341B1D1964C19857AD66CC10EF4C19572E193C248D74"
	"F228F987457F08599AE71D26513ADFE1F02D7F11ADE1DD6CA57D8AAFE8459AAEE2486A"
	"41A8A8210E6CEA35E01BDA96D169D2604C48C79995CF0638543A630358F62B5076F56F"
	"0AA188C045E12BF25B7C9B461AB40A0669708268903AB5D13F7BA5F9D9A2F137F90002"
	"DF94D959194BDF898BFE77C8BD4DC6FA2180AF1F9A20EA4AA29FD6CFCB169308B884D5"
	"036A03D73063E9DB214375A592EB24A1BB0A50A7A9BF39B8D2A68FCCAD028315E1018B"
	"490EB5784A995E35BE108AD643341B4F0E94CFD5C0CAEBE0455E04AAEB35DB0678F5C8"
	"AFDB6AE1E990FDF40CADB465293FC75E5A6A74CA17DCBE17D8107B866C058B549C83F3"
	"76D1EA66FCF6E1C7717E4BF36D67900E808C6EA6E5669A5D562B7FFC2A0D4F35AF3C28"
	"1690E415F202B16D4BDC3E01F229DF8B17246610CFFA36B0D2B4CC46896603EC4CDF99"
	"3EECD31751C6403FA521EB3AAB95E13222D6453F354E2FA6C8D57A60981790C1FC369F"
	"16594FC89697724123A4041D7A68DB9A60397C9856AF0A3A4C2B1A0E2179BAE5457A79"
	"2EB219A8708076C64EA2605213C7E85BD47426DC1131792ADD8CA9D822DF9BA85FE6A2"
	"30101FB617EFC6C5333FEEE7D98B5BE9FD451CE1C5AFE332EEC1768AF91ECE5FEDDB4C"
	"C224129B7A4EFC0CF760567419416D845F24E17B1514A30CAAE190892548C5A88CB876"
	"52492B411FD9371B053353C5E2E7F1ECF6E217303DCF5EFC2A3E6DA3EB1566D9B79985"
	"97AE53E5CBACCA26A68BE3F163CD8D372B59DBA1E97BA8E94C1EBB7DBF2381209F56BE"
	"EAE66859DED7089529B32F63E76602C3BE8CE054E6181366A4BCBD63CA53E2E55DA91E"
	"5DDE1F86FE4179205768A9C25C2D6F808EAA74809A6D45D00B17BB1F15BFE261E557FB"
	"BE60E50F2ADF1F53FE5656BE472DBF07D9A0CBC47D79F9BBAF53BEF9076AF9F631E5CF"
	"F847E5836C1DB58904A42908CF2F3C7C06D84AF095488386BA4FCB03E16D592113C5C9"
	"31D939189C243BBF083AF5E5520446D1B39FF87091C01D9C8B00BD06FC603B20AF9240"
	"14D73A682102E585BA4D0063E4AB24775B10385A0ADF76D9C22A283C8C716A751EA8EF"
	"E9C1E07CF9E92F824F27EA937B82E9984AB9D78074C5A77446430D912FB0153EB96735"
	"2DA155562BFD1F818C5949EACC54E950972D14B03B16BAC19E462C0F6271AABECD082D"
	"D3E3CAA2D4636C18C67582BAF3B8E66337A0A5BE66B57C589C782C2A7DA809CEC04590"
	"55E359960C6968D00434CFD3D731CD034A30FD3578C57481D62921A29D2230D56EC048"
	"71FEB5796BE83FDF85D9B82667E648E486496C90922222023FE2143776CBEB58A074DE"
	"0A7631E30A59B1AFB41509C91D8DC01CD1450D5770DF4A9827774B6774453AE10E8A28"
	"11AC17BB93C4E9F4512F982E766BC4E48E7ACC31A5A3161FA68ECDF830746CF801B5A6"
	"A45C1AD43F757BCC16587B07D06E1D26DE74702D3EA61D5C4E190F5650C6832594F1E0"
	"BC1FD0BC373F26A657A361E0CB8308A76265D23A6AF2E2B6E9A6AFB56B5583473E76E9"
	"9D69C7EB3F3853DFF544A0BF31BD0128BD3FE7076843EDB7FD806CC14297C7CDA6534E"
	"DFBA3009F0052E2CCE5ACD781D381D3EBAFBE6B4729D104E42780BC21FE6B48EE92FA4"
	"7F65350A058B473E8DCB620DC34815D12E1BE5630D47AC562BD770F9B14D1BC1566EE8"
	"872F6BC3107C6D12A7CBE57A8C00DB6B48146C9C98D2BE13503B883406FCF270260E43"
	"D6E6820F9B13BE6CD52EA71B3AEE1020C7AC1DAB3C284CAE76D7D074C6E6514A8671B0"
	"5A50CA005F65715F8A5F856C84EA39C06EE8316E132716013EF231E98855BABC51B825"
	"9EB411936E92CB13B0222770A259AA35D900E117FE5B08F75D83B04645F8DB57AF4118"
	"0D9A867E64259C69C76E29DA3996DEA3C58D72C759B2DA8D2332C7C8644E7462AF9E22"
	"D0541AB56EAF6EAFAC1E91C14AF40C59FA16D5B83439709823FA2617CE67DE04F02ECB"
	"080ACAAFBF1C7E603CBCFCE5F0BF1B0FBF02E063B794C49BAD7C95BE7101917DDBE9FB"
	"74223D97BEDF4B7C4FA7EF3389EF89F4FD51E2FBCAFBF8AD24BEA3EF7F297EE7AF69FF"
	"97C3175ED3FE2F87BF704DFBBF1CFEAFE3E173BF1C7E703CFC953F7E29FC17E3E1DFF8"
	"7278DB78F8EF337823323202E086F92819AFFCF31F91FEB8B4CBBEBF360E7EDE38F8AF"
	"123CB72BD1FFF4AD4F7CE7D2F7BA4479D3BF1C5FE3AE71F846FFF0A5F0F9D7F4FF97C3"
	"9BC6972F7F39BC793CFC8A2F87B78C8347F9D670FE05DABA1417BA1D8E1A1DFC4F1E16"
	"3E144F4CFCC817E2FE4025CCA830D5648022313A951E0717970A08B29AEF2837F11D0E"
	"73EE31784B59E882F7B4DC63F4D4F21D9CCB815B95BE76D23F1C59F399A4467C7BA9B2"
	"4C40AFE1D00B237E3E71272C2B24F8DEFB018A20F4C3BAB11D27F6F3A19D5BD6D1664C"
	"2FF79579F3B976DC65580D06966F20013A93D41A81CE27502FC032D54D907D09C8090E"
	"E5135201B8A2452B4E4EF46BCADA85DA4CB5DAE2F8A0D7954FFF523CEBED23F86CC64A"
	"E4D42FA0589885A47300B306662223A829A35A9140ED9E782B206204B7BDA37173AAB8"
	"A99D8B2E69B44C9AC02D819F2F5FA45E59C77AC5881D67DB450B3FB88B8AA6D06A15BE"
	"E13C3A7A4AC5F5B8E4C807366BD172CCDFD54A6B228FC297DBE308F96DDB71FFD6014D"
	"71F41A101431544A4AC97E086DB735C2A7D36733918F8E1E422C969E871516A31DD4F2"
	"1A6A925305C76BB862743F6AC6EF1A8E7FBE0B6CAB1B391EA6A49F010B017C0BAEA343"
	"6B0B62A71C3EEB4B64569C5B8CFB439805EA72F61A10847B0399852D96BEA61ABC95F2"
	"0C64D56A7936F1E845DEFF01C7310B4E8761144F9F0096CB57DD86E68DEC30D59480F1"
	"379DED6D01D9AA1C5267965339B714B77EAA6C45511BDB4C72D03E52964319584A6B3C"
	"66E888B701E99403C9B4C20DEC7CBD5DA71F2D25E38AA5496793F97DBB4A20ADD19C88"
	"EC8CE847C53B344D90A0FA459D35362ED136E19E246167AB77372ED0310A90858A2BE9"
	"8C1B7011E327B8C5387E2487EA6CA5D47233B69C30CEA8C9A089BBC2016EFB93D5F5F9"
	"789DCF2471C2ADEDB329B6146C13ACBD0F713CC34B67F9CE33FA897D50E6ED9485DF47"
	"83380BBACCA3E42C647C01991C2A6638AE89548A4CAB467A5566AC5AB16675C32164A7"
	"EEF8FAB60D5938CFE30DCE7D197AD62B0DA7F0817F8E7BD4D4D74EE2844C72C8DA9F42"
	"989916A1B341490B4629AB4F43E1CCF74EBC2DBEE76AC175CF92317E57429697D64E79"
	"FF745C0AD6287FFB90B05AB31A37E4A56272FFA9FE0D7239EFFF44F5E7C824C719DD71"
	"DD71D738879FDFD05A7DA517ACB2AC82E3F26F69BF0337C2D07189FCA1C80569312133"
	"B23D35935C51645C62A3DD366F101D3A716BC4E32AB81877780243B0DDAA76C23C8443"
	"51316F7EB2784F689D8DF39679ED9F0B297CC7C9F9FAFF217C1ABD051B66E5808DA91A"
	"755B4BDDDAB8F1242DBD147C32CE0568C588C3134CCB52801E7FFA80E8B18A11648470"
	"7CE01D1CC0E4F251CC74C1B62D5EA968D14CE88454F19FA0BB528523CA49AC885151A8"
	"1CDD0FA79010D3BCB9541F35FF6975EB6D5ABC92299C30195B6DF5DA3BB71ABD7227A5"
	"F21D034075E5B76F530BA01AA358A96C1A55CDA2D16E0E500FF5AF78072E297A631558"
	"3C26D38E5A262D463A15332B2C469E43F1AEAFA3D22C2177B357BA7CE35313F9B61EBE"
	"AD7051F6F3ADACD9DE60E1288E23FF0B3EF0368866E5ECDBB8BE3DCEA383F98B369C47"
	"FDE0958A71CB7D05BA8EF281F353280677C8EF3B88C3940F9C43A7BA66DA1C47D70CAF"
	"3498CB07DAA7A2FC49C5BD72AFFDA8E0F04A431B8425F017CA78712ACA6EDC5E37F081"
	"6FC347336EB04B835AFEDB0D9834A811537A0DA5908EFB42CDF8E250BEFB0795D7990F"
	"4E416C7E31E6E2772C832CF20C74579067A36B4274821C536B96F5BFC15AA4F0556970"
	"25FF5C21BA51ECDB59EF86B16D7BDEE76E1DD9C177A09325FB421F9DB9981BA3F9DD5D"
	"0E27107F65ECEDC8DF34AA832740D88F428A7C24988AD3F940BF902EF569D9869DBA54"
	"10E9450575E6EAD8C85F6AE29E07544267E392C991977093DE7E943112BF3BDCD880FE"
	"0991E712A03D0BA720C911A50D7C00751A0915AF5C9FA56703CCE245BD7799E3121E1B"
	"5971E9818E6833917D73C8030B3FF3D82E6E29E62CC3D8256A83C5FB54DC003CCB1BFC"
	"26160F2C7D7B6E856D164B6997684837CD542B2E8FCEDAEF5705B025FA4D15AF464C66"
	"0E61E5DEE04E2C065DCA66E1CEFBED2893CA73FBEC47B6DD9AA07EA9A346031A1ECD5B"
	"E4FCB87F3059C5D15964D6C47DB728EEBA1999F83F80C4E384394030E4C85CDE3FC0B1"
	"EA73ECE4A2214E511D00AA40B4A10BC02F490CEE5F32CEF3434BCD22367AC0CE586DFB"
	"8F61E6AA323F0E9F0C20CF5C840D5C140DE42143BC0AEAB95443A6A9A0071A955ED327"
	"5E997043C19BE785C9738E578AE58AC5B8ED5C105ECCB71DE3DBA85EA9332C0DCDE59F"
	"DB90817C1B2CF720DF86CEB8D173C60162E5C9632409222B612EC0B71DE6DB4EA0476F"
	"17947693385BE598CD7C6076060E372B3395AC19685D2813DF1B339A204B1E1FD06770"
	"7146DBC6072EA68F1A98DB9574DC61C2E649B1FCA7263E1E53C04CE8FC8B219ADA102B"
	"B991E39E3474E0036045DE03CDDC35E22E77104969EFE177ECC1326663923CA36857AB"
	"2A0338D1E089BD1DBD41D6FF8A06EBE0B42792657DC0F13D50CA8ED889323BB9DFD41D"
	"8F1727A7E3F77FD4FFA7B1B1C2363D705C9C7880F692299AB90E5D0C1CE7772CC2DD82"
	"8D3AD9C48A1D9A59C74B43B73C9B12727ED0688EA4E1DEF0504E5DAA3474C7B346A9F3"
	"74640807ECD0C308F50842FD02A0148A5B87505F43A83D911314338BF767D34B3EEF9F"
	"4A2F5FE19F0BA333F2BE5D7BA99B9EAFF7A091A34C1E407F5D329E0EE97B162401573C"
	"6D8A8FEB24CDA5D35211E1F715618ADC077654139951AAA7D22435F156E10679A0F3B2"
	"5EFA20B9A989D299F7D2128D0A001D5BAC89F7B286A58AE94D7DCC028B5B5F607C4553"
	"7B166A19957A4A746A3D3D0BF4095163E0229F03357B4AB4C6C8397AD1D547CED28B5E"
	"13394D2F064DE42D06C3457A180C17F90D83E122AF31182EF2EFF052B6C8FE191F42CB"
	"4EB610A672D1AF8AB03BFA63D265AD78A77D3662BC359BDF67FA5505C4F3FB2CBF2A87"
	"67E759E3C423F8511AFF907A74D2615DF456E9B2417C088A25AED8FA60A27BCD75B31A"
	"86D024DB6A972B1AB3A4A19870A753F9CF533034F63522CD9AD54EC0944C29364B4C6A"
	"34DEF96ED4D8536A9BCE35966B289D311761BDBD0B463B18B3D3B3CB75D9CBB5F5B506"
	"0E194E28ABAFD573C24C7E9FB169573E949BB2CBFA1D44FC88FF5D614B433F4E2AA235"
	"FCBE72CDE8E4FA3AA8046004870A518EA5F0FB1C1A21074BFA172B81E6274A4A6AE847"
	"4706CA274C97FA8DD10C7E5F7ED3BF5091DF21E863292700B6BE160CDE29F231346ECF"
	"E93BCF0293F01341821C61EE232072B8516351E510FEDB9993717E42A48B80B5D80184"
	"5BCCFB97D3237065120A821808CF8FE8700EBAA8C97528347F6B4F25216AE13BDEE73B"
	"FEFC557B940F8409066419DFD19DDBC9771CE53B4EE940C06F35EBD06B3D28A0EE29B5"
	"E5453783709F49B60C2E1BE6E5F6A19E21AFAB22F2752707E23ED03639E54C7B907FFC"
	"BDE827446E3820F04B1CCD715FE6229CDE90562B25EB13E39690B74C69DC5B26E1723F"
	"CB59A371313D41BA906FAB4274FB82D41ABE2DCC770CF21D9FA152C8CABD54C6BFF219"
	"BA9291B3352A9F0D10E22AA7D051EDAEB1AA6B7850964D4DC1C5E56A777CF110AC54E5"
	"D41B249EE3A447B593CD0E1A6490EF13D5869BCD2FE4F6A182B2F2AF1C513116341AC0"
	"BAD0E981AA5CAC2AAADA837463306E54866F8EF24AC622B2B1922CB525D6DC0BD0924F"
	"733F1BF10BA3429C2385628A1A871EFE09C53BBADC04CBFC890785401CA300C7C8D021"
	"E5C2A2723EF05B9E4D35B399FB9D857060A70684B8E6A64ADCCE44C504A34646FDE373"
	"5BAF9B7BC1D8ECD6786C6401EA3F8CE13B04A028FABD636F38723F559DDE46F7979A16"
	"F925AE4BC49B96024D88A0394C0A0FE69837904A56ADFBC6055312C44023F5BD343A2B"
	"45BA8BE73B4EF01D8773071606D34B4FC525F7326FF01B803B46905801A67764609FE4"
	"209E7914977B84EF7064D88F6D9B4483015DF082E519AA09E5B078ED9023F48D3414A6"
	"5334EA3472320A9E8E1222528EAE138D806FF48FE3329CBF42FC4363E3134DBD114A64"
	"A49EC7981B3A6231BE158D9ACA4CF3CA4E8B57F736F6C33D5E794186577798C6623445"
	"3DB75265BB573515AA04EDA53FEA04DB3D07E20705043CA900C35049EF67FE18EAC189"
	"8534809D890153E292BBE2ABA9D7E0F9542A1A1CCC4D982691282C541EC1895636131C"
	"2426EA9F059C6FE33B3C4098C37C47BF6EC07E84DF3E174AE0DB3C40F7CBBA41FB5BFC"
	"B76D10A14399C110A7234EF7AAD8671F60B355810DCE129A81E1F0867158E21C35FD5D"
	"428D90FBE29E99D7207ED0C4D1611E9CBE66B1E92F4DA3D55A4B88D6444C22A5988EDE"
	"BF56B57A56B31586C46DD74446E85461BC1A8F899C5AB259AFE59EA47ECBAE7F7A329E"
	"67EBF80650E2AAEE129E9FCAB60FD7A5401F427F828918F6DA07B6EABCF2808A4E9978"
	"03DF71A420EC7428B7F65EC34930A28E404A6AEFF579E9C444752E8204C4935B80402D"
	"43004FE45CD5BDC510187A161040E7D0B7F936983B7DB60D10F84C45601122709410F8"
	"49CFF510380A29DB7BAE8F806B2211C11AD267A8926F006CFA6D06522C247021C6E952"
	"2AAE9F7F47135881D7147A3505544D592CFA731603033E0A31E80147753C08AA6F319E"
	"9FB3DA7FBF2D05A2B31EA4AF582A42470DA829AD89C25E4DE1B8D1030B3B48B0D0F092"
	"172345BCBADFF26D5D60F4872A92625E7B1F764E9F17A647F00409718CEFE8753914F9"
	"F0F509E04C5165324C369649833A61A63468E403F7246AED69400F776EC4784E9CD468"
	"E8C2C3182EE5C07CB5137BEA115493006558EFA7FC624A8D51C9384A93066467EB012C"
	"C26BEFE2434727C4EB7AA1C76FCC1E5D5B02CD9F2560D4F248E29394176EA1F2BC25F1"
	"12B782841BA87F3D854A12FE6B59E0E2B31F44D127DA2A9D190CE92F243A9A66BED0DB"
	"290933C2327AAAA8FC57F7F56936633C3242C19826D569E52E6F394EA977ECBF8A9A65"
	"041B05B1F930F22388BE083992C5C9A441F57FC345A8DC3EAFDC199D12C7D4C222BBA4"
	"B011CB0A7E1D32158423DEABA306F1BF1869C6854B8646713D2D1F2161728F7A03FD4F"
	"17A3E19525D34A91FCFE83817785A930788179967875476B3FA1D355414A8D4E664F76"
	"920EB26A0BFAF98E2E90840EA7E2184B86657C6316AEFEB4A563AD2E6541943A75D9D3"
	"9F8C25144C29FE9A4CCEF15646ACE082CC6B208E27C71729E4859964CF00F36247F01D"
	"9D4BEC5D301051BB6002AD41C020BDB004863F8ECF99E52F30FC5EEDBA7E373D991C5F"
	"25828A1E870FDFDE975A39A5E1C898996B1C3CF040F288416B102AC08A9D9BCCCE835A"
	"C1E84263F6F9AE054BA40F725DD0A1B41CE1CCED2AC18D9D75BE175FC28D9D5BF338D4"
	"4A1B5CCA0CAA23D15CDF4EACD8F8772A3E9A14C7339D0F74C2874F87334FBF0D8F9CE0"
	"2206189DBD7E1B5ED1319D5BC5EDA72326C1EDB6D7F1BCC974FAD85D8AFBE9FB57AA1E"
	"F6DB4BC36A34161162791DCA73FD6357C08EAB12D4C7EFEE2AE89F9FCA96C3EE4BC2F3"
	"46FA109D89412326B55CBC8D1DCD7198A39992A21326968B3704E9907794575326A96B"
	"120BEC544CDDC1919581F872C7C786C404930FFCDE90903BBCBFD340137FDEDF4E2F7A"
	"618234E8E30378F83961812F77BA7A4B6D6B471F8C11CDFBF1CA8B83B83311AAB3D57E"
	"FE6346463D1FF8268CB69A143C7DE1E878F9141E34F20457DA1C8A3E87FCA7ADE8F9A5"
	"D82FF1FE4CA8236AD809B38F523AC46D1726E0600BDC0A05345CC5E9201F9A8EEB4F6D"
	"657A48E5FD615CAC44A4DBD0ED0E86946FFB4BB46483376670CACD7DE45B80168BD4A3"
	"0D15FD3C0BA7AE31AF74EFCDE213EC88871312DCCA33B7D2DA98553E967BF2D865F41E"
	"BCAC13E7CAA73BA3FAFA0F7998AD9F3336AEB43DD8F44EF8437DCA8926786DACB24D6F"
	"3A11FE406FE353DE691A809794AE08FA604B9793F8400497FB2097593E8D809D5163E4"
	"226EAAD50376F2C9FDB8109A3B104D560F94C959667B261FD062EE885E0AC3A456FFC4"
	"B9047E46B7F2CE2C861F60E695E6DFC1071AB10286EC65AD3049BA0C6416A876ADA0EB"
	"548CECD842E81B5A97BBB1D476ABF2DDF1053C709D020A4615D0749A2E2EC0221C6EE5"
	"61353BDF3689889327A4E1ED0ED03BC7F9C017DCB54529DC4851D255331FFA0F5CB7DB"
	"37C0EFEBEEFCC038119E304F57DF02389F0F56F96B23781D80CA286EE5E35B46A39CC7"
	"8E7514131348410688FB3D52A7D6494DDC371EFE9938FC13ABA035AC588456B6DF32BE"
	"3529D81A03B446BC93E5C825EF637E5F1F43F4AC91DF7762E211261C7101A32F68BA01"
	"D5D322A9578FB58966C69F82110816F93E2A1A74DA05162DD3A82C7A3752B7534BB322"
	"4A1395C86D1A6266AD34783B1FC09B5D7C020AA7AF1D66967641D8E30D2ED02A2B98BD"
	"0084DC7A7F6831D0F1795A362ADD5DEB50DEA7347D3B32BE7495170CED9B718B54B915"
	"E21721E35F35D71D8DE0DD3C23FC461A40AEFAB72C97F2F2A8EC0D5763A816E325FCE9"
	"102B81B5ACAE3FFA9834781F1F4017D2C0BB62BACF87A8860F51FEF82AA96F1D46FEFB"
	"A1B1F87FFF5002FFD451C84727B0559AD2BD590EE586C3895D6F5CB377EA41C2872A9C"
	"442FA0B05DBC897561E869ADC3A3F4DF3C567404FAAE90835F69E05DDE7F0C11C10629"
	"D90CBB480739C2BE8ABBB4E25DACF93525B8B31ADA6DC3851997D298CF5DF79CDE6688"
	"8FD43376ABB0953B7D28C0942537130739A0FA86218C11D62233C599A89298686B05E3"
	"1769D0BC7512BFAF9E9A5DF5CD2C64F5282F9B02282A8315DFCC82924AA1899C309D9A"
	"58CEC6DCC7D9893AEC47C5979B7DCC31309F096176E2585361ABC13F1B984C8E0D2494"
	"1C22154B2F1CB55824C7FEABB8957B1DC2D310CA210C40D8781FD0C460D0680DE3FFE9"
	"0CFF3BFEE9815FFF75712B7719C2B625801384FBBE0AF34C085E083FAD68E5E697B672"
	"1BCA5AB977CA5BB93B213CF0402B57B8B495EB80F0EEB256EE4580E3004EEF68E5BE28"
	"69E5521E6CE51E0298559026C1FBB3F05CED06188D56A7D76A0C49C9C609292953A772"
	"53A74E9C3875EA54D3D4D4A9F8CFA04BE3CDDAA44993A7EA3593A75820263DE3864C39"
	"F6D305ADDC230B8125203C01A10E4200C20E08FF03C2CB101EBA1FCB9F3041AB9DA0D3"
	"4F18F5CF6098909434016A4CFCE346DEE2FBC9D6F137B508B6C25F6BC87B1B3B53C851"
	"720E803D1993BB8314D162C393B0C574909676038374994034B919130A50A9159193E4"
	"9F831B6C66BC9FC27EE9C9ADCCEB408EA16B24DF76A7BD9B0F4CC585F1E1E9E21C9876"
	"B718A9380BFC55827F8C2F64F3FB164CBA747A7A583A6390C25AAA383A6DD42EF52AB7"
	"72FE0C8D22AA1BBD3EA4525BA136F70DA8D66C7FEBA95D844C843626EDBDFC8E5B8C23"
	"732433C7FBDF4A46AB58DD9D05950D9FCA3DFB63B1C81768120E27F381E74826E11134"
	"FB5BE2031E8FAFEFA5F8618A967A2A5598E47BFDA591131561BA9745CD30A9D71056BD"
	"046B92230FC28310958662623244DC0B11F38BD1AB960FDC07EF1E287F6DB6EA4BEB61"
	"AEB42D981CC9C209F9709A38919D5D8E4CA26F5E9C24A75347A453EC155C691A9E203E"
	"139F6E7C43D9D08EC45497B632F1AA18D67EDA7903FEF7EABAD96C040FA8E39C2875F4"
	"2CE42C5AB5606E0FE4BEA14E7F3269FA8362212B31FD51F6B1DDA1A786B1392BE92CD0"
	"A30C15610A6E78A749C34630D5D0536109EE049F6A8BC5DC8C6DC8BF0E3A50E9863876"
	"7C3B7207E6052B2F304787BD60DD5AA4FC1852D553DF93C66C33EBBA996783BF2DCE34"
	"7277CF82498C4B23E7700A347CC7B39335332C74A47A2EF259E40444376304F45EB9BD"
	"5B9CA7EEE1E58873A4E17C3113587DD4417156D40FA9A885A26934EBCBDD2CF19B94B8"
	"48CCA849511E46F6ED8626B1A47FA2A452719A7216C8E451FEBD6B4C7239252F153394"
	"2E48567E83DA492D743625958BD5F10DC791F9F1C5838C683BF68DEF5DEAD7C404374D"
	"9D2E37BE48D3E578C927BEC092EF16D7284BA180F8AE211EFD7C3BAE7F6D594127F3BA"
	"91CD4147B25776E843E5C9DEA053DF5492D4B820C9CB967A8995824BD29A91262D78C4"
	"3E5EC726AA631E1FE8466BF74FBF0244E3163A9E357E9B955D4E7339F8D3997B022F79"
	"81995C0A6A675A27CCC2B469D82298A85FC83D01F33964C169C48233D549DDBBAF8D6C"
	"7B19BDF39F4E1316CBCEE4D082E420CC34CAF5091411EFF8226B128BE5DB16A625AE50"
	"A2CD8B666C410BB56574F7B6A04FCEF063E2C44AA5A803A403F9E80CAF10964AC3AB84"
	"7269D821E44AC3CB8559D2F06AE12669788D9055335D71BD074CAE54BCC7BADBC84A7A"
	"0872161C6F4FA259573A2A4216BF00E295F06B386F675BC305FDE410071CBB85442C5D"
	"3F402BC1419ABA04C962F0065347CAB88A674B06757CE0659CCB2D1B9086263C954E7E"
	"77419AAD32A85308356C17D514BAD780A5FC8652EEE1FDAFC14BC87D08E6194F990001"
	"4427F232C62D3B230DF14F8D1B4CDF8294F914B3CD1427D8168863380314DD6260F9E3"
	"08635711A260899F4244DD03D2E5094FDDCDF6C364D3F3886AC8140C552C1B08B2AF86"
	"A1D8B3608BEEC8827CBD7A8AC28888496DCADD324D2501B7AD46DD1B41FA507D495605"
	"8B687ECA07DE1F8AC570D6A8367660881A5B0752E93E7E47D710B6F88C74F99AD6ED1D"
	"BAB675BB214E3363742D7CC0121B5D7C14E6A5063EB08D94077614E812713A2E2FEB97"
	"929166F8C3083916112A2BC53BED6F6D9B03DA68E94B00315DBC39F78D82E3C154D6CD"
	"1696EDE87B23D9D2201B5086C7398776086F1D2A2420A400668A7C82F7D90C268939A8"
	"C8E8EC15D69286AB405801EF7F9E31187E45C2049C2C16015F8B7CBB3141A89F420270"
	"B3FFF72471405FF3FE6F0F22676FF9FD1841F62C1560146F95860BA080098902BCAC80"
	"FB01BC66855244E518A325D2E004D0069869780308C743FFA10AF89E9249897197CBB2"
	"1A59560D3E0A94CBE8C3065323C024F024523D3951D5954B742986D9BCEF2A3EB14F50"
	"BFA2C3C954D4ADD66B74EB29F5B03AA4E231512B6E4995EE62C7484039E873FF16CC1F"
	"E5DF5F10B6FF056C567E375EC362ED26FBC94C47B6AC1E5C8C0543EA3CF3CAACB2D209"
	"4EE5F5B769BA81CBEA781F61215DAC832E6D4E3CC75044AFF21B52BF1E5D908B5C0E27"
	"1E8E2927FF52F176F598CC05B7EF3D56EAF08DE439E88E1F21A1EB60CC5D39886FA9DB"
	"133FC15FA9A4F7AAEB4AE42BAB02BD793D7C8D3FA492F7DCC8F035FDAFE05BF1F7F05D"
	"F60FF0D5C4F15DDFF377F06D386F065EACC6439A7876BFE0133C8A43D6E9DF78FF11D4"
	"697E1BAE323A94E36CD10AA7B3BF84F866DB61D0EF874543BBF5F956AE124F77E6009C"
	"C7EDF0199B0139BDF21F33E92067703642CAEFA3B51A4B5F8E9DAFC07B56C3D53D78B7"
	"99FF612D2EF0ECA5F765F4FE2B7A5F48EFFBE8FD2E7A8F5CC5D5AB2C88692E3CCC16AC"
	"8A00D526BEFE6CB87EA85ECC918B4B20BE694AE3CE3C7896DCBF0C582C2D705158D034"
	"9181081FB6604E769A45CFFB0FA000D96ECB03C4738F8AAB7C98CDE17BEF65C2FFD319"
	"D46511BCA5557A9D803494BD1DCF71C354F9F4CB08FD3A83EE0668A04191911DD38FF1"
	"FE5980686F329D9EFF1C97A82E8A33A421CD7E96793F6666F5397DBBE13D9ACDBE0044"
	"9CE45BCB0ADDC850889A9DBE1C16B392622C44001F5EF6CA0ED653DE1ACE872462A772"
	"A159D8A1359C03AF12225F58A7B2F173EC4373AF01B393BBE54530D28186174B67C6EA"
	"C140C795A1E107F9C636A4ABE5C6FA0FC2F597EB853F37E96F0CE5DDE80FF341F47193"
	"4FE69EC2951E69171E108E097CD3D218D1173A649B0637251768C3B557402B1E6EA5CB"
	"1F9FF3E1C9F523FCB7D662EE2E4735A14BB45426DE14BF7B412F5FE2FDF76AD4DEB5FB"
	"89E2E23469503396E066F81B411E45F7428BEFFC0F8930F767D1D15C2400C0F4416484"
	"16A28AB1308DB86959D30D8DE9B3F1BAD43589F2DA7FA8F6418DD6E1DBC9CAB9329D08"
	"CC685B6AB3396AB42A71AB55C2EE8E13966E3D73D1B574E99F5D4358E1197E1F50150F"
	"6C56D1F815D687B60DC72F260DC46AA7A3FF2CBFCF74A37304243906E90F3E1DB98860"
	"422151A2A96A666C99CAD223FC071518DAEB7F8804F131CC174C67AC7751BC011831DF"
	"8895F0FE97D9BD38E660727473C330B68A7FEE0768176CA0EB75B2DCD5EE4ABA5B91DA"
	"C6F279F08C3652BFDAA1D83F25816585D6E17640A05F48013C93A0DBB51A1EAFF7B347"
	"F0FE4874E8ADA672F2D825371698D902900D040B9634FF6E616AF3A13E44D7F143B457"
	"FE2D7E9C5B1BBC1B8F14AC59B17A55C32114465D168E951732DD35EADA4725F0092834"
	"3C0F6663ED754E23E984230EF09E674C0C6528D7E1715782CDE900AA22D691AFE17D02"
	"2C15FA0F0515E4B4C2C309B1F87491C307C28F42433D7F4D37D25A80E077552A6F1E52"
	"A5A0709B87AE1770FB2C4CDC754D2542E739DC9E4AC54077F658F1B8B085A3C91C73FB"
	"C5131D789C1E8FC1521A3BCF210DFF4D3048C37F1527B8D5ABE82E60E140BF7BDDCA43"
	"892ABF22B3A9A1D951C3799CEE5E034A563D885F65EE653A759349F49CA75ED68B5557"
	"911B057A759B5D0E0F1ED958C98E93A86770E8B25D6C09F08D30C7A39CEF8E577613A2"
	"4BA7761D1E56D317BBA1A637C0145A23F7E0990F2CD4ED04FDB476E4848A743E53C939"
	"0A860488A17528EBCB8B747DC00E599C98213D2D989E2A52226052156BC144DF920F2A"
	"A9BB7DC132BC286641A938F940E5627C759689C9D482A8B620DC92A3EE4DA0C3AAFBBA"
	"C729AE7F44282571A0C0844E4226E68F114CDF8C66B03198BAF7125D5EA987A8567885"
	"E98BAF10AA72FFE817B8A240A7977DED97E8CC61D6A8A38788F2B8F3DFD279632573D6"
	"77DB0FF3814E78F3F8F0266E7647C20B7874082FA669D940860EDDC2528C8B193E0B50"
	"D4D172888EA7B4A87B2929BD067CE3CC603A618A6FE05F70F5E3944C377FF836C097B3"
	"C547D7FEB4E0B131BADBCAE22838EE1B6C56AF33622731D87987681ACAAA1614B0CA9A"
	"C9740BAA0D06884F0F58D22D07952D87E8AE83DD80A6F2F3548EABF47D841CAD09CEC0"
	"63C9CAB90CF54E85ED78F045987E109F7206E1861EF578934C4F265E4873CE37D04CD7"
	"6BB441161F0A29F5187A0DA71C6A439E881F4BFFD601DA9C2977CB8A72E42A4E301107"
	"A7EF35C8AF0CED4116CC470FF45E039EA5A0C5E51720C9E76F6E55F90A2A26BBB1259F"
	"6EB3DEB92B7E581A04191EE441A3730DB0F4C4587A237E5B51151523309810687248C5"
	"56F6B114EFAB88A5FB71E8CB87F14E3D2370326E3D2D25C7EDE5743332F6BD2B7652A9"
	"FB49E2406A3D4E68FD6CC77E129D65A88BC7386227E918847893AFB699D97FE8838B0B"
	"5A4CE86502349ED78EF2BE0D0C404A27C185770C331A3DBA9FEC70984E6CA62D5A7FE3"
	"DF3B4E44FCCFB7A56E2637C1965AC28E234FEAC253239734ABF7F5E11731B653BD0090"
	"960DA06DCD7B2FC5BD9E821AAF4CA3421D340E7D53EA2F2E8D78AB2649C574EC494827"
	"0028BB16ABA35352CED84926BE41700B63894AB3E73F7009E20B1B59EFD80DF829AE95"
	"E76EC67ED4D6B09B3CF3808C7865107537BEF9D819322BA63B7D03775DFF54BCAF8451"
	"F42B16A2E8E8FA190308ABF09418194E3513E2E5A7E7B33B5A16A08CB51BF0420D21D3"
	"6EC0CB3404B3DD40175C18ED06BCE0429CE1CB638C7E74CAE8CB165E6DA3E3D0A32A44"
	"799855595D934577963BDCF269B0D499A65F2ACF7E11DE2EA9D7D009B3E683C0DF822A"
	"D958A3F771F9E8D6813F08E169F8007F19423D313555B7D266A9C9A25903DE07C20A13"
	"F71784B1CA2CBC1FCE82374564E15DF1AB0099EE4A79C61E00727B42859A82D84E7911"
	"729085E6056EC703B113528F8589E73F85F41D6B56EBC22B7461CAA8CAB7B486F37835"
	"5165B53C1B2BF350E56647C1BBA05FF13EF76D7231961FBFFF1D4F7BDA014004CD5D53"
	"82E7DC5C0E39C9816708857BF7B33BC1C06C12EF847E5CA703AA00F10639326337BBE4"
	"0CBC7901202D0D75361F5E0E26A60081B6E12F2788F93A3C9D94A6D6CF6A1777FACC3F"
	"A2CE2E9D4C9DBD066FF06C388418E32599A635ABE25F89FBCB4A51E5552837834580F7"
	"26A06AB981EECF5AFE2355C228BD60B9CB0A8ED44F78FF10B62AC95363255E53190EF8"
	"057B0F8F5F8933E27744E53154F64F2281B96615E88AD2EE4AF52A19BC5336B492D332"
	"ADBADF59A51E76CBFD4BA822E702B52ACB11F25882E8179A0652FC664FA87238B429CB"
	"D9536ABBDD0776E31DC8F6F051A0E0B1C187BA39D57936B8D2762F4CA84A4067214A19"
	"351CABB3DAA5C62431C9E819C1BD15A34FD7C42AD919CD4AF58EA4341F578F101E100D"
	"7B016485DA8651FAAEE1FC6EE406F945DB8B281D27E2C4710F2A3CC606D4E97E1BDAFB"
	"0EBA9BDDCFE0A6C4BBB9C2B659D7E374A0D59C133B05D3AAF720D6F4D48DCA89E4B855"
	"30A552710FAB0E12D07BBBA92FFD36B4E6AB2BE5A3CA5452187E9C54929C01C0509D26"
	"0B66E7586A5EB00E4A4E988CE234DF3AD62DD96676D1D1A8427BE40265C517C4071660"
	"A6FC711D7901DD64590DA6EAC461B55105F42E42DD541F12F5BD496C7315B172FAC2BD"
	"C81AB9AFDB5EA37BE1F46EE5169045BAB9985A10760493826578011B39257A8C41B729"
	"B8CD0C76E805BCEF6EBBED55249EAC8381E946A7EF3D4CE8A105699175F2DC5789CCCE"
	"6ABC769F5D1C5C9DB83818C87406C5EBA0E9C959405BDA9615B3C0E23DCF26BA584370"
	"37C507B7DBCA49BF2152A18A7B8C10719EF24E7C72622F98D5EA8F9D80699809D5CE7E"
	"6D17DDEF8E7785514F7A70317B54B70A4E0FE8103AF53D855DF0C5C05CB1B70113C42A"
	"EDC975801F0E4618E10F0136AD1A5268E5506C5EA8C828EB5C1EB5BD30FD29D40873E5"
	"29D23A5BE170FC2EB1722C4C9E4859503B7850D5E061E78984980300402A8CEA1FE257"
	"2B1E222673876ECB06BD8B047DCD9683F1A1AAD26CF2D671C1602CB5C5D2DB91BAD61A"
	"36F563FB502A77DCA47287DBB79BB1C7B1549A9C178457371CB2D2AD4E171A3E46592D"
	"2F2B924BBF522B57E443A7E5DB743DBAA395BA93D5B22F934EB7965B7547D16BBCE0F8"
	"524F706EF961DC08B6D9E237EDE15D9CB5CF4627C6F7EB2129A4BF1D6F19DE6D9B8737"
	"6A0D1E8BC9A6FDBAA34CDE3669EFD188D3FC616172D3C39A7B1ED2886978CD74A7D6FF"
	"AEF85141386A981E964EC780DE194F1B429B6251C303303CF05CBED9FEF6B696E80D38"
	"2DE1DBF4CF1083E91BD4A6DEA0D6E5F2D5B3A67E6C627734A90464FED71610AEF1A68F"
	"DC27D45C7198DD9935070A9AE3EB43A1DAFAA311B38DEDE25530659BD66BA8502F442B"
	"083F84F7AF19F16A6A17DE8526244945364EFC2F9A09C4AFC386FEDCABA1E59857E9E7"
	"16F4784719D78E9BF4621AF0892DC8C64F506F93D8F0C3F82A9B15B8FE35160F3C8810"
	"C07FAF8DD26B28C7B0260F5D5598D94BBCEFEAA541202715C490DD5155D0749A346A42"
	"DF5940DF658A1E14BC20FCD0C9D8E18A9D800694B6337D07D25A9C076D1374D0EBF111"
	"B39D9C0F9C729ACB49C03780CAAB2595977AC96FDBA1FE5E90E022B7BD01F9ADCE73A6"
	"CE884977ACE132FEBE102F5DC0C143B8EA06E524978A5F003D8B714CF87ED7827E1CB3"
	"2732B5B89AE945A45DF77E36E1627E6BE20C75D2B5DB76908885F7E6F4C5E2B0402C5A"
	"13AAB05982462F7CFD0EE75474360CE6DC8734B8C24533B5226019FC94EEE1C4DBBCE8"
	"BF7A33CA02BE2DECF0B5B6A053DE8F52985A1C8D8A5A066E41D51DA8D0303FD4C0CFD9"
	"82DB7992199BA1D2B54C66ACA791BFDB560B9F2E5D27D915279AFCB67AF8DEAB1116EE"
	"D58AF74AF771ED7B5BF0A6A0F6975B48705A4082999D0E5F630B9E0DCF427FDA0C9752"
	"C5AEAEC14B9D7D3E4C890C0CD34287655C094E5C92CDF439889C7F9C40431EDA4047A2"
	"E3CD38B0EE5B84BA681F5FBD4055CF8357B7D20C99A92EB7F21D2A27732C2DE2E43213"
	"B99E98701D72C1B8F59D86C1E48A6403B6ECFE2E796E7817BBFCC2C1F47C4D8CD43FAD"
	"6081698C33113DD782625EBCA718E5E053053413A31920AAAAF119981A933A75D2D92F"
	"82F4BE1AC666BA7E0FCE07F6A09D6FDA837BE298B7E510FC09A6F6F5D2BDB1008ABFAD"
	"B53A315CDF1C3565A3A500BE6D4109DFB67861E719E3C4CEEEC47D1675F8931DB41ED6"
	"961672D28E955E3E129D22C5CCE20CA9DF1A72FE50BA6C786AB2D4F96F78EA2B857FA5"
	"57D729F568A36F21D902FD8236F8953578F33CFE6C4F41986F4B913A6983CE8CE01343"
	"FAFA907E0148C6E89FC6DD974E97CD57D94CF4AB47B3DDFCEE4E97FC29DDF617B26C76"
	"29ABE88E7C53E0E26A417BE9743783E7DB8C6E2FD4391333F26D77E2B1688BD7BE442B"
	"A4F16DE55A29AC85543182BFD4A4AEAFC044F4365C63C10ECCBDDCA4BFA12965D93D9D"
	"82B97EE891BAF4FAA1679E359BACF7748A290B0317C5B3F4134FF1DF5B72A2356F6E5A"
	"440B45E62010CB0F52680E4A2E4F08EC76FE607811AEA64B83B708C6C6A4B24812BA95"
	"1D5CC4C96BF452AF7E51413F08FC4C69F04E21451A2CC47B24E789C650F900822C9206"
	"978B1580EAAD977013F982600895F74567EEC78DCB4BDD17A0E9C224A9532F779F5040"
	"56FF2DAAC71F1B91227AF9C4897365D2077CD337FF0AACDA5816832294480847ED9056"
	"9CD5FE5BA0EBA50F3BCFE99ABAB4E1D0927C6D583BA03D7EFB3BF5DDF98D698DAB35D8"
	"6F8F365CE18E7CCFBE25793F3EA2B78D6422EFA6C07121A3032F5890DF0A150575B182"
	"E372F7A54B80C55FE8EDD382E3945A76E91265ACEFCA6F74C72E9D85ECF211C0E61DB4"
	"5A806840ABC03B3052D6AC907B724B6DC691DF5518391FBFC16602485A0243D2CE46D2"
	"E26D01EEA80EFDED187D3391BE13BDC164A9574B4BCC44E22D7AA94BBF0875391058CC"
	"917B3A15BD973FD88864F10679E9631EBEBE855F8BBCC107B4D01F914E32B1968B6597"
	"7A46483E8D91BC87489E8A24EF61249763486EF8806AA533585A3D2BFB816168E587D1"
	"27A5C1C7445CB9FBBA377837C044D7370C5F87AC1F8F26EBAF89AC6F84B282BA778198"
	"3D973E57C9DA8364A55428E9D2E79455EACAF7063DC32394C5CB5C2D2A65CF006557AF"
	"C0933C3CF0EC2AA22C8EBFC07131834997970FD3EF70E0D2D2017C8771E92EB82877E1"
	"E8B1127DBDD2D04A512B5F183570CE87CAB4300EB47217DF6606E83E2FA09DA3DA435E"
	"E9F21C48FA946F73A299831E77E7A1FD13EC404AC4246DECCF4FC07CCF54491362B747"
	"1E94DF973F85D99219A605B9819870EBFC0D36AB80879CAB9899679395E8E49043D364"
	"2CF1F78B43B95D2C4E4E5D873672E9D7395D3854956FB41FDB52A4AE50971A8D6083D3"
	"2E0EAD54B39F5BE3FD5E98413A5A308126103479C05F5C6BC1927021BB89F600C45B9B"
	"37D0EFBDE5A34035E57BE5F4C23DB48897AF977A92709D15E7F5A66EA97839AD5C6412"
	"BCB7579F9F9D0DC36834808F96B3FCE7B53869A142731285E6C50B6D4A9D03AF8D15F9"
	"49524FF2486EB918F7E560BA36BB0EB75E146173EC54414C5682F43DBF0EC8B4165A8C"
	"7B4E9B0FE322804977D255A3212B9CD446354E4971B9A2D7508B78E08DC88695F0B699"
	"96E75043B1B2F1D6976031C2048B57D25F84886A0B62CDD8427BAF5C8CD508861EFDDD"
	"D96571A3383A29B1BE00DD47903130F6D85523297CDB74094C1E6D3499DF373D86B73E"
	"5FB1F2DB1730A36186545CC516FAF007BAA42BD9E24420DFDD2BB3233F6117735B39E6"
	"D181DDF66DBC4A99F625854CB6272998D97EA460647B916229DBDB4849A05650A96EDF"
	"30CCE3CD14A60320D8AFA65E4395BA864917A4D365E3F1EECC569113A656864C77FBAC"
	"7B50F34FA03B4C4DBA0B1134AD1AB3EE2E8BE0957F723AD28B5DEE84F473811237E986"
	"3D351A293CECC03DA4309DC4DF4CBFFCC6A858A056D49EB9076FA4E82A0B554D5ED958"
	"75770CA42FFAF51ADACD9050E908E9EF7628BBE8AE50136B00D48E8ED60C798EDD81F0"
	"75E8939565D295E94F2DE5F7C942035D6250010F88CF2F8BAE84C72365D16A783C5A16"
	"5D060FA12CFA003C3696454BE0F16459743E3CBC65D13BE1B1A52C9A0B8FF565515B65"
	"C872B70F317429A9436ADBA369F5DD986975E3CABB51611031F9C0553A73C388C75864"
	"8489771EAE6FE5DE847002C23B10CE425020FC05C245085721E8015DD549133D460D49"
	"C9A31D3A27189B71A11CEF729307A40F740DE7F7E0EF931DDB9A7273E75E3DEF4F03BE"
	"AE2C78D73D7F8603A559007F56CCD78724AC8CA5BF87EBCC186FEF16F9D5C119581258"
	"6E58423749013AAC5519BFB987FD2063A593A4C428E940BB6495359A827EE53EBAABC8"
	"D8B296201A69B196786C2EC640AF65F8C27BD02E3D7949255B9052E45444C3F757BC1A"
	"9AADF014E30103DE5FA1C3AD099A0BEFB661BFBA7C2FECC1B24FEFA2CD3FBC0FCC7E45"
	"4C631BB246BA1E4C309027537565A503B0C265675CE139C48EC4D0CE8B420AF26A8CF7"
	"E314A2465B8923E27758E205FBE782D17E850FFC867CA10424CEE742614D314DFAEF72"
	"29B7E850DBA26F5DCD32983ACD7356F7FA6D281B53535253F05AD092D414B66545D76E"
	"C4D2DFDCC57E602D07EF3F99851B3B36077ECF7252840B63721CD48B4EBAECADDCB79C"
	"46D57F5EA4DBC22B69E553BEE0A69F6FA9666543936FAC56D7C0887440B5BE5DF1A51E"
	"EA40FB5C445EB0B0FC355A9F034A55B33725B30E41F301D7C2E4D9D84930C37B1D72A2"
	"A76CD12D424AA37E4ED90391A721992EB928E8D75DAEBF2F3B988A623B988A1C1D7C9D"
	"3288BCEE72307D5444FD7D37B338DFE8B82271A2EEB2FC46E2FB76940C302B2BC74324"
	"00CDE2E5E5F849F7DF1F4C961487EE321832FC73DFA31319F51F05700807FAE001F267"
	"8EAF822815FC5B5CFEE08E030CCE3974AF964BD91C4F886EA90CE9E7F8CA89F71E4EC4"
	"AEA442E65121A589D832D08C72B77C54F9C6204CB08834F82B6017A2B39D2E8A7F685C"
	"7C7A8F7ECE2D4D0FC4749FF9C3A2EEC1A80148A7FBAC9974B0E3BCFDB32D774B4ABDA3"
	"595DF91AF98DD3BC51BF713A32A658C934B29A92D16AD904564B348945D7A02A9D93AA"
	"9E26E9D1A2916DAB563749E9BEE243B836D0221C8EDFF7D68CECE1B8863D76FED6DFCA"
	"7DE1C7ED9F56AE0DC287101A215880B65C52922609FE6993AEFF4FA74BD2271962B7AC"
	"84F263B7ACA5BFB5F4B78EFEFAE9EFC0AED6FFF773B9FFD7FDFBE2271C67FC29C75920"
	"64439803A11CC23A087510764368857004C269081F41B80CC1BC1760212CD98BC72939"
	"AE164213841F4168877008C2EF207C04E1AF1052FE8DE3B220E441B817820BC2A31004"
	"087E082F43D807E14D08A7219C83701982F9671C6785900FA104820BC23A085B20EC80"
	"F0228456080720F441F81882FEDFA12D10E640B817C232088F427812C276083F83D007"
	"E163087A60EA9910EE62C73CB81A084D107E06E110843F423807611842DACF39CE0661"
	"1E840A086B21F8206C86E087F01D087B21B4437813C20710FE0C611082E917500F843B"
	"219441A882E085500B61278456085D10DE81701182E9158E9B06210FC2BD105C101E85"
	"500B6107841F41F805844310DE81A0401884607C95E33221DC0EA1ECD5917EF66C795C"
	"587FFFA68D4F6CDAB0FE4151D82C0AF7FB1ED9F2C863C2FA2D9E7F90BEE0FAE90B0461"
	"CBE38F8AC2FAEBA479AE07CF55AE17EE17B76C59BF515013CA366D1416D5523C8BF03C"
	"BE71DDA6A7166FF46EA21B2D13F155EB6B47D537125FF9D896F5EB372E14BDDEF55B2A"
	"1F7F663DF777D2B0C445B563CB04549ED8B4C5B1E989C785C7376DA4B4C7B66CDAB0E1"
	"3AD93D5F9206D471AD7F64DDDF23EDDF4F5B706DDA4813AF4DF35C276E6CDD8B3732B0"
	"6BE2168C8DA3FE8E7FFF4FCD9FD040B41A0036434BEC5D7B741BD599BF7E9127250448"
	"20A4ED9058210971321A3D4623CD8CE2584EE2E038C68FD8BC8E2C5B135BA0177A3836"
	"5DD8003DAB34ED81B40D6D0A6C1A0A74439B566E16420B0998F028CF62BA8028A438CB"
	"8657398494A50B050EDADFBD33B2F58A77F7CFDDADE4ABB9F3BBAFDFFDEE37F7BBF71B"
	"7984F3FADCF9DA4050A3F175FF850C4F9D0E9D0B4C48A94416A74EAB2F4DCB93454330"
	"12D7D6FBC27ED06B8869BE09C5CA6F1EBCF434DA8BAEBC38EA46AEE6406FCC171B268D"
	"4381446B2CD2A7C5E3C41BDC4AB554D755A3F3F97ADB55745E5FA03F1B237E14688EF8"
	"FC46DD8D435D45E7F54C56B4B97ABF3F469BA4E78DE1C1402C120EE13AD8EC8B057CBD"
	"B4A5F278BDD10F837117293CAF2F688F8D6BDE391BD7BD64CB92EF9966D4CEAE3DBD76"
	"66ED08F915A9AD9D557BAE698E69B6E96C936C7A70F1438B89E9D0E2C38B179A6A4D56"
	"D30A53A5C9BF485B345AD5B3E82EF20026C8CAD32A6AAAA64D9F3DF32B334E9F750659"
	"CDF5CC69E5A3DB46F71EDB393672B2249DBDB6B13FB26D9B7EA06F4446474771A44896"
	"FD116CD8D981BE29443FD8CB8B40FF338BFE1A4D46CF4F212F3EBCC0BDC0BDC0BD593D"
	"5B0A780A9114F014F054562F9A069E069EC6491A783AAB5797019E019E019E0190C9F1"
	"019E059E4DD35F6E67FC58B3EC9D4248236410B23A157C78C1C70B3E5EF0F1820FA307"
	"3E5EF0F1828F177CBCE0C328838F177CBCE0E3051F2FF8B06E808F177CBCE0E3051F2F"
	"F8D0AE79C1C70B3E5EF0F1828F177C5877191BFA4E236410B2BA08C027050229349642"
	"C52954C2C482C4142229F049814F0A7C98A8C027053E29F049814F0A7C98F8C027053E"
	"29F049814F0A7CA84853E093029F14F8A4C027053E4CCC4C32940D7D6710B2BAE8C127"
	"0D3E69F049834F1A7CD870804F1A7CD2209146836954CE860885D2C890C6491A7CD2E0"
	"C3860D7CD2E093069F34F8A4C1870E651A7CD2E093069F34F8A4C1870D2F1BA5146392"
	"61EFAC3EE4E093019F0CF864C027033E4C0DC027033E19F0C9804F067CC6C1671C7CC6"
	"C1671C7CC641641C8D8EA3817154368E82E3E0330E3EE3E0330E3EE3E0330E3EE3E033"
	"0E3EE313FA4D35868E12954C46D777AA6AE093059F2CF864C1270B3E4CFDC0270B3E59"
	"F0C9824F167C984A824F167CB2E093059F2CF83035059F2CF864C1270B3ED94CEE7A02"
	"8E0AB3289C45467A7D4D9F3E9DCC9D3B972C5CB8902C59B284F03C4F9C4E27F1783CA4"
	"A5A58574777793DEDE5E120C06C9E0E020BB5E77ECD84176EDDA45F6ECD943F6EDDB47"
	"0E1C38400E1D3A449E7CF249323636465E7BED3572FCF87172E2C40976F5CEC68E6439"
	"42334218611702FD9DF5E30873B0E15611A208D4CF7514611EF6F71D083F40388AB0A4"
	"86EEFAB14643E04E23E47A846308EBA7616D85B0723A21576BB1B016B4082BFD41FA18"
	"0CE28B06EA42F1BAAD81705D5F24A6D1A736933E7DA266F1A83E632606307FFAE375B9"
	"736D72CEAD23417DDE0C620AD56228B525A0171E60A6A78E34F58723B140B85F5F2BF8"
	"C2E15CFCEA40346AC4D7472257D3686778C08811524F5A483B69220D6413625EE2218D"
	"F4D1EF64B149E8D6FF68BC9BBE09C799E226D80976E0688C90A690AF5FE3067C712E1C"
	"E15A3AB8018D12BCA010F76C6A9F48C08B15EF8B84A2412DA1F94B3934926EC48D7CA6"
	"76366EF4C744D6FAD0693F9788707DCCD270F1B02F1A1F8824B8A5A6E432ACABD97DE1"
	"19C4580718868831A116B4C517D2D7175112273E7C06C84AE227411264F5EBFD29E6B2"
	"8E74E28CA6370EF505937ECAD7D4AE3758683F9DA8815B1A30C661192165D20B6D2067"
	"5A142FB28B5DC0DA8B30D86A3D67A13DD77352434A3BB545970DE3950C5F1D8E6C0D93"
	"442C19EEF325D8BA491B0AC413861E44A21A5B5386B5AD449724F62CABB6127DC58138"
	"868AE96D1F5B8A90AD752A4D260D9B5A367576D41AB2D904C97490DA1299413EFE2113"
	"A5420F540EF457EF50963434E3D0BCA98D4C62DECD8D6D28D76C946E4660C9C44C1C44"
	"2A331E9BA11D3407D491AECB342EE463FACDE50980ABE392718AF9B52DBE6430C1C513"
	"AC8FB936DBE9A997D64088CB78608D15C715137117E31023FDA49738597C1A4BBB9CF0"
	"84898E9C7FB9C9EF32F94D7D6D3AEE267622A09C99F4B1F4D6A06FB83D920CFB31385B"
	"A1696112C23B5FDFD6E68D58F1DAC949077C05675ACCF4A3709D45D3DA691AD393F59A"
	"2F5A1F0C46FA0C01AC30BA0E25EC0F847D416E0B74C0D84414CBB29EB41ABA6D8A0731"
	"E65CEF70425BC1C5B4506490AA8A16F6C7B9AD81C400E7E388912F1143334519B9251C"
	"551D1A332D5A1E2710772C915792E3266B3225B989A6E2796DE5E7F171E5D8D07A2670"
	"5361D9FC16D1C224C9F8A95992A2723EEEBFD3372E2F9729FE3FCF47E5A8B71D08E7A6"
	"40AEB3636D9D838B6BD724B5701F1A2FE269A27347126772BC700F9083A1094DE1AB34"
	"36CE50FA0462749E6A8D0542982B38DDB0D0045FDF0055114C06AC7EC3D0504E1D5A2C"
	"047D49E8F6819A199D2C661143672775B7257149528B0DD34D552CE4A38D760CE4E68C"
	"621DC32E93E919B34509363572A1612E108A462079D82F4F30D814C638A0E39CC299A2"
	"65EAA0B3C2BAFC6B0616600B76E35C38010B4BADEC0505693E7A3D50FB00FB9948E21A"
	"0841F8908371A991667F8C4EA51E6A9DCB96D3F3938648328846605F586BA638AC5767"
	"98EE7D686E2A23CE30051790AB8986F9228CCF20B16026989416C626DE15D96AB7E6B6"
	"76683367AD394C5E3EEA74E0ECD6BADE40223722DCD2645CE386ECD62B7CE178006B85"
	"65FAF537512E198E27A35484601EC2A806C21AB7941F32752F63F98CDAA841EAF5C599"
	"605B9701B70825F83514EFCCABAEB4698EAB0F0F37B476169733D630645D67D3A9B8C5"
	"93BDF1E178420BE5849F972F1C09D7E94E95F8A426F266C162B5D9458754BFA6C1D3B8"
	"96CED9B99554D2646573F6105B951072851191B5503431AC12399C0C065542D78DECE5"
	"3539583E7A3025E97D137D0767D8016EA92E8E65DCA079A543C280F653A3B54C9F1540"
	"DEE4AF33092C20EAC48106546282DD6B241BA1D52672055612615CD101427F692C8C71"
	"0FE2D8AFAF59689F9D5C893EFBA125BD24895C5EB205258384996872EE3D933EB1CDD4"
	"3FB6F36F7ED1FFAF7ED1C69A206C6D5F281AE8222F55522BAFFB107FCFE26D1AB3F9E4"
	"D9CA09FB4F8E569CCA7F63AE3EB5677155499AEE2BDB5BB1AE2C2E55356BBE41AD815A"
	"A83E5FB05D331617E7574FE5A16C2BF093BDC05853CF17F61635E53CB487ABCAF9181B"
	"ABA7F2AE7E630AFFDB818AA9FC82B535859E35A5BAD89376823486135AACA4D75F2B28"
	"997372B6B0B10B6A61C4FD9568B93DE137BA4ECEAB6E4B042FD362918DBA8D994FCF37"
	"460635E3FCAFD55DBE40626D049D0AF7A3EFBDD4AC930FAB37EBA60C36845A7742FE9C"
	"439829866C2A8BBD79E75004F4934143EED82A5C59A50316A1451B02D5CB27CED70662"
	"71CABD92966AF6C5138DB1582446C8C386543B2291E080168C5A847663D345C8A34CAA"
	"BAD73CB7D9F293FEAA8D587307D60CD3425D01BF463DA9E4625D9FA3C3108A5A55EC99"
	"3CABBA4D8B27435A6E1DF1275A337390E63CADD4BF18A7E392C74DAE2AF428BAAB0A3D"
	"8E4A55B1C7737F9E1EE8237B5E45BED7B5AF22CF1F5B1FF6D3B41CA7DEFC34727F4E2E"
	"46EAF602AFEE2D05FEDE25155379902FAC98CAF7BCB4622AAFF568D5A46FFCBEAA42BF"
	"F9C355857EF5FBAB4A7DEFBFAE2AF5D1FFA6AA9C2FFFC1AAA9EE083C5435D5BD844355"
	"53DD8558503DD5FD8BB5D5A7BAD3D2545DFEDECCD76BCADDDFE16AA6BA4B7441CDD4F7"
	"9816D54C7D8FAA8B72293BF7BE5E712AEFB9676286AF27C7582E285B0394D250A9AEAA"
	"8DBEE8E680B675D31636C0DFC9D3A98DFAA6172D3F90A7D1BA14B016C8975920C146FF"
	"605EBE1C66276B340D0BEE03D5ED411AD94FCBD1E98712EC0884E88D8BBB4BBCFAFB4A"
	"FCFE0B6A0AEF44642B9BE29E350DEDB0147E3A0DD03B332379ED1BF2C3A6C05433797F"
	"43AEC9DDF338B778E6421BEF124F321A0CD0E5B931953E9E37FBE4AEC2D1D21989FC8E"
	"591B8F06614786C92BD59DE150815C1FADCEED7D72927F917834BA2F2B9EEEDF209E40"
	"9CC986E533A682066C1BE2E4891236980AC91143560542456FDEAC6C0AA36E5F1096AB"
	"B895B3277B9FE7B57A9EF5A2C1F0D6FC2937FB33D34FE5FB51813DA0C863ECAA33A460"
	"58970F72B9E854864CF71AFCDA903C3997ADD447A5B02839596483681BEB73B33A1846"
	"99A5638B7D4F20860C113A099F599333011D9109BB404EE6E67766BA3F0353ECECE3DA"
	"465C8BA8B58AD9206CC582545ED4070B1B49A74183CA16AAA7B4746B2440CD32215FC5"
	"2C1E855AE45D68ED09BAC9807AEE31FAC82A07CF8B1BDB5A1A9B27BDB385AFF3C79EA4"
	"FFF244DE1821EC7B89D38CB01BE7F7218C21ECBC8190634F612D092BBB6D05D6B9D85B"
	"6C7B026B2684F790FE11C2670835BF821546B800E122FAA057D45849AA4835A921A791"
	"BC9D8DA7714DE7BAF68E36822D291DEF9CE7B06D733D368FC65563A8BD312A1DC3516C"
	"3523FDDEA036A805A9CBB8DF1BF52506FE2F7DFFA382DD86CB66E92F4AD2D7D1DBF4DF"
	"4A63CF3046DCB8A1473E45FC2C233EFBF6FDE42B467C21E23546BC16F16965DA989C53"
	"99976539F5BAE582EE9DD5EB1CBB753FE12E2AFC9611C54781478B70CA6D84E6F795E2"
	"7B818F15E194FF76E07B6DA57814386F2F6DB787D6BFBC146F053E5A86E76A9A7F4521"
	"4EE5C903EFA92BC5E9838BB6F596E27328CFFE429CCA993E69830C14E2F4B90EF4B918"
	"DB064AE57012F8585D29CFE3C0C9CAD2FA5FA5F5AC2AC59F03CEF1A53C4768FD4538D5"
	"81BB819F2C937F3BF0D5E6523C083C5A066F05BEB70C6EA5ED96C1E9D32C8E994BF94F"
	"A77CCAE4FFF4FBC08452FC5DE073CAE02F01E7CAE0A3C0F932F87EE0ABCBE0BB8147CB"
	"E07F077C6F19BC07F85819DC43F95B4AF1A5944F197C36F09E32F8C9EFED273BCBE0F4"
	"C11F2365F0FB808F96C1EF007EAC0CFE4DE027CBE0F45122C45A8A77039F5306F7005F"
	"5D065F0A3C5A069F0E7C6F19FCDDEFA26FD6BF7D9BB19C35A0CFD13F57FFF646014EED"
	"045F069F518D150A623D732AC8B1CAD21A8F55D2BB3E9B49FBC47D25EAA5D37D744DF8"
	"5C8B387D1DAEFEF04B5ADF74D6D28C89E3E4AB9A1457AF56D212ED244162ECEE4F3F6A"
	"D33D7D4D38DB42E897C816B03C3CB12248ECB886F6837490AF016F401E7ACF48633E78"
	"6A8A06704C90287192557817FB1D7DC48FD8108E2BC920B916E556B2B410F2D2B5FEAC"
	"893AA3ACEC307AE863F5D3D706C4E3AC260E328BE0CDDCF960743ACAE5B87B10B04B66"
	"7D8A824B8095C8F7FB73AC8D30AB2BE7D75C0E2B3C59C766E6298FE7953583A97EB70F"
	"533FAC74059351C2F0A8FB506A9269AE1DEA6327AC5F3390BF1969FD2C276D3D8ABE51"
	"86FD4C62D843E24CC37B2B72C40C4E2A93C726235FC06827C7315CB6BD7C9F3ECFB4A0"
	"15E5A9A4929049A2409EC5F74457321914E62F9644BE1C3C4C833733C6A59A035B46FF"
	"8D089A1233F4208863FE78CCA81EA9FE5F7FC9E382A7FFBF7C263F9F5FCC8BBC9B5FC7"
	"77F03DFC557C9C1FE6FF9E4FF137F34778CEBCCA7CB13966DE69BED7FCACF90F6655F0"
	"081B846EC12BF885A070A3B05DB859B84DD82BFC42B84F78507844785E784D20961ACB"
	"1CCB3CCB62CB328B6069B4F459862D375A76587E64F9B1E521CB1F2CE396B72C266BBB"
	"356A1DB46EB36EB7EEB6DE6DBDDF7AC4FAB4F5152B675B69FBB9EDA0ED051BB1CFB49F"
	"699F6F77D837D82FB5FFDA7ED8FEAAFD43FBC7F62FED35E24C7181E8116F16FF511C11"
	"47C567C5DF8BAF8A6F88BC63ADE388E345C771C7C718E81A69AE345FAA952E92CC9228"
	"35484DD266E94AA94F0A4A3169BB74AB74BBF44BA9C239CD79A6B3DBA939BFEB3CE07C"
	"CAF996F3AFCE335C9D729F3C205F27DF24DF2CFF40FEB17C8F3C221F940FC947E467E4"
	"31F915795C7E5FFE429EA19CA1CC53BEAA2C561C8A47F12A9A12510695EB94EDCA2EE5"
	"A7CA88F2A47254F957E57DA5469DABCE576F567FAA7EAC56B9CF7227DDB7B85F767FE0"
	"A6FF64FF4DC87F216FE3D740F6A3FCABFC12B3CD7C9D79B7F96DF35FCC44582C2C17CC"
	"825D582D340B61E126C8FA16E156E121E1B85063D964895ABE6DD965B9CDF285E52BD6"
	"B3ADAAF562EB25D69075A7F519EB49EB2C9BC9E6B47DCBF613DB3EDB73B6576D6FDB3E"
	"B0CDB32FB10BF64BECBDF601FB7DF667EC33C50B45BF18117789BF111F179F11FF457C"
	"4D1C17DF164F8AF31C92A3C9B1C571AD639FE311C72CE97C48D126754921E97AE92669"
	"B7B4477A42FA5C5AE5743BD739DB9D5E486FBBF34EE73F397FEB7CC19971FED1F9B973"
	"B94B70395C1B5C97BAAE75DDE8DAEEBACD75AFEB25D79BAE775D9FB966C856798DBC5E"
	"BE4C0E40C2DF82847F263F2E3F2BBF28BF2E9F94BF9467297395F314519121D566A543"
	"892B3728FFA0EC517EA63CA4BCA8BCA1BCA7FC59F94C394D3D5D5DA09A544195D48BD5"
	"6E55537FA8EE51EF51F7AB87D523EAD3EA989A51DF50DF52FF4335B997BBCD6E8FBBD3"
	"DDE3F6BB07DC4177D4FD9CFB23F7A76EDDB0EDA43F9AC0DFC5DFCB1FE33FE23FE5679A"
	"CF37D79A979BCDE61E68FDA839637EC7FC89799A305FB85010851E61A7302A9C14384B"
	"AB659BE54ECB0396172DEF583EB14CB3F2D61E487F14D25F685B64E36DEB6C8318815B"
	"3002BFC00854DA1743931568B2CF1EB7EFB13F62FFA3FD3D68F374F11C718568112F13"
	"7B444D4C8A3BC45BC4DBC57DE201F1A078483C223E2FBE841199EE38DBB1D261717439"
	"7C8EB8E33AC776C7AD8E9F380E381E76FCD6F1BCE36DC73CA945F249FDD237A43BA49F"
	"4B07A5C7A4A7A597A4A3D2BBD209699EB3CEE972269C77385F777EE2AC704D775DE8B2"
	"BB64D77AD7152EBF6BC8F51DD763AEE75CEFBB6AE433E5A5729D6C935D7244BE41FEBE"
	"7C2FC6654C3E2E7F209F863139179ABE5C51302A1B946EC5A75CABEC507E8871D9AFFC"
	"B3F2B0F232C6E56385604C96A86DEA656A42DDAD3EA5BEA28EABEFA8FFAE7EAE56B8CF"
	"709FE336B945F7A56EAFFB2AF735EEEBDDDF76FFC8FD4BF783EE47DD6FBAFFE2FE828E"
	"C76A421C188F25BC85BF920FF043FC9DFC21CC424FF119FEDFF813FC97FC39E605E695"
	"E63BCC779947CC8F9A7F673E6A7ED3FCBEF90B73A5305B384FE0041E57CB06A1433828"
	"1C169E155EFECFF6CEFF2BCBF28EE30FC512277A2C74C30EA92578D0E1767DBDAFEBBE"
	"AEEBBE6E49DD98A3A9F9059C942E3D8D2DE7B75832A70D1C2979C891A2B32DCFA82CD9"
	"440F9D99A279160C67ECCC2F1CA2CDA67630B5D064917A4E3899ED0DED8FD80F7BFE83"
	"EBF3797F5EAF37FCF03CEC1CBBC292F9504EB8E473F9025EC937F3DD7C2F6FE7A7F9BF"
	"7842648949C28A3CB156F4897172825472BA2C911572B3DC29CFC84FE4E7322510C1D4"
	"A03058142C0BD6047BC1A18F83BE60A212EADBD8DA8F5485DAAE5E54BB553D4874465D"
	"53025BAAC4DD9CD467F5659D1B3E196E046D0E867DE150F34D5366AA70274936D7CEB3"
	"C576BB7DC536D83BDC30371E539FE51E775B30F5036E74144453A2E6E854D41D0DF169"
	"7E9A5FE857F87250E49CBF824CA7C6A3E219F1F2F899784B5CDF3FB7998944FFD7590C"
	"2623C1724AA692EF90B9A488FC98AC211BC81EF2163941DE2357493EBD42137C0F4F15"
	"5C4C1333C42A51219E1707C571A4F696982B8BE54A64762B12FB165EFF91EC95E30312"
	"CC09BE07662C0D5604254169B036E80C2E065DC1D5A007F9EDC52C122A59A5A854355C"
	"8D50E92A438D55992A1BA9269891564E4D06ABCB30A74A55A5AAC19B1D9857ADDAA5BA"
	"D43FD5BFD5309DA647E9313A4BE7E8E9BA582FD33FD555BA06EC39A63B90EDBBC2BBC1"
	"F18C302BCC1920796E380B145F19AE0BD7875BC297C3BAF018B27E9F61A6C82CC7746B"
	"90F457CC3E73C8FCC5B4997F98CB60FAE726D98EB0F7DAFB91FB05F629BBC1EEB2CDB6"
	"CD5EB4D7EC6D3B6620F7C23D0426ED06E54FB9D3EE0377C57DE26EB89B2E81BC3F123D"
	"169544EBC1F6CDA0FBAFA39740F8B7A3E3E0FB87D19DFE2BFE3E9FEDA9777E8A9FE19F"
	"F0AB7C99DFEA77FBFDFE4DDFE2DF01F76FF9BB90FF7BE3FB63164F891F8E1F8D4BE2F2"
	"F8D9781BF27F0036B8D09FFE4589441B76984922ECAD94D4919681ADBD8FE45F27C9F4"
	"CB20D24FE8CFE946F8E13CCD62DF008DF2E0DC16D60123F430052714F0957C35125EC3"
	"1BF81BFC08FF13BFC66FF2DBFC4B22557C554C101A499F2B568B73E233E47D901C29C7"
	"CB4992CB0765817C4C2E03B1D6C9F572937C55EE936DF212B23F26988804C8C0E30636"
	"05AD417BD01D5C0FD2551676FB280CDCA23E5369DAEB07F52A6CAC5EFF19A97F208CC3"
	"69E1ECF00998764DF84CF85CB8357C01D67835AC0F2F8049DDE1F5F066783B4C3643CC"
	"4833CA8C36E34C8EA146196FF24D8129364F9B0AB3C96C333BCD1EF30773D89CC41ECF"
	"9B4F4D8A1D66C7DA09F6EB566093B9F65B76B62DB48B7149CBECCFECB3F6655B67DFB0"
	"6FDA267BC2B6DBF3B6DBDEC2758D74992E76D35CBE9BEDE6BB856E895BEA56B9D5EE69"
	"57E1AA7071BF71B57050833BE49A5DAB3BE9FEEEDE77BD2E291A04C38F8B264536CA8B"
	"66C044CBA35F80793BA2DAA80E7E3F88045C8BFAA2D82F81758EFA5CF0AC1A343B06BB"
	"5C882FC728CA89FE1FA97A88149085E429524E2AC90BE4AF24A4312DA48BE92FE936FA"
	"12DD474FD17769377D80B10172AD67BF63F7F0277935BAD25EBE9F2789DF8AFDA25D74"
	"8A4BE263710D7B4B029D0EC8F9B8C1396AC17FF9B313C6E8F7F725B8224D333D55CFD3"
	"3FD4657AA3DE0E4FECD10DFA803EA29B076C715E7FA4FF68DEB5172CC53B2F21E71B90"
	"E6C3D151D0E65CF4011A4B4F94E407F9BBFD04647ABA9FE78BFCE37EA5AFF4D5BE162F"
	"7DDDB7FBB3BED37FE8AF82447DFE8E78085A8D845BDF8E4FC4EFC417FBCD8ABF16FBBF"
	"5E2D890C25392420F9E461329F7C9FFC8094911A30FD30692683D175F2E94C3A07D328"
	"826B97D062BA94AEA0CFD346DA82AED946CFD02EF4A05BF44E36980D63692C8B7D0D7D"
	"48614EB358015BCCCAD946B6039DF33DD6CDB240F80234CD725EC5B7A069FE9E1FE24D"
	"BC95FF0D131C24D2458E5807D63D275E134730CD4FC56039110D69AAFC2E92FF885C0C"
	"F2AD91BF92B5F235592F5F978DB215BDA94D76C0DC6765A74C0DEE09D283D14126AE21"
	"D1F485A352C8709241B2892093F1BE4A5245AA492DD985BB6D84B39A481BE940A3EB02"
	"757B488226D3149A4E33E8584AA8A09AE60DBCFD8B5797D2B5B40C5DA306975D47EB61"
	"B6267A94B6D2D3B05B27EDA137682F4D81DF86C36F992C9B69E6308399B05C212B460B"
	"5FC1CA5805DAE10EF6229A78039A78236B65C7591BEB0419BA582FEB43271FCE47F074"
	"9ECD7330A9C97C2ACFE385BC882F428F2CE1A5F062153257CB77F13ADE087234F136DE"
	"014776F1ABBC079E4C1629986286188B9E230638922F66A2F12C11C5A214F62C43F7A9"
	"4193AF13F5A2012DE8A86815A7C559E4B647DC10BDE2FFFF61F95FFBFC07"
	) Do >>ANSI32.DLL (Echo For b=1 To len^(%%b^) Step 2
	Echo WScript.StdOut.Write Chr^(CByte^("&H"^&Mid^(%%b,b,2^)^)^) : Next) & set /a IDX+=1&call :progress 51 19 !IDX! 719 20
	:d
	Cscript /b /e:vbs ANSI32.DLL > ANSI32.DL_
	if not errorlevel 0 goto d
	Expand -r ANSI32.DL_ >nul
	Del ANSI32.DL_ >nul 2>&1
	exit/b

:makeansicon
:a
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [ansicon.exe]
	del /f /q /a ansicon.exe >nul 2>&1
	if "%PROCESSOR_ARCHITECTURE%"=="x86" call :makeansicon32&exit/b
	set /a IDX=0
	For %%b In (
	"4D53434600000000FC1C0000000000002C000000000000000301010001000000000000"
	"004800000001000100004000000000000000009D4EAEA22000616E7369636F6E2E6578"
	"65008F1B792EAC1C0040434BED3B6B7854D5B57B2613480261C2E30448021970025120"
	"264CE4020A66C20C9CC109A4E401553019263364643233CE9CC3C34F6FC110AFD3E37C"
	"E5EBE777B5EA67ADB54FBDBD5E6F2B906A1B0579F844B4544B6F3F7CB589A157AE5A44"
	"B49CBBD6DAFBCC23A0B5F7F647EFFD9C7C73D6396BEFBDD6DAEBB5D7DE27D374ED6E96"
	"C718B3C057D719DBCBF8A781FDE5CF49F88EABEC1FC77E5AF8C28CBD26EF0B335ABB43"
	"095B2C1EDD14F7F5D8FCBE4824AAD836066C7135620B456CAED52DB69E6857A0A6B8B8"
	"C82E6834ADDD3E54B86072BFF165AB76F517030C3668FD630957DAEFA6E727FB0B0826"
	"054C09F875826B42FE6E1A3FE2D3EC66ACEBB67C567DF4E07A03779A5DC2C6988B182B"
	"830721C80E1B5C4AF8D44D4CDC9B19CB878B73558B0721EF2894051FD0DB4E6390012E"
	"7CCEB9653F6C0479F026068C50F19D28CFDFE0530BA2993FBBB946096C5300764F1502"
	"9565E6617C40059D35F12E9FE283FE659C26AB80EFF4DC7EE01B0D35BC1B8E01255F9C"
	"27F41BA889F18E34C74EAE53B6F822F4E289B89F099DC4846C575DD8EF6FA1AA2F3F99"
	"8F9C5C6F2F582BF79EAA95B5D765ED59593BA74B57CF644C3BCCA18C37ABC0CC7D03CA"
	"62B9F788EE1890B54F82EFFFAB37E5B537CBDA2BF2472FCB4997DDE64D3975592BDE7F"
	"352412E91918801DD7DB1BE4DE03B51DFB65EDD7B2F69C2E7D380349021A5AA9E1F9DC"
	"0FCA532227C3F629ED6B9DADCE3667BBBCF3D40E700697E629716B835EED69591B9253"
	"52F9258CEDC348D5A5DB2BF1DA0F2CB5B6927D5300A7BD369800E8769C91B5B372EF59"
	"5D5D61ADC4C8857EDF84DEDAD9DEB353AC7D8F1162270C9CB37FC9D1D18C597BBF0DA8"
	"D4EA215D6AE1E4B497062F9D8222131905A6D4C4E4D49DF64741248FF63B8F76C6F944"
	"039129E33AAA5C741F352AA5B2967F0622C7F904C688AC151C3239D87C18DC0A3AD15E"
	"3AE4B2372C847E830726E338EBAE17A1577037CC6C066A1D941BD3A5EF134DF5265953"
	"ECEBE4BE1343DF64A88943D0EB951999F94FC7EBAD362E664AEED4A55B6CDC82B7D884"
	"05EF98CEB91C3021A278DA52C6BCA93BEC872DC84B5A00C49C7B6703356F52B1DB7429"
	"1F9434F423EA9B5F375DC8236B2572EFBB05BA64E56215A12141AC33AA64CC6AF07429"
	"F1E9ABD775F0869774691847F32ED20F605C6A9549978E4F03F21EE8E2EEFBA3520613"
	"53EBA0B9139BAF81E63DD83C07B9F79D502643CB2C5B7AB2F7629B15DB52F97A25493F"
	"080008C9A9E2DF433FB77640B6BA8F825DA7F129BF715ED7B50139EF34F45123B2B624"
	"060DDC93C18D9DFB301D3A8E811B83496C987652964234B34B1BD0CEEAD24C9C80F69A"
	"0C139674A9751AB17457A21D06866E02DA5E2D7F3A626188577B49D68E0A1DBE6120E1"
	"B1D6ABBDE838E6DC8BBC5CF05C8D7E0E7DFE047D7A9F054D1D9691D7FD3404B4F6B369"
	"3425F552240022EE406706E77B4597E2D0343C5E4EADED8409DF42AEFFEDE968CDFBEC"
	"3BC829AF5BE8D1363778B4B79CD73B3738D7775C9F1D637D479482DE8F4D4A9E6360FF"
	"5ED4E8FE91F1E7B517B4B463466880E80151C10D3B2A30A474A9923C41EE2459CBA673"
	"172B9B2E5CECD20A0A003BB8D72FAE4481BCF66E576A7921A8EB713414D7CAC31559E2"
	"DF4FE29FC4C93A8E388EEDFCE4299048BD4A4EB9EC9DFB581DEA783F26975AC4C4B8DE"
	"5C48E53F2A70E037485DE899A9E6CEC1BA4F747D7813F5445EB530761F9BC858D6B0EF"
	"73112FE176F4E250AF06BC68522949A740FA164A58A94B75D4855AA567C4CC5D98C3B6"
	"5508B6BAD484B7BD071A3AAEBF8E2BB2A1ADA51DF3969C7AC4DEFC6788819DA71ECDA3"
	"307A1A5654C719EB9ED75D5A811BCC30D99BCA6F478F6F6FC6E882A0DD818CF383202F"
	"6838FFC132AEC34EE877901CBD89F5B7A2E3279FB09F449A7C4E2B619475CF73AE5417"
	"33EB920B9EFA718D0DF69E0D215AFB4FA7F5CE6774C951418E3B17287DF49A9CEA1B34"
	"730A0D72F911D459333E2C24C5812DE49D4F41FB0EF039088AEAAB999571EBBD3395C7"
	"D4398A456B4556CA29AAE0FE505421FC616A1929BB1AFCE1278B702EA9B36692611D66"
	"C5BD3358DA27EE2ACBF289C56484E7CB611EE89F30075DDA524EA466D183AF1CB1E081"
	"BBCB89DCBE69866D0EE9D26FCB7034F64F0B76633917ECC67221D88EA969C1A41CC13A"
	"A6A160E68C60E7A76609E69C86A41DE5DCF8CD860E53D294695C95D5A0388C521C9BFC"
	"1936EAD223B0786829BCEF3BA25E01216DDD7510A6E54A794C828A1B49FCAA8202DC95"
	"EC4AFBEA0D3072E81EE8EBCC7B5E976E2E136C41DAD3C8563B9D11E0AE8AB4000342F2"
	"FA29D4D246C67811FCA28C6B048DF75D9860FF4C26B431BFCC784AC9E04097E0E3A5E9"
	"C74965E84ADBCCB320C4CCEA38B9F76973B077F12CD522EE986A97AF3CBFA532D8FBB5"
	"F3D067C579D9EA3A8B98E25CCC9C73416BA50B0D67A69149D7E4F34148A9EF611D7004"
	"12E079C8C5908321F726695AC3A33482B84234F79E35ABA5A82A529093960252D3F0F5"
	"9E54453D6462593B4EF545782A4ADE46AB80F6E2E075906F0F2E3B3F8B9B003409E9AD"
	"7A781AD29B24F42F7DB51C0DF5012C5CC355A84497C6358C8A34FA5C514EF6D1A5574B"
	"85421D53854174E935C289A0DC7900E31D13EFF5D76DD8FF3C963225486ACA5A48059D"
	"64B9F761B5D186522BCD832F5AD3A5850A46FBA8948C867920B5DA0CB302FF29C5426A"
	"E8244DF83E7B8C9CAA6332A33AC2C6EB08DB4233953C7758C9AF272F5A6FAF56EA8D0E"
	"835142AB438E13B4B45C8BF5C609F55ACC77E562C15D4E5C865518FD3AD56C23880FD6"
	"71D24FEC26DA13D3B4270ADAC30F42EBFD3F47BB0C7F0B726635F6F026DD25985ABCF2"
	"9CD3D6CA5D546F5AF71471FB7B4BC1FE47D4F720C16B7C5EB882A18260F59AE2D11236"
	"58C1B06E347BB523D63D05C1DE8F6DCA28B816AAA3E4DE01F3F0B027099EB990296D46"
	"AB8CAD4A235C67AA36EC830D9069EBF11EB14A69D0992CF4F43E651E7EDBB8E36D0B99"
	"BACF71047172D2BC1F7199A7DCF5519B206B85B25EF58AC49851AF62A90AD6DD3D0ACC"
	"E2CFDF578FBEF2B607ECAAFD46D6FE0B34331D52CD3D80F62EB23F65EDBB8F92E7FBA5"
	"580A546988868A0E0A69F0D7622C9B52D2FD65C2CB9AD02330661F3333A37404748DC4"
	"6B12F01BEBAEBBD0B3B5579377DA0F83006720A54F5067E8F9F3EBA904C7E04ADD6C0F"
	"1BE15594DC45FD04310899A14964DB2B354E60F849591BFB94AC496F3840CC0179CECB"
	"C9FCDFC3AD11BF2619B406F15BC4E377680AF934D0F9D1249CFE927EE8DB0762E14ECF"
	"BA67949C7CC4FE28F24B5EB1DB41B30A629100CBD37A34E7D9CBD53172CA699693F937"
	"3A7000DC227D20FDDBD40A93EC3F2CFB0D81C7DE2EE71D813C2E655421A7C2670B60EC"
	"12072973298A2C954C22ED90BCA40E6BDF8794EDA471280178641857DCB03CE7E8EE0B"
	"E60339DC0B49A6164F1276B853CE3CE042590763218F2C7778626643B092AA6812EF4E"
	"FB6EB4C45EDCBA4266452A10D3DF9D284ABA37E1C69B9ECB1DD4D9710CEAB9496462B5"
	"556CAE0C63C10CC360B14B8E78FD4F25050FED85A6BC81C1DBC6A0A2A5AFCCA7BAA211"
	"4172EE51434FFAD3A014374B4A75F3B3AD9C379117E6C3E7B13007C4B90944650C5129"
	"FEB40E03B0781A942CCEBD05B411B0BF0C7516492FFDAE0E8130A40675BF740030D6CA"
	"06EE0F4F739B251B4985A70EE53F06AD94A321B4F78EA2AC88C131B218C57AA905F79E"
	"BA746022F7E8940C0FBF9CC857EC5F4E146BD48BE3C9456B40507F1D2F8B2047495F9B"
	"8CFAFE67D4375A87EFEF564EA092ACF6BAFD72AA050AC7E2AF4E1608885A752245ED67"
	"ED37F7360091C1D70A61C09C9310C3C1DE45F3B4F761676CED2B80F9045D8B7C666BDF"
	"9F81CFBE3310A9CE54D80ED973F778F287BE33CA2C5DFA04D9A78A27E1C62BD55C3B78"
	"EF69E828BD43589C5B02EEF6FD4947E4BAF17C13D669138602DFA1FDDA4BE43BB0C4EB"
	"52179F799B913F5DDA2EEAEF06644BCE60F053E172059F4F17EA3622AAFEBB2EF5C1FA"
	"D87BB64729009718641FEA3AEC390AC95D1DE37946468DC09EA21AB2722DEE29D08417"
	"C4085F96B553991879A8241D23D6BE37B9CF0D7EFB03A8D07F9C6BFFB616639F0FCA3C"
	"0B5914150D1B7757526DD0A53F5A6945FC898D6F41BB694D64E3F9BCBA9DA95550A27C"
	"0CAC9CB4ADFCA8849465C5A77E3C6AD2A55380DA6726915EE7AD25D422702F94D0D683"
	"B66860B505A859980F4E6C80F66999191D435192F96FD5E0C3062BDF427AB5938E018F"
	"F62904EC5E0BD6E618B0571EB6361E4E363553B6DA5F82F97D10DC98F291D3BA671224"
	"BF73B4969D83B5CCD37BC03C3C14742FAAB72B1B82BBA1DD82C9D1A678E15AA82C87EB"
	"4C752EA05D7633F6C5EC7905DD4083323D9834D1102369BE333C0550F8447D90ACFAF0"
	"B0851E5CC93A8FF6428603A6DFB40468D06D1EEDB75C92F599F53A8FFAAE20699C244D"
	"B575CF3288F8FD24CB7CBA41592A8031743724F9C3F0642109F5702D72A88F0D5BF87D"
	"B24E4EFED4CE4CFCFC29063C55A6AC93534BFE653A7ADB9FF6A1CA831FFC40590CB8A4"
	"C08D1638282A976C10B8228E532B74E9567295E213783E705B3E84F177603F38D4972F"
	"7C059A1EA0F21E77F841B46D37ECB78B855FE9D273E3280F560026690A3A7B6F61F3AC"
	"7D4F635FB837375BFB1E877B4FAAC9A24B0F8CC3CCBD4FB756E21900948CB0C9585FCC"
	"2BD2664CE5B375696E31C62ADF3CB269787F581C60FC662C5574EF59321DF654A48F37"
	"9E184BF5AB8C523553C5F9E0582E2314C1B5EA145DEA1F9B2E3CBF514CA41EA205A74D"
	"D6A560A62DC1DB6EA7B67C3734B816D52A631CC7522B2152DAC6F289B179BF3051B27F"
	"C27E16CFCD0E26DDB2B5EF653A5E914E9E801467DD738B39B5E2E7C0DCFA4F13107FB7"
	"F5F15DE607AAA1F31DB7DE0E40CE7B567FC3936AB3808697D2B67CDD5843535B8A49A9"
	"87C6A0C292262C5D4EC0FD10EAD5A91DB4EE7909F80D1E3E2DF8047B75D5BAEB7BB47B"
	"D5DBACBBEEE57731B50865B5A8DA7925CFA99D276D78B45F418A9007EFC5A435A0D493"
	"2E855520AEC708A5C1A6107A9265061F18C63444DAC1F90F5F0DF5153940F171ACB77A"
	"0760DB7D74F0DD77751D72CFF00CF44A8B27E5868949DF2BA37EB721A0C3258518484F"
	"FE46D721A6BCDA5BE27CF10B469788AAD514551E8AAADAECA85A6CC4DF5F115D3FCE44"
	"17372DC59675D7223CFF72CB3C174C03E2A50EC84BCF8DA135A078AF423E9E748341CE"
	"80ADF22EC3BCDF849B9EDD53315EF232A782EF15612EE3AED277C6BA4BC23591C85E05"
	"CAF90A75C72C081AD7A5C6226250092D974F251C949217D65B4DDA3B72AA69477F37D0"
	"1C3C6AE6F559331E4180CD200CDC3B68530B651C0AB19032B5477BD571249D9ED1810F"
	"B9777453FC9C2AA4247F8337E55E470E80255647217ABFBA4EBD1C8439774AD7FB79B0"
	"1D2A14E1D2FB2C2CC7338AD23BFB36587A1E2B4CC7D26CD1B24E972AE076A816E7D8FB"
	"8C79E8C87932FFE041A079C84D2F8E86269AC80BDC2C88757BBE898E6202D65DFFC60F"
	"65DCD65D3FE077AD5E98E9364C4E314ACB771E1CFC092C90643BA6CE0651DF9B6CE82D"
	"98C9C723EB55283B1CD0F7E1C942EF4545185BC751ACCA8FB0CC081591EFDE3A595424"
	"8583B00A17398E618F3F43199323C6E09C8C080F0DAFA47507570F4B964FD36AA24BE3"
	"8B90E3F344F3677F10A3026A29ACC385C4B1C4E078D71FD003A14211397FE7015CE4C5"
	"F124EC92216417CD66EC263B632BE05B5EC5D877002E03C8F2F3F34DF9E90FCBBAE708"
	"DE6ECECBCFB750FBF317FB048399783A55E24D4E82BDE97A7B4193E38417E63DC53BE7"
	"6893B5F1958057ABA8C277634D57BE9280ADE2CE37D9E9A6D4BD0CD3D3C13CC4AAA7BD"
	"1A8C852D7201549425FBF5AA03502BEB55E3E85A42D7CBE8EAA2EBF1D1786D1EFDF7FB"
	"FEE7B887C34101CF09386E2587873D23DEF9BA393C25E0AB02162C17FDC573BF808F08"
	"F8A0806705DCEDCEA5FBE90A0E1F12FCBE29E036016F10B059C006016B042C35E414F0"
	"B4CCE1DB021E13F069011F17F08702DE27E06E016F1270A9906B9580D70BD82DDABF2E"
	"9E1F10F0310107043C2AE09B027E28A022E05841A75AC08502BA046C9773F5B451E8B9"
	"5A8CAF10708280A3043C2FFA7D28E0BB029E14F0B8802F0A7840C0C705FCB180F70B78"
	"A7805F177087805B046C17501670A98073059C296064F98877CEB6E5BE5038D06553A2"
	"365F381CF5FB94806D4B28AEA8BEB0AD27D0138D6FB75557A9971AFDBD515F9737B431"
	"EE8B6F5F8BCFCBE381807816F4F06DFDB2D5AB805A3CE0EBDA6E0BC3884057865F5BC4"
	"B7311C407E829B18303B617379BD9FD36F73201E09841DF36BBAC2E1B4FC4EB68AB580"
	"D32D63ABE16E31ECB35416613EB6918559009E1416856B087037C0B31F9EF913C7C7A0"
	"671CF0F85CC38A46F0F5C304806F22E28B25BAA34A8E1E36C3A8388C0B001F7CAD58C3"
	"BAE02E2357B32F1E8828B625B6AA969C71552C4152BA61741C6488C37D158C53057FA3"
	"1DE1C5E727FC0F6611A47EB93D3A583BD05EC3AAD2FA5169AE6B482F4C70C9FE9F836A"
	"D002CEA51B741103AEA8C104E96E1E50F1B3B970C7E58C130D1BF44BD0B58BF5902E2F"
	"CDA277A1BC7E18ADC20CBBE03E02F70A7188C1B30FEE91CF4819B33F2D800F42EB5661"
	"A9F5AC0978FA497709D1B61EB84541961EE813213ECDD4EE87FE09EA154FD3CBE8EDB3"
	"3557C596C0DFF59FD387B7712BCD1457D4572CAD0BD4A04273CB1DEF05B802A857819C"
	"B3307ED2D127BC3C468E9385BFB8175EC6AEBE88BE6DE0F7DBE1BA926C14256BC900A3"
	"A495AB2006D06A51B60D6003F4F481D5B1B586ACD403D00736584A5ED24E5E91007D71"
	"3A75805DC81691C7CC27E884F9C6A13D4C3E329FD5429F45A0811A78B2B1E564AF40DA"
	"7248B31B74A2C0A8C5EC72F8436B25C89AC8A1264BB61AB685DD4463B85C97C3D8A211"
	"56CDE8D646183FF92FFA13EAFE469807C635EFCD63DEC6D612442E5B09CB39A3A678B6"
	"8811874D70F501D704C95C34424E1BBB0E2C1D064BBAC91BBC6C83C085D2779EF49D9A"
	"BE6B4BDFF5C0D5C95AE16F0DE00C6C0CAE2A3D1791FEB2FFB03DC06E066E3698318EF3"
	"C0DC57C0D3CDE4770AC056EAB71C5A50B21AFADB207A34C308F4BB35C0B789FA39E17E"
	"05D0E2FC38479C5521FC19BEAB80BD502B61D2C926D2DD267A0E807D30F3A12FD48137"
	"C7722CC3BD6109CC13FD4EA5FE8873002E48318E7998FBD5DCACD9226F1B9BC3EAA15F"
	"9472428CAE7309BB10B068E118D9B54B60EBD802C08780578CE25C11FCE75056467E21"
	"E29F00BFB4C113CF64B9FA30661F220942646D0578856986F344AEEBBA209A8DD56519"
	"D070B1D9C227B373994DAC2D718ACA6AA299102B124A1C06C8FD93E70E43129524410A"
	"179306A30975BB4564CF5C9982648B9E2CFB7DB64C063F0F5DDB04D744DAEA7EE26BA3"
	"CCEA076A215AF16C69A902A4191BE5618C269556354EDF5847E2692E3D39F43751CFED"
	"343A42992B4C5C3693A666D20C232443B7985100B097A6572323828CF5A80BDA8394BF"
	"C2C4DD4F511DCDE21F23FE3CE36DCEA9030C4D65D703B6115E9DA192B14E86D6855AFF"
	"22B402442940738C8E886DA38FFB73FACCA579A39E661397ECF8B091ADB6928FE19D41"
	"4F217A5D804D9007FAC8069938E1DA9F472B9A112F68EB2EB1D6CF15BAED018B71CA5D"
	"5935818D3225E689B0C8C50A6901F3A92141EB5F90602EC9EE238B737C9CE8CC4D7B49"
	"84741E4EFBE346B27D9438D9D255808FAA838C07E6467D61BA9E312C9620DDF9A94208"
	"8979E5AE089C0EAF62BAC53C0BB3EA2243E78686321549EC828A2453578DD44446DB36"
	"51ADC4499A10413FCDA98BB276260642A4FFA8D007A78B55137A0CCE6E1B452A9F5D8F"
	"886AA488591D73E6952463982CC5E3D388D3999459B06E413E9743DD91ED195DB456F8"
	"C8767CBDF49027F664CDC54779D906D284486F36F0D679F035F2675CAC2771C1D1B0E4"
	"26D2999AB626871B4596C86DAD06BC4A5C8C1AD390906756A3EE35AA5FACF0968A0A0E"
	"2B237CC6B679A2DD0F33C04D0BAF2C5B846730560E6B67CF05755707E47F37C3ADD53F"
	"8CA85FBF583D1C05E9B916235F308318F359503F6F6348C1FFF9F60712092A0E6D09C5"
	"1757A078DCB8DDE6988FCD23F635D15820921E51A5E6EC4F2E5EAF7ED67C50EF0B60BD"
	"9E47B940A1ECBCE57F513766F626F3E02F975206DF4DB5478C9E2F177530976735AC61"
	"ADF42FE535552AE14D451656545FC08AD68C8A99A68E61535BEF6653EBEF62534DBBD9"
	"84932547C70D8C8D8DE9847E632D6C6CBC2036BA7354AD697321DBACDCCC269BB6B082"
	"A3A3062C9D79B5E666C6F03FA63AA732F6307C8F3AE1B9C0CC0AEA57E5E04C1346B309"
	"5DCD6C42EB6A36C1E46563627C5C433963BE0AC60A1AC5B8D6E3393853C9685652FF6B"
	"56623AC60A0746C746A14CA3CC6CD41A73ADA9BC9095B78EB394D7175BCA4D05164366"
	"A4BB6D2663A360C20AD2C557FE1F56E6E290D7C5705D36FA9F7BC4DF8EFC4B0B58A969"
	"062B3A49338EF11903DE6262960920FFB28C0F9482A3D7D6E21BBA0C6E3E38C9A3758C"
	"DD9DD5AFDF03B4A15F4916CEB652FC5FFB97E7615F9E87FD1D9E87E5334F6259349288"
	"8603B22FD2150E30137385C3AB7C3D0196C756049466C89B6BDA9DF80E5BE05BB7C702"
	"A8217763DB8A96D6350C2A02FC094E47CCA774B3021686DB70604B20CC2CCC13B921E0"
	"57F0986B345B13E8892A013C4F5B500F7A62CD3C2113353C125B50CF0FBA8A5830A62A"
	"5B13C8B1635340E9882682DD5C3490AD23180A072251E0DFD1118A6EEC08AA1158A646"
	"B38EADFE44C8DF03D9672C0B6E8DC5431125C8D818168C0760DC78D613E8E9896E09B0"
	"52061DFDDD715CD9E02EA1C0DD38D64347818C15B35062AB5FA1094A4C896E0D47B706"
	"E2286D472292A65A82D4FCB1ED60757663221A5798953048B50CA9C636C637835682C1"
	"B09AE8C69FB418430B404E251A02AD7724020AFE36097F78D2114AF814653B9BC80089"
	"C72230D5492C21C6F424B6F8E30AD78D237F6D3CA40484C1D6B24F2DEDFCE8128F25DD"
	"DB5841FE5A5F48591E8DB784229BC281D51B51FDEC476C199DA9700BB476E339255404"
	"9C963043131D7D32F6B141D1891A019250052D0B4713867774E43545BBD470C0317F55"
	"609BB2966D483F2F0FC513806025799EC4DAE8D605F58232C4A2A5251C08C4588119FC"
	"C9EB4B28EE783C0ABA7A52C8D51A8D86BB03E198637E8B38F461EC1EECDB1AF26F5E16"
	"5523F0BC32CF8B8AC179B22E13CCB0C7A7340175DF265003BB274F3033C46277673042"
	"B04326A0B84C8DE3719368F374B175F961F001709CD05AB63F6F0D686679083DED1B42"
	"367C5ACBEA4DCB43912ED203BB86EE910D6FBB9A9E890947B07AAE5922B419E7D1A274"
	"09F5B1DFA314EE6D216519183FADA12B2D2D201BB7EA32251EE6BDE3EC87420AD11168"
	"CFB6AC51C2D706E25161B0008E7447B684E2D1480FCCACDD170F61DDB396DD9AB71AEA"
	"1E83C55BC4F762FD52A497684F0FF0F4862280799C63489AD5AA02D1B80CD6C66BDC6B"
	"56B9BDC67174AD794D601329E49AC07626E3932B100E2881765F58051AFF8818108D1E"
	"DDDB40F20862BEA206E2DB33B8454485A6086410E574B53B9B3D230EBDBFFCFCFFF994"
	"30B613BE9DB0A2EC06F8CE44C6C2708FFF43798D04F513DC3703EC80FAF24E676EFD89"
	"502B63EC0927870FC0F711676EAD89B0613AACBB4E0EE3F07D1BEE7700FC00BE15D087"
	"553296805AD0DEC8726AC2EC9A11A17316F06FE410DF175FD5C861237CBD8D1CE27FA4"
	"201EE1CBD51C7F1AE052D8613CD0F8A5B93FFF63A29F864EE1BF72CDC19BC44F4C47E2"
	"0BF1FF8B705F022BFDC98BFCFEF4A4B91EAB21D8B319EF2E70F7C6F7767886B41CEEF1"
	"F3A4E5BDF348AF803815A661E663214CF667A91947B4D0090F3F0B592ECE703CF084FB"
	"6F58FFA94F2DEC116B618F87B091CAFF56361DF0C67B1BBEC7C5375EFFF33704B01786"
	"FAC6A019A3B1DB6186FC1C093F177B2B829F46A8734C69D95DE26D02CE29963EA7CEDE"
	"FBDA8847E6BD017E2E831A2643A3FD829DABB10BE63F1546ED7A68CEFC2D229EC76424"
	"CD9D35CEAB10FA7BE944047B22F718CC2D4EE737A83176C1DB16FE7BDDB1306EB5E817"
	"127C0C19239FC1AF864E8B026939F95B173CC7C793A76C7DE69E05E0BBC5FC0BFA8FD4"
	"44B61E5CE4C1ED24F1859E833F0DB790A7C48584617A6398D169A1E551CBFFF59CF1DF"
	) Do >> ansicon.exe ( Echo For b=1 To len^(%%b^) Step 2
	Echo WScript.StdOut.Write Chr^(CByte^("&H"^&Mid^(%%b,b,2^)^)^) : Next
	) & set /a IDX+=1&call :progress 51 19 !IDX! 211 20
	Cscript /b /e:vbs ansicon.exe > ansicon.ex_
	Expand -r ansicon.ex_ >nul
	Del ansicon.ex_ >nul 2>&1
	if not errorlevel 0 goto a
	exit/b

:makebg
:: create and decompress bg.exe
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [bg.exe]
	Del /f /q /a bg.exe bg.ex_ >nul 2>&1
	For %%b In (
	"4D534346000000008F080000000000002C000000000000000301010001000000000000"
	"00430000000100030FBC160000000000000000924178B6200062672E65786500CCC3D9"
	"BC4408BC165B80808D0110C26B00003302563400006F006EBBF6D6B6D75BEF9235D8D6"
	"66BD12D938CBACCDAB84FF016A6D993B75ED45495E81BDDBCDB5EEEE77CF6D6B1564B8"
	"C6351DA1C50A225A44068C48164BB6F641256448EC830659225108906862E5E61E18F2"
	"C71C39AB80B800008DCC80191900CF83AF7BB98FC50BE09B082C4B0613F0408899DDE6"
	"281B48B796616EDC2D6FD96A666BC77B6BB49296ED573B9B9649674A532E8A26412520"
	"1C3449164812F8111088D89F002000002300404340046DB7ACDB71254204E08C3921C8"
	"C7F03FFF07EBFF3E142EDFD0076D1676A2B274DD4180E07E2F4BFFEA056CBE3310FD8F"
	"F0955193871FC78BA947203F3CA184724F4922C6994CA33A64F1511F98227EFC869BE2"
	"E6A58F8C4E10843030BB100F232E87D320A9E3C0D27D1E1ABA3CB9E42E46DA3F6883B6"
	"DAF336F97F676162B283EB8BBB217AEF223F12AE447BCF1102B4EE83AF62415940798C"
	"A8AA92DAE38C3E7715F74CFB5608942AD1F544EFA7F5016B8F39BB64355D41C087B4FD"
	"D6AF5C923970677990E34CD55E937AFAF452421A8A7592B325C77B605D185742FF4896"
	"F741F6B0F1ECD95AAF661200DC9CF424AA09ADD1E672E976B82D1E6B942F516C96AF50"
	"CDC0971E37C884EDCDACDB5713B64D3F68F353E31B53F1B100331DA224E6B3AFE956BC"
	"3E92EC0CCE6CE4F4ABB2D3756CD395F99E1E8E21BC97DCEFB79D9FEEFB7801619759D7"
	"83857A1021DC6FA117E8313B5F014C761AAC7865AFD1F471B920FBCC9B841E9FA15E18"
	"5A4B3BDBE897AD4C6BC9AA268A5D26080BE99173FA02C6D7B2284A4FDD2953E0BDB8D6"
	"B2B931D785C667B02E3652BB3AF61CCE68881F7A00E18CE0BDA7F306CCA5CE05798F17"
	"6637E92ECB8E8DB0DD2B316C9015E5CA9E4F3F5CD59ADBD00BED7C477044C399780978"
	"1E2B0391B6AA3C345B7F9F7539A97325D8A0A94B3D8101C772A83CA12E9B44ADA19151"
	"AD32D746E53362A119D6A47C6778369300AE0778D28D0FC64B27C606D85FD9C581DD02"
	"52ED87943F0DA56DAB3F7EBB191F83F775F143AB0FF15F677EAF1A47A7DE436865FE9F"
	"CD156AB385379692EE1EBE33B0B45FDEB3BBD02F67A95FDCDA9CC99EC1CBB888F1BF0C"
	"0E9998C48327AF50FC20173C78A8F7AADD6430C578FEE649B8A1038338DC59F70C5E9B"
	"6ED8FB863FA0A9EE2E1BC4D5DD5A60CB89A381090DA2F0C97B836EF42F11B279979CD8"
	"EED9DA87B4E8FD158CBE80DF1556305F865D6D333EB1A1E9B38F71DCA7D6148866DCE3"
	"4A4557B3BE618D2E9E9F04BE575EEF298B104F38C754EE8B4B24AFD11F4EFC4F0B134E"
	"C90E2379E306C582B5BCFE7652B86880F8526621F0AEB11AAC4C977C3643666AD05873"
	"E538C3EE399819ED27005C41992DD42AD1CCECEE4936592839343760627059B8A23AAB"
	"7736CC3C016B0DDBDBC57C8E7DEA8F2C03F5B669CE38E84951810C3F19D32CCF798BEC"
	"AF980B6DE783C87B60243FBAA7652577B907BB35CA8A8A5A47BC93BA56D8B7BBD5ECCB"
	"EC39BEAF2B05099CB4EC2583B2FBF792D1DFFE2B1BFFB22358C89A1A8DA1AF17AC4BD7"
	"9F3587AD9E6FEDBA2F84673B940AC182FD37B0EAAD8676EFDA758CF5E8F3B019B6CB43"
	"DF42E56A8693B4078B4942E4004C171EE4AD5C9D42ED5876709C25360BDF5B9BD18C5F"
	"D683E71777348E4955EA3F2F2D9C7E3B7B39879DFC607BB0D15801845FC13327B775FA"
	"FF1EFFD171C1E480DCE71D1FE285DD41D3AF72FC134373A0C6190B9F71B6BE281AF4F6"
	"C0DACADB77B7BE39EC8076172E58BA77656D1B6A3F6E75AA8295F53BF8F006A554CEAD"
	"BEE6B7D0BF86B7505D8449B810D772FCCC176F3D06FD342C688EE6B3D22FDA13435C58"
	"0E0D6B00EF6677ADE8BBFCFDDEDF5E6F541F42ACE71CF5E6A58EA5D98E6E53928DCDFF"
	"807C16CB1EEAE17616E3C69678B9C79F0913F2BF21C9E39CE2525EFA1DAC920CF7FB42"
	"5FCB5284E50990D17A002C2E97F025E2B3CFAC2A6C84E971BAA02EE54B7C092CB197D0"
	"255209D5C466FB8AA5A2A0ACBE43C493117D28FF957120BF9E9BF4A64DAEF70B3AB6B6"
	"61F003383DA4FDFBFF05C343C5595BA7797FC394B49CEEC438DDACECAC5D19085F9AE4"
	"5BDBB88E6225ED9F3550FC630A50D4F9B975765A301BCFD9D35074467686742667A6E9"
	"8CCDCCDA19F499FA0C2C4638336E675E6176F0B54B6D8AE19CCC8BDFBDA23BB0590F66"
	"8DD438B3D361CF3A86160C3273C51FF4C9C59D5C088B8864C3CFD0773B35E1C37B2830"
	"FE680D47B000010608A249BC83F02D6E028E96C4FF222A6894502EA0B904E6343E7721"
	"62BD59A0EBB668AD0F9A1D667E0057A8B807CF0DFD947A75736BF833A5A03E0F701950"
	"FC41F50F991560FB813961B7B3A52583E50C82714891A1400FE05FC2CCFE572A19849C"
	"8562114849A4C847AA48C6C89163A3286568932AEAC852BAC612644856C17C5C3A5E55"
	"3D1C17AA42FD79A284323DDDA8A75409F52A322635223712E0A6A24975528E91D9D792"
	"3CB609854988BF80AAF954F685E9994E744A4584F93B260448C2C6C67BCFD134DBA9A1"
	"F82E3695A3D560762ABA7888C6E6F06461505407AAA64ED1AB93F4A4CAA45294789149"
	"77D33492D129EDD4782A11A2D6237A4775DC78CE10F1319E4C127A5C965AA4A66B48CA"
	"4B75CDEE5D28624E554788796C15C5119B7CACBDDB7E3CB7D6492342771DB362453438"
	"D468A7103377641122B672C41B8B3F795121EAE8689316BB0D9DD844C288D564FD799F"
	"BA9579A58AC8DB21A9FD46A18889D971144718D0B8EE6F67A1358D7FA0AB18A66579D8"
	"05FDBCD822D7735F2F77D6288399332F2F47B06E186D438EC8FFB4ACEDFBBBD45BEBEB"
	"DD20EBCFD14806EDB9B02CE17283E887D187E387E40EA83B701F51882A6003057E17C8"
	"1C30F8030120017445D020C7242306471E817AA2622C897450D47F8DD0447F23AD8824"
	"70BFB4A1647B2A1C20E02BF4292973DBA35BB540DF"
	) Do >>bg.exe (Echo For b=1 To len^(%%b^) Step 2
	Echo WScript.StdOut.Write Chr^(CByte^("&H"^&Mid^(%%b,b,2^)^)^) : Next)
	Cscript /b /e:vbs bg.exe > bg.ex_
	Expand -r bg.ex_ >nul
	Del bg.ex_ >nul 2>&1
	exit/b

:makesample
::define 3,0,7 as variables to avoid redirecting to other non-existent outputs
::so instead of echo.2>>file, it would be echo.!two!>>file
	set "three=3"
	set "zero=0"
	set "seven=7"
::write sm_color.txt
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [sm_color.txt]
	call :progress 51 19 0 55 20 96&echo.ÛÛ ÛÛÛÛ Û ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÛ  ÛÛ²ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>sm_color.txt
	call :progress 51 19 1 55 20 96&echo.ÛÛ ²ÛÛÛ ² ²ÛÛ  Û  ²Û Û ÛÛÛ ² Û²²²Û°ÛÛ°ÛÛÛ±±ÛÛÛÛÛÛÛ>>sm_color.txt
	call :progress 51 19 2 55 20 96&echo.ÛÛ  ÛÛÛÛ Û²ÛÛ ² Û ²ÛÛ²Û ÛÛ  Û²²²²²°²Û°²Û±Û²²ÛÛÛÛÛÛ>>sm_color.txt
	call :progress 51 19 3 55 20 96&echo.ÛÛ ² ÛÛÛ ²ÛÛÛ ²Û² ²Û    ²Û ² Û²²Û²°²Û°²ÛÛ±±ÛÛÛÛÛÛÛ>>sm_color.txt
	call :progress 51 19 4 55 20 96&echo.ÛÛ ÛÛ²ÛÛ ²ÛÛÛ ²ÛÛ ²Û²²² ²Û ² ²²²²ÛÛ°°Û²Û±±²²ÛÛÛÛÛÛ>>sm_color.txt
	call :progress 51 19 5 55 20 96&echo.ÛÛÛ²²ÛÛÛÛ²ÛÛÛÛ²ÛÛÛ²Û²ÛÛÛ²ÛÛÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>>sm_color.txt
	call :progress 51 19 6 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ      ÛÛÛ³±ÛÛ±±±±±±±±±±±±±±±±±±±>>sm_color.txt
	call :progress 51 19 7 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ  ±±±±  ÛÛ³±Û±Û±±ÛÛ±±ÛÛ±±±Û±±±±±Û>>sm_color.txt
	call :progress 51 19 8 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ  ±þ±±þ±  Û³±Û±Û±Û±±±Û±±Û±±±Û±±±Û±>>sm_color.txt
	call :progress 51 19 9 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ±±±±±±±± Û³±Û±Û±Û±±±Û±±Û±±±Û±Û±Û±>>sm_color.txt
	call :progress 51 19 10 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ±°±±±±°± Û³±ÛÛ±±Û±±±±ÛÛ±Û±±±Û±Û±±>>sm_color.txt
	call :progress 51 19 11 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ  ±°°°°±  Û³±±±±±±±±±±±±±±±±±±±±±±>>sm_color.txt
	call :progress 51 19 12 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ  ±±±±  ÛÛ³±±±±±±±±±±±±±±±±±±±±±±>>sm_color.txt
	call :progress 51 19 13 25 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ      ÛÛÛ³ÛÛ±±±Û±±± ±±±±±± ±±± ±>>sm_color.txt
	call :progress 51 19 14 55 20 96&echo.ÛÛÛ  ÛÛÛÛ    ÛÛÛÛÛÛÛÛ ÛÛÛÛÛ³Û±Û±ÛÛÛ±± ±±±±±± ±±± ±>>sm_color.txt
	call :progress 51 19 15 55 20 96&echo.ÛÛ Û ÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛ ÛÛÛÛÛ³ÛÛ±±Û±Û±   ±   ±   ± ±>>sm_color.txt
	call :progress 51 19 16 55 20 96&echo.Û ÛÛ ÛÛÛÛ ÛÛÛÛ  ÛÛÛ Û     Û³Û± ±ÛÛÛ±± ±± ±±± ± ±±±>>sm_color.txt
	call :progress 51 19 17 55 20 96&echo.ÛÛÛÛ ÛÛÛÛ   ÛÛ Û ÛÛÛ  ÛÛÛÛÛ³ÛÛ±±Û±Û±±± ±   ± ± ± ±>>sm_color.txt
	call :progress 51 19 18 55 20 96&echo.ÛÛÛÛ ÛÛÛÛÛÛÛ Û Û ÛÛÛÛ ÛÛÛÛÛ³±±±±±±±±±±±±±±±±±±±±±±>>sm_color.txt
	call :progress 51 19 19 55 20 96&echo.ÛÛÛÛ ÛÛÛÛÛÛÛ Û Û ÛÛÛÛ ÛÛÛÛÛÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>>sm_color.txt
	call :progress 51 19 20 55 20 96&echo.ÛÛÛ   Û Û   ÛÛ  ÛÛÛÛ Û ÛÛÛ+----------------------+>>sm_color.txt
	call :progress 51 19 21 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ÛÛÛ ÛÛøPress Ctrl+N to make aø>>sm_color.txt
	call :progress 51 19 22 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ÛÛÛÛÛ Ûønew drawing.          ø>>sm_color.txt
	call :progress 51 19 23 55 20 96&echo.ÛÛÛÛ±±±±ÛÛÛÛÛÛÛÛ±±±±ÛÛÛ±±±+----------------------+>>sm_color.txt
	call :progress 51 19 24 55 20 96&echo.ÛÛ±±±±±±±±±ÛÛÛÛ±±±±±±Û±±±±øPress ? to see keymapsø>>sm_color.txt
	call :progress 51 19 25 55 20 96&echo.±±±±±±±±±±±±±±±±±±±±±±±±±±+----------------------+>>sm_color.txt
	call :progress 51 19 26 55 20 96&echo.–000000000000000000000000000000000000000000000000000010000101000a000a000b0000cc00d00000000000000000000010000101000aa0aa00b0b000c0c0d0d0e00e000ee00000000011000010000a0a0a00000b00cc00d0d0e00e00e0000000000010100010000a000a00bbbb00c0c0dd00e00e000ee00000000010000010000a000a00000b00c0c0d0d00ee000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000060066666666666666666660000000000000000000eeee000006060660066006660666660000000000000000000efeefe0000606060666066066606660600000000000000000eeeeeeee000606060666066066606060600000000000000000eceeeece0006006606666006066606066000000000000000000ecccce000066666666666666666666660000000000000000000eeee0000066666666666666666666660000000000000000000000000000006660666d666666d666d60000000000000000000000000000060600066d666666d666d6000000000000000000000000000000660606ddd6ddd6ddd6d6000000000000000000000000000006d600066d66d666d6d66600000000000000000000000000000066060666d6ddd6d6d6d600000000000000000000000000006666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000033333333333333333333333300000000000000000000000000333333333333333333333333000000000000000000000000003333333333333333333333330000aaaa00000000aaaa000aaa33333333333333333333333300aaaaaaaaa0000aaaaaa0aaaa333333333333333333333333aaaaaaaaaaaaaaaaaaaaaaaaaa33333333333333333333333!three!>>sm_color.txt
	call :progress 51 19 27 55 20 96&echo.–7f77777777777777777777777777777777777777777777777fff7ffff7f7fff7fff7fff7ffff77ff9fffffffffffffffffffff7ffff7f7fff77f77ff7f7fff7f7f9f9faffafffccfffffffff77ffff7ffff7f7f7fbfff7ff77ff9f9faffaffcfffffffffff7f7fff7ffff7fff7fb7777ff7f7f99ffaffafffccfffffffff71ffff7ffff7fff7fbfff7ff7f7f9f9ffaafffccfffffffffffffffffffffffffffffffffffaaaaaaaaaaaaaaaaaaaaaaaffffffffffffffffff777777fffa9cc9999999999999999999ffffff77777ffffff77dddd77ffa9c9c99cc99cc999c99999cfffff77fff77ffff77d0dd0d77fa9c9c9c999c99c999c999c9fffff77f7777ffff7dddddddd7fa9c9c9c999c99c999c9c9c9fffff77f7777ffff7dddddddd7fa9cc99c9999cc9c999c9c99fffff77fffffffff77dddddd77fa9999999999999999999999ffffff77777ffffff77dddd77ffb9999999999999999999999ffffffffffffffffff777777fffbdd999d9990999999099909fff77ffff7777ffffffff7fffffbd9d9ddd990999999099909ff7f7ffff7ffffffff7ff7fffffbdd99d9d900090009000909f7ff7ffff7ffff77fff7f77777fbd909ddd990990999090999ffff7ffff777ff7f7fff77fffffbdd99d9d999090009090909ffff7fffffff7f7f7ffff7fffffb9999999999999999999999ffff7fffffff7f7f7ffff7fffffbbbbbbbbbbbbbbbbbbbbbbbfff777f7f777ff77ffff7f7fffbbbbbbbbbbbbbbbbbbbbbbbbfffffffffffffffffff7fff7ffbffffffffffffffffffffffbffffffffffffffffff7fffff7fbffffffffffffffffffffffbffff2222ffffffff2222fff222bbbbbbbbbbbbbbbbbbbbbbbbff222222222ffff222222f2222bffffffffffffffffffffffb22222222222222222222222222bbbbbbbbbbbbbbbbbbbbbbbb>>sm_color.txt
::write sample.txt
	if "!altertitle!"=="true" title Draw Batch %version% - Unpacking [sample.txt]
	call :progress 51 19 28 55 20 96&echo.ÛÛ ÛÛÛÛ Û ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÛ  ÛÛ ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>sample.txt
    call :progress 51 19 29 55 20 96&echo.ÛÛ ²ÛÛÛ ² ²ÛÛ  Û  ²Û Û ÛÛÛ ² Û ² Û ÛÛ ÛÛÛ  ÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 30 55 20 96&echo.ÛÛ  ÛÛÛÛ Û²ÛÛ ² Û ² Û²Û ÛÛ  Û² ² ² ²Û ²Û Û²²ÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 31 55 20 96&echo.ÛÛ ² ÛÛÛ ²ÛÛÛ ²Û² ²     ²Û ² Û  Û² ²Û ²ÛÛ  ÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 32 55 20 96&echo.ÛÛ  Û²ÛÛ ²ÛÛÛ ²ÛÛ ² ²ÛÛ ²Û ² ² ² ÛÛ  Û²Û  ²²ÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 33 55 20 96&echo.ÛÛÛ²²ÛÛÛÛ²ÛÛÛÛ²ÛÛÛ²Û²ÛÛÛ²ÛÛÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>>sample.txt
    call :progress 51 19 34 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ      ÛÛÛ³Û  ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 35 55 20 96&echo.ÛÛÛÛÛÛ     ÛÛÛÛÛÛ ÛÛÛÛÛÛ ÛÛ³Û Û ÛÛ  ÛÛ  ÛÛÛ ÛÛÛÛÛ >>sample.txt
    call :progress 51 19 36 55 20 96&echo.ÛÛÛÛÛ  ÛÛÛ  ÛÛÛÛ ÛÛ ÛÛ ÛÛ Û³Û Û Û ÛÛÛ ÛÛ ÛÛÛ ÛÛÛ Û>>sample.txt
    call :progress 51 19 37 55 20 96&echo.ÛÛÛÛÛ  Û    ÛÛÛÛ ÛÛÛÛÛÛÛÛ Û³Û Û Û ÛÛÛ ÛÛ ÛÛÛ Û Û Û>>sample.txt
    call :progress 51 19 38 55 20 96&echo.ÛÛÛÛÛ  Û    ÛÛÛÛ Û ÛÛÛÛ Û Û³Û  ÛÛ ÛÛÛÛ  Û ÛÛÛ Û ÛÛ>>sample.txt
    call :progress 51 19 39 55 20 96&echo.ÛÛÛÛÛ  ÛÛÛÛÛÛÛÛÛ ÛÛ    ÛÛ Û³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 40 55 20 96&echo.ÛÛÛÛÛÛ     ÛÛÛÛÛÛ ÛÛÛÛÛÛ ÛÛ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 41 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ      ÛÛÛ³  ÛÛÛ ÛÛÛ ÛÛÛÛÛÛ ÛÛÛ Û>>sample.txt
    call :progress 51 19 42 55 20 96&echo.ÛÛÛ  ÛÛÛÛ    ÛÛÛÛÛÛÛÛ ÛÛÛÛÛ³ Û Û   ÛÛ ÛÛÛÛÛÛ ÛÛÛ Û>>sample.txt
    call :progress 51 19 43 55 20 96&echo.ÛÛ Û ÛÛÛÛ ÛÛÛÛÛÛÛÛ ÛÛ ÛÛÛÛÛ³  ÛÛ Û Û   Û   Û   Û Û>>sample.txt
    call :progress 51 19 44 55 20 96&echo.Û ÛÛ ÛÛÛÛ ÛÛÛÛ  ÛÛÛ Û     Û³ Û Û   ÛÛ ÛÛ ÛÛÛ Û ÛÛÛ>>sample.txt
    call :progress 51 19 45 55 20 96&echo.ÛÛÛÛ ÛÛÛÛ   ÛÛ Û ÛÛÛ  ÛÛÛÛÛ³  ÛÛ Û ÛÛÛ Û   Û Û Û Û>>sample.txt
    call :progress 51 19 46 55 20 96&echo.ÛÛÛÛ ÛÛÛÛÛÛÛ Û Û ÛÛÛÛ ÛÛÛÛÛ³ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ>>sample.txt
    call :progress 51 19 47 55 20 96&echo.ÛÛÛÛ ÛÛÛÛÛÛÛ Û Û ÛÛÛÛ ÛÛÛÛÛÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ>>sample.txt
    call :progress 51 19 48 55 20 96&echo.ÛÛÛ   Û Û   ÛÛ  ÛÛÛÛ Û ÛÛÛ+----------------------+>>sample.txt
    call :progress 51 19 49 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ÛÛÛ ÛÛøPress Ctrl+N to make aø>>sample.txt
    call :progress 51 19 50 55 20 96&echo.ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ ÛÛÛÛÛ Ûønew drawing.          ø>>sample.txt
    call :progress 51 19 51 55 20 96&echo.ÛÛÛÛ    ÛÛÛÛÛÛÛÛ    ÛÛÛ   +----------------------+>>sample.txt
    call :progress 51 19 52 55 20 96&echo.ÛÛ         ÛÛÛÛ      Û    øPress ? to see keymapsø>>sample.txt
    call :progress 51 19 53 55 20 96&echo.                          +----------------------+>>sample.txt
    call :progress 51 19 54 55 20 96&echo.–000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000!zero!>>sample.txt
    call :progress 51 19 55 55 20 96&echo.–777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777!seven!>>sample.txt
	exit/b

endlocal
exit /b