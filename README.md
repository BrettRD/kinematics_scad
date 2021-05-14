# Kinematics for OpenSCAD

A simple forward and inverse kinematics implementation for OpenSCAD
![animation](https://github.com/BrettRD/kinematics_scad/blob/main/animation/animation.gif "OpenSCAD animation")

`forward_kinematics.scad` implements forward kinematics for series kinematic chains of arbitrary length, includes numeric differentiation to recover the Jacobian, and features a very simple gradient-descent Inverse-Kinematics solver for end-effector position.

This started as a weekend skill-sharpenning project to roughly replicate the "Axis" sculpture by Mark Setrakian after it was featured on Tested.com.\
IK was supposed to be via STL export into ROS2, but I got carried away.

`dragon_claw.scad` demonstrates creating poseable assemblies and describing kinematic chians, and is slowly becoming printable
`ring_animation.scad` demonstrates synthesising desired end-effector coordinates, generating poses, and using the $t parameter from OpenSCAD's animation feature.
