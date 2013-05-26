from plumbum import local
from plumbum.cmd import timeout

def run(useless_code):
	return timeout[3, local['./baudot-code/stub'][useless_code]]()