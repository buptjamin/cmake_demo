cmake_minimum_required(VERSION 3.2.1)
#set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Toolchain-arm-linux-gnueabihf.cmake)

# library Version
set(PRO_VERSION_MAJOR 1)
set(PRO_VERSION_MINOR 0)
set(PRO_VERSION_PATCH 0)
execute_process( 
    COMMAND git rev-list HEAD 
    COMMAND wc -l
    OUTPUT_VARIABLE GIT_COMMIT_VERSION
    )
set(PRO_VERSION_DEVELOP ${GIT_COMMIT_VERSION})
set(PRO_VERSION_SO ${PRO_VERSION_MAJOR}.${PRO_VERSION_MINOR}.${PRO_VERSION_PATCH})
set(PRO_VERSION_API ${PRO_VERSION_DEVELOP})

PROJECT("TODO_type_your_project_name_here")

# -----------------------------Global_Build_config------------------------------ #
#############  Build Config ############
option(BUILD_TYPE "Default Build Type:" ON)
#use default BUILD_TYPE:Debug
if(${BUILD_TYPE} MATCHES "ON")
    set(BUILD_TYPE "Debug")
endif(${BUILD_TYPE} MATCHES "ON")



# ---------------------------------- MACRO Definitions ------------------------- #
########### Embed/PC Macro Define #############
if($BUILD_TYPE MATCHES "Embed")
    # --------------------------------------- Embed Define------------------#
    add_definitions()
else($BUILD_TYPE MATCHES "Embed")
    # ---------------------------------------  PC   Define------------------#
    add_definitions()
endif($BUILD_TYPE MATCHES "Embed")

########### Debug/Release Macro Define ########
if($BUILD_TYPE MATCHES "Debug")
    # ----------------------------------------Debug  Define-----------------#
    add_definitions()
else($BUILD_TYPE MATCHES "Debug")
    # ----------------------------------------Release  Define---------------#
    add_definitions()
endif($BUILD_TYPE MATCHES "Debug")

# -----------------------------------C/C++ Compile Flags------------------------ #
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

# -----------------------------------cmake Debug Toggles------------------------ #
set(MO_CMAKE_DEBUG_FILE_MSGS ON)
set(CMAKE_VERBOSE_MAKEFILE ON)

# -------------------------------Color Settings--------------------------------- #
if(NOT WIN32)
    string(ASCII 27 Esc)
    set(ColourReset "${Esc}[m")
    set(ColourBold  "${Esc}[1m")
    set(Red         "${Esc}[31m")
    set(Green       "${Esc}[32m")
    set(Yellow      "${Esc}[33m")
    set(Blue        "${Esc}[34m")
    set(Magenta     "${Esc}[35m")
    set(Cyan        "${Esc}[36m")
    set(White       "${Esc}[37m")
    set(BoldRed     "${Esc}[1;31m")
    set(BoldGreen   "${Esc}[1;32m")
    set(BoldYellow  "${Esc}[1;33m")
    set(BoldBlue    "${Esc}[1;34m")
    set(BoldMagenta "${Esc}[1;35m")
    set(BoldCyan    "${Esc}[1;36m")
    set(BoldWhite   "${Esc}[1;37m")
endif()


# fetch Ubuntu release version to : LINUX_RELEASE_ISSUE_OUTPUT

if($BUILD_TYPE MATCHES "Embed")
    set(LINUX_RELEASE_ISSUE_OUTPUT "ARV_v7_Linux")
else($BUILD_TYPE MATCHES "Embed")
    execute_process( 
        COMMAND cat /etc/issue
        COMMAND cut -d " " -f1,2
        COMMAND cut -d "." -f1,2
        COMMAND tr -d '\n'
        COMMAND sed s/[[:space:]]//g
        OUTPUT_VARIABLE LINUX_RELEASE_ISSUE_OUTPUT 
        )
endif($BUILD_TYPE MATCHES "Embed")



SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
message("${Blue}-- Library Output DIR: ${BoldBlue}${PROJECT_BINARY_DIR}/lib${ColourReset}")
message("${Blue}-- Binary  Output DIR: ${BoldBlue}${PROJECT_BINARY_DIR}/bin${ColourReset}")


######## Global Opencv Config ##############
#set (OpenCV_DIR /usr/local/share/OpenCV)
find_package(OpenCV REQUIRED) 



# Build Config
if(${BUILD_TYPE} MATCHES "Debug")
    add_definitions(-O0 -g3 -Wall -c -fmessage-length=0 -fPIC)# -MMD -MP )# -MT "$@" -MF "$(@:%.o=%.d)" -MT "$(@)")
else(${BUILD_TYPE} MATCHES "Debug") #Release
    add_definitions(-O3 -Wall -c -fmessage-length=0 -fPIC)# -MMD -MP )# -MF "$(@:%.o=%.d)" -MT "$(@)")
    if(${BUILD_TYPE} MATCHES "Embed")
        add_definitions(-march=armv7-a -mtune=cortex-a9 -mfloat-abi=hard -mfpu=neon)
    endif(${BUILD_TYPE} MATCHES "Embed")
endif(${BUILD_TYPE} MATCHES "Debug")



#### ------------------------------------------------------- ####
#### ----------------------- TODO. 1 Start ----------------- ####
#### ---------------- Compile Source File Config ----------- ####

file(GLOB XXOO_all_srcs 
    LIST_DIRECTORIES false 
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/*.c"
    )

#### ------------------------------1 End ------------------- ####
#### ---------------- Compile Source File Config ----------- ####
#### ------------------------------------------------------- ####


#### ------------------------------------------------------- ####
#### ----------------------- TODO. 2 Start ----------------- ####
#### ---------------- Include Header File Config ----------- ####

# Compile from source code part.(TODO. add an version of compile from library)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Source/)
include_directories(${OPENCV_INCLUDE_DIR})

#### ------------------------------2 End ------------------- ####
#### ---------------- Include Header File Config ----------- ####
#### ------------------------------------------------------- ####



# -----------------------------------Lib Link Directory------------------------- #
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)

# -----------------------------------Module Compile----------------------------- #
add_library(${PROJECT_NAME} SHARED ${XXOO_all_srcs})
set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${PRO_VERSION_SO} SOVERSION ${PRO_VERSION_DEVELOP})

target_link_libraries(${PROJECT_NAME} 
    ${OpenCV_LIBS}
    )


# ------------------------------------------------------------------------------ #
# -----------------------------------Module Build Msg--------------------------- #
# ------------------------------------------------------------------------------ #

if(MO_CMAKE_DEBUG_FILE_MSGS)
    # cmake-debug messages   : output project details
    message( " Moudle INCLUDE : ")
    get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
    list(SORT dirs)
    foreach(dir ${dirs})
        message("   -- ${Green}${dir}${ColourReset}")
    endforeach()
    message( " Moudle SOURCES : ")
    foreach(dir ${XXOO_all_srcs})
        message("   -- ${Green}${dir}${ColourReset}")
    endforeach()
endif(MO_CMAKE_DEBUG_FILE_MSGS)

