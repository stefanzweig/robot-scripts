from robot.libraries.BuiltIn import BuiltIn
import os
from tdd_kiss_core.sshconnection.sshconnection import SshConnection

def tell_macro_value():
    blt = BuiltIn()
    return os.path.dirname(blt.get_variables()['${SUITE_SOURCE}'])

def run_command_under_ssh_localhost(cmd):
    execute_command_by_ssh(cmd)

def execute_command_by_ssh(cmd):
    ssh_client = SshConnection("127.0.0.1", "ute", "ute", 22, prompt="$ ")
    try:
        ssh_client._setup()
        ret = ssh_client.execute(cmd)
    except Exception, e:
        pass
    finally:
        ssh_client._teardown()
        return ret
