rarb 42
acc 15
to-mba
acc 5
addc-mba //ACC = 0x4, CF = 1
to-mba // mem[42] = 0x4
acc 1 // ACC = 1
addc-mba // ACC = 6, CF = 0
acc 12 // ACC = 12
to-mba // mem[42] = 0xc
acc 5 // ACC = 5
addc-mba // ACC = 1, CF = 1
addc-mba // ACC = 14, CF = 0
addc-mba // ACC = 10, CF = 1 
subc-mba // ACC = 15, CF = 1
subc-mba // ACC = 4, CF = 0
sub-mba // ACC = 8, CF = 1
sub-mba // ACC = 12, CF = 1
sub-mba // ACC = 0, CF = 0
add-mba // ACC = 12, CF = 0
sub-mba // ACC = 0, CF = 0
set-cf // CF = 1
subc-mba // ACC = 5, CF = 1 
shutdown