# wxMathPlot Sample3 CMakeLists.txt
#
# Author: Davide Rondini
# Maintainer: Lars Easior
# Last Update: 2022-04-15
# License: wxWindows license

# Set CMake flags to enable compatibility both with 2.4 and 2.6
cmake_minimum_required(VERSION 2.4)
if(COMMAND cmake_policy)
      cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

SET(wxWidgets_USE_LIBS base core)
find_package(wxWidgets)
if(wxWidgets_FOUND)
    include(${wxWidgets_USE_FILE})
	include_directories(../..)
	
	if (MATHPLOT_UNICODE AND NOT UNIX)
			set_source_files_properties(mp3.cpp PROPERTIES COMPILE_FLAGS "/DUNICODE /D_UNICODE" )
	endif(MATHPLOT_UNICODE AND NOT UNIX)
	
	add_executable(mpSample3 mp3.cpp)
	# Under Windows, the target type must be WINDOWS, not CONSOLE
	if(WIN32 AND MSVC)
		set_target_properties(mpSample3 PROPERTIES LINK_FLAGS "/SUBSYSTEM:WINDOWS")
	endif(WIN32 AND MSVC)
	# Linux cross compiling to x86 from x86_64 distribution
	if(LINUX_64_32_CROSSCOMPILE)
		set_source_files_properties(mp3.cpp PROPERTIES COMPILE_FLAGS "-m32 -DwxSIZE_T_IS_UINT")
		set_target_properties(mpSample3 PROPERTIES LINK_FLAGS "-m32")
	endif(LINUX_64_32_CROSSCOMPILE)
	target_link_libraries(mpSample3 mathplot ${wxWidgets_LIBRARIES})
endif(wxWidgets_FOUND)
