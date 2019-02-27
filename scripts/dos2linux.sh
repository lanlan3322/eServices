#!/bin/bash
cp $1 $1.orig
rm $1
sed -e "s/^M//" $1.orig > $1 
chmod 755 $1

# replace the ^M with below:
# The easiest way is probably to use the stream editor sed to remove the ^M characters. 
# Type this command: % sed -e "s/^M//" filename > newfilename
# To enter ^M, type CTRL-V, then CTRL-M. 
# That is, hold down the CTRL key then press V and M in succession.


