"""
reads a file in the format

address 00ff
77ff
c041
address 1000
c868
2fff

and outputs one in the format

"0000000000000000",
...
"0000000000000000",
"0111011111111111",
"1100000001000001",
...
"1100100001101000",
"0010111111111111",
others => (others => '0')

"""

import sys

f_out = 'imem.txt'
f = open(sys.argv[1], 'r')
rom = [0 for i in range(2**14)]
curr_addr = 0
max_addr = 0

for line in f:
	if len(line.split()) == 2:
		curr_addr = int(line.split()[1], 16)
	else:
		rom[curr_addr] = bin(int(line, 16))[2:]
		curr_addr += 1
	if curr_addr > max_addr:
		max_addr = curr_addr

f.close()
f = open(f_out, 'w')

print("Writing to " + f_out)
for i in range(max_addr):
	f.write('"' + str(rom[i]).zfill(16) + '",\n')

f.write("others => (others => '0')")

print("Done.")
