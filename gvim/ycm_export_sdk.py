import sys
import os

def usage():
    print "Please supply sdk sysroot path."
    print "Usage %s <sdk_sysroot_path>"

if len(sys.argv) != 2:
    usage()
    exit(-1)

import os

sdk_path = sys.argv[1]
if not os.path.isdir(sdk_path):
    print("ERROR! Supplied sdk path doesnt exists or is not directory!")

sdk_path = sdk_path.strip()
split_path = sdk_path.split('/')
plat_name = split_path[-1]
if plat_name == '':
    plat_name = split_path[-2]

# Construct path with version of libc++ that is created by sdk like .../c++/4.9.2/
sdk_c_inc_path = os.path.join(sdk_path, 'usr', 'include')
sdk_c_inc_path_cpp = os.path.join(sdk_c_inc_path, 'c++')
sdk_c_inc_path_cpp = os.path.join(sdk_c_inc_path_cpp, os.listdir(sdk_c_inc_path_cpp)[0])
sdk_c_inc_path_cpp_bits = os.path.join(sdk_c_inc_path_cpp, plat_name)

export_str = '''export CPATH=%s:%s:%s:$CPATH''' % (sdk_c_inc_path, sdk_c_inc_path_cpp, sdk_c_inc_path_cpp_bits)

with open(os.path.expanduser('~/ycm_export_sdk'), 'w') as f:
    f.write(export_str)

print "Exported CPATH to ~/ycm_export_sdk"
