*** Settings ***
Library           OperatingSystem
Library           String

*** Variable ***
${TOOLS_DIR}         d:\\USERS\\

*** Testcases ***
KKK
    Get version of TargetBD_KKK
    # RUN demo

*** Keywords ***
Get version of TargetBD
    @{matched_file}=    List Files In Directory   ${TOOLS_DIR}   TargetBD_*.xml
    # log    @{matched_file}    warn
    @{targetBD_split_list}=    Split String    @{matched_file}[0]    TargetBD_
    # log    ${targetBD_split_list}    warn
    @{enb_version}=          Split String              @{targetBD_split_list}[1]    .xml    1
    # log    @{enb_version}[0]    warn
    @{suffix}=    Split String    @{enb_version}[0]    _     1
    #log    ${suffix}    warn
    @{branch}=    Split String From Right    @{suffix}[0]    17SP     1
    log    ${branch}    warn
    ${length_SP}=   Get Length    ${branch}
    log    ${length_SP}    warn
    ${tl00}=    Catenate    SEPARATOR=    @{branch}[0]    00
    ${version}=    Set Variable If    ${length_SP}==2    ${tl00}    @{branch}[0]
    log    ${version}    warn
    ${version}=    Catenate    SEPARATOR=_    ${version}    @{suffix}[1]
    log    ${version}    warn
    # ${enb_version_new}=    Replace String    @{enb_version}[0]    L17_FSM3    L00_FSM3
    # log    ${enb_version_new}     warn
    # ${enb_version_type}=    Get Substring    ${enb_version}    0     2
    # log    ${enb_version_type}     warn

RUN demo
    ${output}=    Run     dir ${TOOLS_DIR}
    # log    ${output}    warn
    ${output}=    Run and Return RC     dir ${TOOLS_DIR}
    # ${rc}    ${output}=    Run And Return Rc And Output     dir ${TOOLS_DIR}
    Run And Return Rc And Output     dir ${TOOLS_DIR}

_workaround_normalize_enb_version
                      [Arguments]             ${enb_version}
                      @{prefix}=    Split String    ${enb_version}    _     1
                      @{branch}=    Split String From Right    @{prefix}[0]    17SP     1
                      ${length_SP}=   Get Length    ${branch}
                      ${tl00}=    Catenate    SEPARATOR=    @{branch}[0]    00
                      ${version}=    Set Variable If    ${length_SP}==2    ${tl00}    @{branch}[0]
                      ${version}=    Catenate    SEPARATOR=_    @{branch}[0]    @{prefix}[1]
                      [Return]             ${version}


Get version of TargetBD_KKK
    @{matched_file}=    List Files In Directory   ${TOOLS_DIR}   TargetBD_*.xml
    # log    @{matched_file}    warn
    @{targetBD_split_list}=    Split String    @{matched_file}[0]    TargetBD_
    # log    ${targetBD_split_list}    warn
    @{enb_version}=          Split String              @{targetBD_split_list}[1]    .xml    1
    log    @{enb_version}[0]    warn
    ${version}    _workaround_normalize_enb_version    @{enb_version}[0]
    log    ${version}    warn


