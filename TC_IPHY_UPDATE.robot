*** Setting ***
Documentation     This is IPHY update to specific build.
Suite Setup       setup ue    1
Suite Teardown    Teardown Log
Test Setup
Test Teardown
Force Tags        IPHY update

Library           OperatingSystem
Library           ute_fsmaccess
Library           tdd_common
Library           ute_wtssim
Library           tdd_pb
Library           tdd_ue
Variables         tdd_config
Resource          resources/TDD_Keywords/tdd_bts.robot
Resource          resources/TDD_Keywords/tdd_syslog.robot
Resource          resources/TDD_Keywords/tdd_common.robot
Resource          resources/TDD_Keywords/tdd_wts_fsm_access.robot


*** Variable ***
${iphy_package_path}    /opt/Software/IPHY
${pkg_puttibatti_pattern}    *WTS*puttibatti.zip
${pkg_esimmode_pattern}    *esimmode*core2.tar.bz2
${unzip_puttibatti_folder}    puttibatti_package
${unzip_esimmode_folder}    esimmode_package
${puttibatti_script_name}    fsmf_sw_update.py
${iphy_latest}    /opt/iphy/latest
${configure}    Configured
${configure_timeout}    900s
${onair}    OnAir
${onair_timeout}    300s
${cfg_lua_path}    /opt/iphy/latest/tddLuaScripts/lte_wraparound_cfg.lua
${second_iphy_alive}    ${False}


*** Test Case ***
IPHY Update Case
    IPHY Update Prepare
    IPHY Update Package
    Reboot ENB And IPHY
    Wait ENB Until Onair

*** Keyword ***
IPHY Update Prepare
    @{package}=     Get IPHY Puttibatti and Esimmode Package
	Log    ${iphy_package_path}${/}@{package}[0]
	Log    ${iphy_package_path}${/}@{package}[1]
	Set Suite Variable    ${puttibatti_package_path}    ${iphy_package_path}${/}@{package}[0]
	Set Suite Variable    ${esimmode_package_path}    ${iphy_package_path}${/}@{package}[1]
	Unzip IPHY Package
	# Backup Current IPHY Xml


Get IPHY Puttibatti and Esimmode Package
    @{puttibatti_matched_file}=    List Files In Directory    ${iphy_package_path}    ${pkg_puttibatti_pattern}
    @{esimmode_matched_file}=    List Files In Directory    ${iphy_package_path}    ${pkg_esimmode_pattern}
	Length Should Be    ${puttibatti_matched_file}    1
	Length Should Be    ${esimmode_matched_file}    1
	[return]    @{puttibatti_matched_file}[0]    @{esimmode_matched_file}[0]

Unzip IPHY Package
	Remove Directory    ${iphy_package_path}${/}${unzip_puttibatti_folder}    True
	Remove Directory    ${iphy_package_path}${/}${unzip_esimmode_folder}    True
	Create Directory    ${iphy_package_path}${/}${unzip_puttibatti_folder}
	Create Directory    ${iphy_package_path}${/}${unzip_esimmode_folder}
	${rc}    ${output}    Run And Return Rc And Output    chmod 775 ${puttibatti_package_path}
	${rc}    ${output}    Run And Return Rc And Output    chmod 775 ${esimmode_package_path}
	${rc}    ${output}    Run And Return Rc And Output    unzip ${puttibatti_package_path} -d ${iphy_package_path}${/}${unzip_puttibatti_folder}
	${rc}    ${output}    Run And Return Rc And Output    tar -xvf ${esimmode_package_path} -C ${iphy_package_path}${/}${unzip_esimmode_folder}
	#${puttibatti_script_path}=    Set Variable    ${iphy_package_path}${/}${unzip_puttibatti_folder}
	#${esimmode_script_path}=    Set Variable    ${iphy_package_path}${/}${unzip_esimmode_folder}
    Set Suite Variable    ${puttibatti_script_path}    ${iphy_package_path}${/}${unzip_puttibatti_folder}
    Set Suite Variable    ${esimmode_script_path}    ${iphy_package_path}${/}${unzip_esimmode_folder}

Backup Current IPHY Xml
    Setup Wts Fsm Access    host=${tl.iphy["A"].fsm.lmp_ip_address}
    Log     ${tl.iphy["A"].fsm.lmp_ip_address}
    ${Backup_IPHY_XML}=    Get Wts Config File    destination=${TEST LOG DIRECTORY()}
    Set Suite Variable    ${Backup_IPHY_XML}
    [teardown]    Teardown Wts Fsm Access

IPHY Update Package
    Run Keyword And Ignore Error    start collect enb syslog    log_name=btslog
    Run Keyword And Ignore Error    start collect iphy syslog    log_name=iphylog
    ${output}    Run    cd ${puttibatti_script_path}; python ${puttibatti_script_name} -i ${tl.iphy["A"].fsm.lmp_ip_address} --set_ge_ips 10.0.2.2 10.0.2.1 --save_iphy_xml --password oZPS0POrRieRtu --force
    Log    ${output}
    ${update_success}=    Run Keyword And Return Status    Should Contain    ${output}    End of the script, success
    ${output}=    Run Keyword If    ${update_success}==False    Run    cd ${puttibatti_script_path}; python ${puttibatti_script_name} -i ${tl.iphy["A"].fsm.lmp_ip_address} --set_ge_ips 10.0.2.2 10.0.2.1 --save_iphy_xml --password oZPS0POrRieRtu -n
    # Setup Wts Fsm Access    host=${tl.iphy["A"].fsm.lmp_ip_address}
	# ${test_log}=    Put Wts Config File    source=${Backup_IPHY_XML}    partition=passive
    ${switch_partition_success}=    Run Keyword And Return Status    Should Contain    ${output}    End of the script, success

    ${output2}=    Run    ping -c 4 192.168.255.21
    ${only_one_iphy}=    Run Keyword And Return Status    Should Contain    ${output2}    Destination Host Unreachable
    LOG    ${only_one_iphy}    WARN
    Run Keyword If    ${only_one_iphy}==False    Update 2nd IPHY Package
    Run Keyword If    ${only_one_iphy}==False    Set Suite Variable    ${second_iphy_alive}    ${True}
    # [teardown]    Teardown Wts Fsm Access
    Update Esimmode Package

Update 2nd IPHY Package
    ${output2}    Run    cd ${puttibatti_script_path}; python ${puttibatti_script_name} -i ${tl.iphy["B"].fsm.lmp_ip_address} --set_ge_ips 10.0.2.3 10.0.2.1 --set_fsm_id 2 --set_srio_domain 2 --save_iphy_xml --password oZPS0POrRieRtu --force
    Log    ${output2}
    Should Contain    ${output2}    End of the script, success
    # Setup Wts Fsm Access    host=${tl.iphy["B"].fsm.lmp_ip_address}
    # ${test_log}=    Put Wts Config File    source=${Backup_IPHY_XML}    partition=passive

Reboot ENB And IPHY
    Reboot IPHY
    Run Keyword If    ${second_iphy_alive}==True    Reboot IPHY    iphy_index=B
    Sleep  10
    Reboot BTS

Teardown ENB and IPHY Access
    Run Keyword And Ignore Error    Teardown Wts Fsm Access    alias=iphy_reboot
    Run Keyword And Ignore Error    Teardown Enb Fsm Access    alias=enb_reboot

Update Esimmode Package
    ${rc}    ${output}    Run And Return Rc And Output     ps -ef | egrep "egate|edaemon|sim_" | egrep "10000|20000|30000|40000|40001|60000|60001" | grep -v grep |awk ' {print $2} ' | xargs -i sudo kill -9 {}
    #${rc}    ${output}    Run And Return Rc And Output    sudo pkill -9 egate
    #${rc}    ${output}    Run And Return Rc And Output    sudo pkill -9 edaemon
    sleep    2
    ${rc}    ${output}    Run And Return Rc And Output    cp -r ${esimmode_script_path}${/}* ${iphy_latest}
    Should Be Equal As Integers    ${rc}    0

Wait ENB Until Onair
	Start WTS applications    cfg_file=${cfg_lua_path}
    ${check_status}    Run Keyword And Return Status     Wait bts until onair    1200s
	Run Keyword If    '${check_status}'=='False'    Reboot BTS until onair    900s

Teardown Log
    Run Keyword And Ignore Error    stop and collect enb syslog
    Run Keyword And Ignore Error    stop and collect iphy syslog
    Run Keyword And Ignore Error    get ue log    ${TEST LOG DIRECTORY()}



