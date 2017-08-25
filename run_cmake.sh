#!/bin/bash

Esc="\033"
ColourReset="${Esc}[m"
ColourBold="${Esc}[1m"
Red="${Esc}[31m"
Green="${Esc}[32m"
Yellow="${Esc}[33m"
Blue="${Esc}[34m"
Magenta="${Esc}[35m"
Cyan="${Esc}[36m"
White="${Esc}[37m"
BoldRed="${Esc}[1;31m"
BoldGreen="${Esc}[1;32m"
BoldYellow="${Esc}[1;33m"
BoldBlue="${Esc}[1;34m"
BoldMagenta="${Esc}[1;35m"
BoldCyan="${Esc}[1;36m"
BoldWhite="${Esc}[1;37m"

# global settings
shelldir=$(dirname `readlink -f $0`)
build_type="Release"
build_num=3
arr_build_type=(Debug DebugEmbed Release ReleaseEmbed)

auto=false

check_install_dep(){

    echo -en "${BoldWhite}Run dependencies checking ... ... \n \n${ColourReset}"

    # check if relative package is installed
    dpkg -l  gcc-arm-linux-gnueabihf      2>/dev/null  | grep -q   gcc-arm-linux-gnueabihf
    pkg_gcc_arm=$?
    dpkg -l  g++-arm-linux-gnueabihf      2>/dev/null  | grep -q   g++-arm-linux-gnueabihf
    pkg_gpp_arm=$?
    dpkg -l  g++-4.8-arm-linux-gnueabihf  2>/dev/null  | grep -q   g++-4.8-arm-linux-gnueabihf
    pkg_gpp_lib_arm=$?
    dpkg -l  gcc-4.8-arm-linux-gnueabihf  2>/dev/null  | grep -q   gcc-4.8-arm-linux-gnueabihf
    pkg_gcc_lib_arm=$?
    # if not install, then install it
    if [ ${pkg_gcc_arm} != 0 ]
    then
        sudo apt install -y gcc-arm-linux-gnueabihf
    fi

    if [ ${pkg_gpp_arm} != 0 ]
    then
        sudo apt install -y g++-arm-linux-gnueabihf
    fi

    if [ ${pkg_gpp_lib_arm} != 0 ]
    then
        sudo apt install -y g++-4.8-arm-linux-gnueabihf
    fi

    if [ ${pkg_gcc_lib_arm} != 0 ]
    then
        sudo apt install -y gcc-4.8-arm-linux-gnueabihf
    fi

    echo -en "${BoldWhite}Dependencies checking done. \n \n${ColourReset}"

}


build_main(){

    if [ $# = 1 ]
    then
        auto=true
        if [ $1 = 'y' ]
        then
            res_choose='y'
        else
            echo -en "Use default config: ${BoldRed}ReleaseEmbed\n \n${ColourReset}"
            res_choose='n'
            build_num=3
        fi
    fi

    if [ $# = 2 ]
    then
        auto=true
        res_choose=$1
        build_num=$2
    fi

    # echo info
    clear
    echo -e "-------------------------------------------------------"
    echo -e "---------------------${BoldCyan}MetoakCore building${ColourReset}---------------"
    echo -e "-------------------------------------------------------"
    echo -e ""

    check_install_dep

    # choose build type
    echo -en "----Use default BUILD_TYPE(${BoldGreen}Release${ColourReset}).(${BoldCyan}Y/n${ColourReset}): "

    if [ ! $auto = true ]
    then
        read res_choose
    fi
    case $res_choose in
        Y|y)
            echo "BUILD_TYPE: Release";;
        *)
            echo "Choose an BUILD_TYPE :"
            echo -en "   ${BoldYellow}1${ColourReset} Debug\n"
            echo -en "   ${BoldYellow}2${ColourReset} DebugEmbed \n"
            echo -en "   ${BoldYellow}3${ColourReset} Release \n"
            echo -en "   ${BoldYellow}4${ColourReset} ReleaseEmbed \n"
            echo -en "Input an BUILD_TYPE ${BoldYellow}Number${ColourReset} : "
            if [ ! $auto = true ]
            then
                read  -p "" build_num
            fi;;
    esac
    build_num=$((build_num-1))
    build_type=${arr_build_type[${build_num}]}


    # echo build_type
    echo -en "\n\n -- ${BoldWhite}Run cmake in :  ${ColourReset}${BoldGreen}${build_type}${ColourReset} ${BoldWhite} mode. ${ColourReset}"
    echo -en "... \n" 

    # check && clean build folder
    build_dir="${shelldir}/build${build_type}"
    if [ ! -d $build_dir ]
    then
        echo "build directory: build ..."
        mkdir -p $build_dir
    else
        if [ -f ${build_dir}/Makefile ]
        then
            echo -en "${BoldWhite}Cleaning build folder ... \n${ColourReset}"
            #cd $build_dir &&  make clean && cd -
        fi
    fi
    cd $build_dir 

    # cmake
    if [[ ${build_type} = "Debug" ]]
    then
        cmake -DBUILD_TYPE=${build_type} ..
    elif [[ ${build_type} = "DebugEmbed" ]]
    then
        cmake -DBUILD_TYPE=${build_type} -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain-arm-linux-gnueabihf.cmake  .. 
    elif [[ ${build_type} = "Release" ]]
    then
        cmake -DBUILD_TYPE=${build_type} ..
    elif [[ ${build_type} = "ReleaseEmbed" ]]
    then
        cmake -DBUILD_TYPE=${build_type} -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain-arm-linux-gnueabihf.cmake  .. 
    else
        echo "DBUILD_TYPE illegal"
        exit -1
    fi

    # make
    echo -en "\n\n -- ${BoldWhite}make ...  ${ColourReset} "
    echo -en "... "  && sleep 1 && echo -en " ... \n" 
    make -j`nproc`

    # echo make install
    echo -en "\n \n \n"
    echo -en "Build complete, run following Command for installation: \n\n\t\t\t${BoldMagenta}cd ${build_dir} && make install${ColourReset} \n\t\t\t\t"
    echo -en "\n \n \n"

}

build_main $@
