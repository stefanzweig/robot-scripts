from robot.libraries.BuiltIn import BuiltIn
import os

def tell_macro_value():
    builtin = BuiltIn()
    return os.path.dirname(builtin.get_variables()['${SUITE_SOURCE}'])

def file_log_test():
    from logger import file_log
    file_log.debug("I make him an offer that he cannot refuse.")
    file_log.info("I make him an offer that he cannot refuse.")
    file_log.error("I make him an offer that he cannot refuse.")


if __name__ == '__main__':
	file_log_test()
