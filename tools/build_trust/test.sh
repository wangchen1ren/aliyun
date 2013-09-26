#!/bin/sh

echo "test:pass@112.124.22.199" > _hostfile_test
sh trustall.sh -u root -p test _hostfile_test
rm _hostfile_test
