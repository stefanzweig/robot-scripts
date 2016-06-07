*** Settings ***
Documentation     Test the SSH localhost command
Library           zweig

*** Variables ***
${cmd}    ls -l /home/ute/stefan


*** Test Cases ***
This is a simple command for ssh localhost
    Run the command in localhost


    *** Keywords ***      Action    Action    Action
    Run the command in localhost
        : FOR    ${INDEX}    IN RANGE    25*4
            \      ${output}=    execute_command_by_ssh   ${cmd}
            \      LOG    ${INDEX}    WARN

