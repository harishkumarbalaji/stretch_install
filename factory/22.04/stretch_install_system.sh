#!/bin/bash
set -e

REDIRECT_LOGDIR="$HOME/stretch_user/log"
if getopts ":l:" opt && [[ $opt == "l" && -d $OPTARG ]]; then
    REDIRECT_LOGDIR=$OPTARG
fi
REDIRECT_LOGFILE="$REDIRECT_LOGDIR/stretch_install_system.`date '+%Y%m%d%H%M'`_redirected.txt"

function install {
    sudo apt-get install -y "$@" >> $REDIRECT_LOGFILE
}

echo "###########################################"
echo "INSTALLATION OF SYSTEM WIDE PACKAGES"
echo "###########################################"
echo "Apt update & upgrade (this might take a while)"
sudo apt-add-repository universe -y >> $REDIRECT_LOGFILE
sudo apt-get --yes update >> $REDIRECT_LOGFILE
sudo apt-get --yes upgrade &>> $REDIRECT_LOGFILE
echo "Install zip & unzip"
install zip unzip
echo "Install Curl"
install curl
echo "Install Git"
install git
echo "Install rpl"
install rpl
echo "Install ipython3"
install ipython3
install python3-pip
echo "Install Emacs packages"
install emacs yaml-mode
echo "Install nettools"
install net-tools
echo "Install wget"
install wget
echo "Install vim"
install vim
echo "Install pyserial"
install python3-serial
echo "Install Port Audio"
install portaudio19-dev
echo "Install lm-sensors & nvme-cli"
install lm-sensors
install nvme-cli
echo "Install Cython for FUNMAP"
install cython3
echo "Install cheese for camera testing"
install cheese
echo "Install SSH Server"
install ssh
echo "Install Chromium"
install chromium-browser
echo "Install htop"
install htop
echo "Install Ubuntu Sounds"
install ubuntu-sounds
echo "Install BleachBit"
install bleachbit
echo ""

# see https://docs.ros.org/en/galactic/Installation/Ubuntu-Install-Debians.html for details
echo "###########################################"
echo "INSTALLATION OF ROS 2 HUMBLE"
echo "###########################################"

echo "Ensuring Ubuntu Universe repository is enabled"
sudo apt install software-properties-common
sudo add-apt-repository universe # TODO(atharva-18): Do we really need this?

echo "Setting up keys"
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "Setting up sources.list"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "Apt update"
sudo apt-get --yes update >> $REDIRECT_LOGFILE

echo "Install ROS 2 Humble (this might take a while)"
install ros-humble-desktop

echo "Install colcon"
install python3-colcon-common-extensions

echo "Install rosdep"
install python3-rosdep
echo "Configure rosdep"
if [ -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
fi
sudo rosdep init >> $REDIRECT_LOGFILE
rosdep update --include-eol-distros >> $REDIRECT_LOGFILE
echo "Install vcstool"
install python3-vcstool
echo ""

echo "###########################################"
echo "INSTALLATION OF ADDITIONAL ROS HUMBLE PKGS"
echo "###########################################"
echo "Install packages to work with URDFs"
install liburdfdom-tools meshlab
install ros-humble-urdfdom-py

echo "Install joint state GUI package"
install ros-humble-joint-state-publisher-gui

echo "Install TF2 related packages"
install ros-humble-tf2-tools

echo "Install IMU visualization plugin for RViz and IMU filter"
install ros-humble-rviz-imu-plugin ros-humble-imu-filter-madgwick

echo "Install robot localization package for use with IMU and wheel odometry"
install ros-humble-robot-localization

echo "Install ros_numpy package for msgs conversions"
# install ros-humble-ros-numpy # not available for ROS2 yet (see https://github.com/eric-wieser/ros_numpy/issues/20)

echo "Install control packages for MoveIt 2"
install ros-humble-ros2-control ros-humble-ros2-controllers

echo "Install teleop packages"
install ros-humble-teleop-twist-keyboard

echo "Install RPLidar A1M8 packages"
install ros-humble-rplidar-ros ros-humble-rplidar-ros-dbgsym

echo "Install Respeaker and speech recognition packages"
install python3-pyaudio
# install ros-humble-respeaker-ros ros-humble-ros-speech-recognition # not available

echo "Install scan tools for Canonical Scan Matching using the laser_scan_matcher"
# install ros-humble-scan-tools # not available
echo ""

echo "###########################################"
echo "INSTALLATION OF INTEL D435i"
echo "###########################################"
echo "Install dynamic reconfiguration"
# install ros-humble-ddynamic-reconfigure ros-humble-ddynamic-reconfigure-python
echo "Register the librealsense APT server's public key"
function register_librealsense_apt_server {
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
}
register_librealsense_apt_server &>> $REDIRECT_LOGFILE
echo "Add the librealsense APT server to the list of APT repositories"
sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -y -u
echo "Remove old records in case of upgrading"
sudo rm -f /etc/apt/sources.list.d/realsense-public.list
echo "Apt update"
sudo apt-get --yes update >> $REDIRECT_LOGFILE
echo "Install librealsense2 packages"
install librealsense2 librealsense2-dkms librealsense2-udev-rules librealsense2-utils librealsense2-dev librealsense2-dbg
