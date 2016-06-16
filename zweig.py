import os
import fcntl
from subprocess import Popen, PIPE
from robot.libraries.BuiltIn import BuiltIn
from tdd_kiss_core.sshconnection.sshconnection import SshConnection

class ProcessControl(object):
    def __init__(self, process):
        self.process = process

    def stop_process(self):
        """Stop subprocess process"""
        if self.process and not self._is_process_terminated():
            self.process.terminate()
            if not self._process_terminates_within(5):
                self.process.kill()

    def _process_terminates_within(self, timeout):
        return self._wait(self._is_process_terminated, 0.25, timeout)

    def _is_process_terminated(self):
        return self.process.poll() is not None

    def _wait(self, cond_func, sleep_step, timeout):
        start = time()
        while not cond_func():
            now = time()
            if now - start >= timeout:
                return False
            sleep(sleep_step)
        return True

def setNonBlocking(fd):
    flags = fcntl.fcntl(fd, fcntl.F_GETFL)
    flags = flags | os.O_NONBLOCK
    fcntl.fcntl(fd, fcntl.F_SETFL, flags)

def tell_macro_value():
    blt = BuiltIn()
    return os.path.dirname(blt.get_variables()['${SUITE_SOURCE}'])

def run_command_under_ssh_localhost(cmd):
    execute_command_by_ssh(cmd)

def execute_command_by_ssh(cmd):
    ssh_client = SshConnection("127.0.0.1", "abc", "abc", 22, prompt="$ ")
    try:
        ssh_client._setup()
        ret = ssh_client.execute(cmd)
    except Exception, e:
        pass
    finally:
        ssh_client._teardown()
        return ret

def zweig_start_cmd(cmd):
    proc = subprocess.Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE)
    setNonBlocking(proc.stdout)
    setNonBlocking(proc.stdin)
    while True:
        try:
            out = proc.stdout.read()
            print("*WARN* "+ out)
        if "Press Return to stop" in out:
            return proc
        except IOError:
            continue
        else:
            break
    return proc

def zweig_stop_cmd(proc):
    proc.stdin.write("\n")
    while True:
        try:
            out = proc.stdout.read()
            print("*WARN* "+ out)
            if "finishing......" in out:
                return 0
        except IOError:
            continue
        else:
            break
    return 1
