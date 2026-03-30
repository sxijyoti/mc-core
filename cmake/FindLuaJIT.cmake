#
#	CMake Find LuaJIT by Parra Studios
#	CMake script to find LuaJIT runtime.
#
#	Copyright (C) 2016 - 2026 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

# Find the LuaJIT header files and libraries
#
#  LUAJIT_INCLUDE_DIR		- where to find lua.h, lualib.h, lauxlib.h
#  LUAJIT_INCLUDE_DIRS		- same as above (for compatibility)
#  LUAJIT_LIBRARY			- List of libraries when using LuaJIT
#  LUAJIT_LIBRARIES		  - same as above (for compatibility)
#  LUAJIT_FOUND			  - True if LuaJIT found
#  LUAJIT_VERSION_STRING	 - The version of LuaJIT library found (x.y.z)
#  LUAJIT_VERSION_MAJOR	  - The major version of LuaJIT library
#  LUAJIT_VERSION_MINOR	  - The minor version of LuaJIT library
#  LUAJIT_VERSION_PATCH	  - The patch version of LuaJIT library (for 2.0.x+)

include(FindPackageHandleStandardArgs)

# Prevent verbosity if already included
if(LUAJIT_FOUND)
	set(LUAJIT_FIND_QUIETLY TRUE)
endif()

# LuaJIT search paths
set(LUAJIT_PATHS
	${LUAJIT_ROOT}
	$ENV{LUAJIT_ROOT}
	~/Library/Frameworks
	/Library/Frameworks
	/usr/local
	/usr
	/sw						# Fink
	/opt/local				# DarwinPorts
	/opt/csw				# Blastwave
	/opt
	/usr/freeware
)

# LuaJIT headers
set(LUAJIT_HEADERS lua.h lualib.h lauxlib.h)

# LuaJIT include suffix paths
set(LUAJIT_INCLUDE_SUFFIX_PATHS include include/luajit include/luajit-2.0 include/luajit-2.1)

# Find LuaJIT include path
find_path(LUAJIT_INCLUDE_DIR ${LUAJIT_HEADERS}
	PATHS ${LUAJIT_PATHS}
	PATH_SUFFIXES ${LUAJIT_INCLUDE_SUFFIX_PATHS}
	DOC "LuaJIT Headers"
)

# LuaJIT library names (try luajit first, then fallback to lua)
set(LUAJIT_LIBRARY_NAMES luajit luajit-5.1 lua)

# Find LuaJIT base library
find_library(LUAJIT_LIBRARY
	NAMES ${LUAJIT_LIBRARY_NAMES}
	PATHS ${LUAJIT_PATHS}
	PATH_SUFFIXES lib lib64
	DOC "LuaJIT Library"
)

set(LUAJIT_LIBRARIES ${LUAJIT_LIBRARY})

# Try to load using PkgConfig as fallback
if(NOT LUAJIT_LIBRARY OR NOT LUAJIT_INCLUDE_DIR)
	find_package(PkgConfig QUIET)
	pkg_check_modules(PC_LUAJIT QUIET luajit)

	# Find include path
	find_path(LUAJIT_INCLUDE_DIR lua.h
		HINTS ${PC_LUAJIT_INCLUDEDIR} ${PC_LUAJIT_INCLUDE_DIRS}
		PATH_SUFFIXES ${LUAJIT_INCLUDE_SUFFIX_PATHS}
	)

	# Find library
	find_library(LUAJIT_LIBRARY
		NAMES ${LUAJIT_LIBRARY_NAMES}
		HINTS ${PC_LUAJIT_LIBDIR} ${PC_LUAJIT_LIBRARY_DIRS}
	)

	if(NOT LUAJIT_VERSION_STRING AND PC_LUAJIT_VERSION)
		set(LUAJIT_VERSION_STRING ${PC_LUAJIT_VERSION})
	endif()
endif()

# Set compatibility variables
if(LUAJIT_INCLUDE_DIR)
	set(LUAJIT_INCLUDE_DIRS ${LUAJIT_INCLUDE_DIR})
endif()

if(LUAJIT_LIBRARY)
	set(LUAJIT_LIBRARIES ${LUAJIT_LIBRARY})
endif()

# Try to determine version from lua.h
if(LUAJIT_INCLUDE_DIR AND NOT LUAJIT_VERSION_STRING)
	file(STRINGS "${LUAJIT_INCLUDE_DIR}/lua.h" LUAJIT_VERSION_LINE
		REGEX "^#define[ \t]+LUA_VERSION[ \t]+\"Lua [0-9]+\\.[0-9]+(\\.[0-9]+)?.*\""
	)

	if(LUAJIT_VERSION_LINE)
		string(REGEX MATCH "[0-9]+\\.[0-9]+(\\.[0-9]+)?" LUAJIT_VERSION_STRING "${LUAJIT_VERSION_LINE}")
	endif()

	# Alternative: try LUAJIT_VERSION
	if(NOT LUAJIT_VERSION_STRING)
		file(STRINGS "${LUAJIT_INCLUDE_DIR}/lua.h" LUAJIT_VERSION_MAJOR_LINE
			REGEX "^#define[ \t]+LUA_VERSION_NUM[ \t]+[0-9]+"
		)

		if(LUAJIT_VERSION_MAJOR_LINE)
			string(REGEX MATCH "[0-9]+" LUAJIT_VERSION_NUM "${LUAJIT_VERSION_MAJOR_LINE}")
			math(EXPR LUAJIT_VERSION_MAJOR "${LUAJIT_VERSION_NUM} / 100")
			math(EXPR LUAJIT_VERSION_MINOR "${LUAJIT_VERSION_NUM} % 100")
			set(LUAJIT_VERSION_STRING "${LUAJIT_VERSION_MAJOR}.${LUAJIT_VERSION_MINOR}")
		endif()
	endif()
endif()

# Handle the QUIETLY and REQUIRED arguments and set LUAJIT_FOUND to TRUE if all listed variables are TRUE
find_package_handle_standard_args(LuaJIT
	REQUIRED_VARS LUAJIT_LIBRARY LUAJIT_INCLUDE_DIR
	VERSION_VAR LUAJIT_VERSION_STRING
)

mark_as_advanced(LUAJIT_INCLUDE_DIR LUAJIT_LIBRARY)
