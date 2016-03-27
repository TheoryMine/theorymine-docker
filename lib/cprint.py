"""Print with Colors.
"""

import subprocess

#--------------------------------------
# Num  Colour    #define         R G B
#--------------------------------------
# 0    black     COLOR_BLACK     0,0,0
# 1    red       COLOR_RED       1,0,0
# 2    green     COLOR_GREEN     0,1,0
# 3    yellow    COLOR_YELLOW    1,1,0
# 4    blue      COLOR_BLUE      0,0,1
# 5    magenta   COLOR_MAGENTA   1,0,1
# 6    cyan      COLOR_CYAN      0,1,1
# 7    white     COLOR_WHITE     1,1,1

RED=subprocess.check_output(['tput', 'setaf', '1'])
GREEN=subprocess.check_output(['tput', 'setaf', '2'])
YELLOW=subprocess.check_output(['tput', 'setaf', '3'])
BLUE=subprocess.check_output(['tput', 'setaf', '4'])
RESET=subprocess.check_output(['tput', 'sgr0'])

def green(s):
  print(GREEN + s + RESET)

def yellow(s):
  print(YELLOW + s + RESET)

def red(s):
  print(RED + s + RESET)
