*** Settings ***
Documentation     testsuites and keywords for study of the robotframework.
Library           DateTime
Library           Collections
Resource          zweig_resource.robot
Resource          stefan_resource.robot

*** Variable ***
${message}      You made me an offer that I cannot refuse.

*** Test Cases ***
Simple Log to Console
    [Documentation]    test case simply prints the message to console.
    Log to Console Demo

Log From Multiple Source
    [Documentation]    test if the keywords lies in several resource files.
    Log to Console From Zweig Resource

Handle data with Collections
    [Documentation]    some actions related with data structures in library collections.
    Print List to Console    12 34 56

*** Keywords ***
Log to Console Demo
    [Documentation]    keyword prints the message to console.
    LOG          ${message}    WARN

Print List to Console
    [Documentation]    prints the arguments into console.
    [Arguments]    @{sth}
    Log List    ${sth}    WARN
    Log List    @{sth}    WARN
