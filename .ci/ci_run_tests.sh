#!/bin/bash

# Exit immediatelly if a command exits with a non-zero status
set -e

# Executes a command when DEBUG signal is emitted in this script - should be after every line
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG

# Executes a command when ERR signal is emmitted in this script
trap 'echo "$0: \"${last_command}\" command failed with exit code $?"' ERR

distro=`lsb_release -r | awk '{ print $2 }'`
[ "$distro" = "18.04" ] && ROS_DISTRO="melodic"
[ "$distro" = "20.04" ] && ROS_DISTRO="noetic"

source ~/.bashrc

echo "Starting running tests"
cd ~/uav_ws
catkin build uav_ros_tests
catkin build uav_ros_tests --catkin-make-args tests

# folder for test results
TEST_RESULT_PATH=$(realpath /tmp/$RANDOM)
mkdir -p $TEST_RESULT_PATH

# run the test
export UAV_NAMESPACE=red
rostest uav_ros_tests kopterworx_base_rostest.launch -t --results-filename=uav_ros_tests.test --results-base-dir="$TEST_RESULT_PATH"

# evaluate the test results
catkin_test_results "$TEST_RESULT_PATH"
echo "Ended running tests"