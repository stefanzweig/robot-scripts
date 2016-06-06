from robot.libraries.BuiltIn import BuiltIn
import os

def tell_macro_value():
	blt = BuiltIn()
	return os.path.dirname(blt.get_variables()['${SUITE_SOURCE}'])
