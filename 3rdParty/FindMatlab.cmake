# - this module looks for Matlab
# Defines:
#  MATLAB_INCLUDE_DIR: include path for mex.h, engine.h
#  MATLAB_LIBRARIES:   required libraries: libmex, etc
#  MATLAB_MAT_LIBRARY: path to libmat.lib
#  MATLAB_MEX_LIBRARY: path to libmex.lib
#  MATLAB_MX_LIBRARY:  path to libmx.lib
#  MATLAB_ENG_LIBRARY: path to libeng.lib


SET(MATLAB_FOUND 0)
IF(WIN32)
  IF(${CMAKE_GENERATOR} MATCHES "Visual Studio .*" OR ${CMAKE_GENERATOR} MATCHES "NMake Makefiles")
    SET(MATLAB_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/lib/win32/microsoft/")
  ELSE(${CMAKE_GENERATOR} MATCHES "Visual Studio .*" OR ${CMAKE_GENERATOR} MATCHES "NMake Makefiles")
      IF(${CMAKE_GENERATOR} MATCHES "Borland")
        # Same here, there are also: bcc50 and bcc51 directories
        SET(MATLAB_ROOT "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/lib/win32/microsoft/bcc54")
      ELSE(${CMAKE_GENERATOR} MATCHES "Borland")
        MESSAGE(FATAL_ERROR "Generator not compatible: ${CMAKE_GENERATOR}")
      ENDIF(${CMAKE_GENERATOR} MATCHES "Borland")
  ENDIF(${CMAKE_GENERATOR} MATCHES "Visual Studio .*" OR ${CMAKE_GENERATOR} MATCHES "NMake Makefiles")
  FIND_LIBRARY(MATLAB_MEX_LIBRARY
    libmex
    ${MATLAB_ROOT}
    )
  FIND_LIBRARY(MATLAB_MX_LIBRARY
    libmx
    ${MATLAB_ROOT}
    )
  FIND_LIBRARY(MATLAB_ENG_LIBRARY
    libeng
    ${MATLAB_ROOT}
    )
  FIND_LIBRARY(MATLAB_MAT_LIBRARY
    libmat
    ${MATLAB_ROOT}
    )

  FIND_PATH(MATLAB_INCLUDE_DIR
    "mex.h"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\MathWorks\\MATLAB\\7.0;MATLABROOT]/extern/include"
    )
ELSE( WIN32 )
  IF(NOT MATLAB_ROOT)
    IF($ENV{MATLAB_ROOT})
      SET(MATLAB_ROOT $ENV{MATLAB_ROOT})
    ELSE($ENV{MATLAB_ROOT})
      SET(MATLAB_ROOT /opt/matlab)
    ENDIF($ENV{MATLAB_ROOT})    
  ENDIF(NOT MATLAB_ROOT)
  IF(CMAKE_SIZEOF_VOID_P EQUAL 4)
    # Regular x86
    SET(MATLAB_SYS
      ${MATLAB_ROOT}/bin/glnx86
      CACHE PATH "Location of Matlab system libraries" PARENT_SCOPE 
      )
  ELSE(CMAKE_SIZEOF_VOID_P EQUAL 4)
    # AMD64:
    SET(MATLAB_SYS
      ${MATLAB_ROOT}/bin/glnxa64
      CACHE PATH "Location of Matlab system libraries" PARENT_SCOPE 
      )
  ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 4)
  FIND_LIBRARY(MATLAB_MEX_LIBRARY
    mex
    ${MATLAB_SYS}
    )
  FIND_LIBRARY(MATLAB_MX_LIBRARY
    mx
    ${MATLAB_SYS}
    )
  FIND_LIBRARY(MATLAB_MAT_LIBRARY
    mat
    ${MATLAB_SYS}
    )
  FIND_LIBRARY(MATLAB_ENG_LIBRARY
    eng
    ${MATLAB_SYS}
    )
  FIND_PATH(MATLAB_INCLUDE_DIR
    "mex.h"
    ${MATLAB_ROOT}/extern/include
    )

ENDIF(WIN32)

# This is common to UNIX and Win32:
SET(MATLAB_LIBRARIES
  ${MATLAB_MEX_LIBRARY}
  ${MATLAB_MX_LIBRARY}
  ${MATLAB_ENG_LIBRARY}
)

IF(MATLAB_INCLUDE_DIR 
    AND MATLAB_MEX_LIBRARY 
    AND MATLAB_MAT_LIBRARY
    AND MATLAB_ENG_LIBRARY
    AND MATLAB_MX_LIBRARY)
  SET(MATLAB_LIBRARIES ${MATLAB_MX_LIBRARY} ${MATLAB_MEX_LIBRARY} ${MATLAB_ENG_LIBRARY} ${MATLAB_MAT_LIBRARY})
ENDIF(MATLAB_INCLUDE_DIR 
    AND MATLAB_MEX_LIBRARY 
    AND MATLAB_MAT_LIBRARY
    AND MATLAB_ENG_LIBRARY
    AND MATLAB_MX_LIBRARY)

MARK_AS_ADVANCED(
  MATLAB_MEX_LIBRARY
  MATLAB_MX_LIBRARY
  MATLAB_ENG_LIBRARY
  MATLAB_INCLUDE_DIR
  MATLAB_ROOT
  MATLAB_SYS
)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Matlab 
    MATLAB_INCLUDE_DIR 
    MATLAB_MEX_LIBRARY 
    MATLAB_MAT_LIBRARY
    MATLAB_ENG_LIBRARY
    MATLAB_MX_LIBRARY )

