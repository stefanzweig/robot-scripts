from subprocess import Popen, PIPE
import fcntl

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

def start_cmd(cmd):
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

def stop_cmd(proc):
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