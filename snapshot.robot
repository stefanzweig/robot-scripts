*** Settings ***
Documentation     Play with snapshot
Library           Screenshot

*** Variables ***
${SCFC_PATH}      /ffs/run/config/SCFC*.xml


*** Test Cases ***
Take_Screenshot
    Set Screenshot Directory    d:/USERS/Haijiang/
    Take Screenshot    mypic