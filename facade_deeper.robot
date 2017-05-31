*** Settings ***
Documentation     Interface resource file for test.
Resource          stefan_resource.robot
Resource          zweig_resource.robot


*** Keywords ***
test the lib order
    Set Library Search Order    zweig_resource    stefan_resource
    Log to Console From Zweig Resource