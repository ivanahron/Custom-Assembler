START:
    call INITIALIZE
    rcrd 250 
    acc 8
    to-mdc
    call GEN_FOOD
    
RESET:
    rcrd 91
    from-mdc
    sub 3
    bnez EXIT

    rcrd 160 //GET HEAD
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0

    rcrd 250
    clr-cf
    from-ioa
    bnez MOVE_HEADING

CHECK_W: // check w pressed
    from-ioa // get input
    sub 1 // check if input is W
    beqz CHECK_S // if input is NOT W, check if input is S
    from-mdc // input is W, now check if heading is S
    sub 2 // check if heading is S
    beqz DO_W // if not heading S, do W
    b MOVE_HEADING // if heading is S, continue heading S

CHECK_S: // check s pressed
    from-ioa 
    sub 2 
    beqz CHECK_A
    from-mdc
    sub 1
    beqz DO_S
    b MOVE_HEADING

CHECK_A: // check a pressed
    from-ioa 
    sub 4 
    beqz CHECK_D
    from-mdc
    sub 8
    beqz DO_A
    b MOVE_HEADING

CHECK_D: // check d pressed
    from-ioa 
    sub 8 
    beqz MOVE_HEADING
    from-mdc
    sub 4
    beqz DO_D
    b MOVE_HEADING

b RESET // reset

MOVE_HEADING:
    from-mdc
    sub 1
    bnez DO_W

    from-mdc
    sub 2
    bnez DO_S

    from-mdc
    sub 4
    bnez DO_A

    from-mdc
    sub 8
    bnez DO_D

b RESET

DO_W: 
    rcrd 250
    acc 1
    to-mdc
    rcrd 162
    from-mdc
    to-reg 4

from-reg 0
sub 15
bnez DEC_RA
from-reg 0
sub 5
bcd
beqz-cf DEC_RA
dec*-reg 1

DEC_RA: 
    from-reg 0
    sub 5
    to-reg 0

from-reg 1 //GET HEAD
rcrd 160
to-mdc
from-reg 0
rcrd 161
to-mdc
call CHECK_BOUNDARY_VERT

rcrd 52
from-mdc
rarb 160
xor-ba
beqz NOT_FOOD_W

rcrd 53
from-mdc
rarb 161
xor-ba
beqz NOT_FOOD_W

rcrd 162
from-mdc
sub 2
beqz NOT_FOOD_W

rcrd 160
from-mdc
to-reg 1
rcrd 161
from-mdc
to-reg 0
from-reg 4 // ACC = RE
to-mba // ACC = RE - mem[RB:RA] 
b DONE_MOVE

NOT_FOOD_W:
rcrd 160
from-mdc
to-reg 1
rcrd 161
from-mdc
to-reg 0
from-mba

from-reg 4 
and-ba
to-mba
from-reg 4
sub-mba
bnez RESTART

from-reg 4
to-mba

b DONE_MOVE

DO_S: 
    rcrd 250
    acc 2
    to-mdc
    rcrd 162
    from-mdc
    to-reg 4 // Store prev position val to RE

from-reg 0 
bnez INC_RA
add 15 
bcd 
beqz-cf INC_RA
inc*-reg 1 

INC_RA: 
    from-reg 0 
    add 5 
    to-reg 0


from-reg 1 
rcrd 160
to-mdc 
from-reg 0
rcrd 161
to-mdc
call CHECK_BOUNDARY_VERT

rcrd 52
from-mdc
rarb 160
xor-ba
beqz NOT_FOOD_S

rcrd 53
from-mdc
rarb 161
xor-ba
beqz NOT_FOOD_S

rcrd 162
from-mdc
sub 2
beqz NOT_FOOD_S

rcrd 160
from-mdc
to-reg 1
rcrd 161
from-mdc
to-reg 0
from-reg 4 // ACC = RE
to-mba // ACC = RE - mem[RB:RA] 
b DONE_MOVE

NOT_FOOD_S:
rcrd 160
from-mdc
to-reg 1
rcrd 161
from-mdc
to-reg 0
from-mba

from-reg 4 
and-ba
to-mba
from-reg 4
sub-mba
bnez RESTART

from-reg 4
to-mba
b DONE_MOVE

DO_A:
    from-reg 1 //STORE HEAD
    rcrd 160
    to-mdc
    from-reg 0
    rcrd 161
    to-mdc
    call CHECK_BOUNDARY_LEFT

    rcrd 250
    acc 4
    to-mdc
    
    rcrd 162
    from-mdc
    sub 1
    bnez CHANGE_BIT0_A
    
    from-mdc
    sub 2
    bnez CHANGE_BIT1_A

    from-mdc
    sub 4
    bnez CHANGE_BIT2_A

    from-mdc
    sub 8
    bnez CHANGE_BIT3_A

    CHANGE_BIT0_A:
    dec*-reg 0
    from-reg 0
    sub 15
    beqz SKIP_CB0_A
    dec*-reg 1
    SKIP_CB0_A:
    acc 8
    b DONE_A

    CHANGE_BIT1_A:
    acc 1
    b DONE_A

    CHANGE_BIT2_A:
    acc 2
    b DONE_A

    CHANGE_BIT3_A:
    acc 4
    b DONE_A

DONE_A:
    rcrd 162
    to-mdc
    rcrd 160
    from-reg 1 
    to-mdc
    rcrd 161
    from-reg 0
    to-mdc

    rcrd 162
    from-mdc
    and-ba
    bnez NO_COLLISION_A
    
    rcrd 52
    from-mdc
    rarb 160
    xor-ba
    beqz RESTART //lit LED is not food, therefore a piece of the snake's body

    rcrd 53
    from-mdc
    rarb 161
    xor-ba
    beqz RESTART

    rcrd 162
    from-mdc
    sub 2
    beqz RESTART  
    
    NO_COLLISION_A: call GET_STORED_POS

    to-mba
    b DONE_MOVE

DO_D:
    from-reg 1 //GET HEAD
    rcrd 160
    to-mdc
    from-reg 0
    rcrd 161
    to-mdc
    call CHECK_BOUNDARY_RIGHT

    rcrd 250
    acc 8
    to-mdc

    rcrd 162
    from-mdc
    sub 1
    bnez CHANGE_BIT0_D
    
    from-mdc
    sub 2
    bnez CHANGE_BIT1_D

    from-mdc
    sub 4
    bnez CHANGE_BIT2_D

    from-mdc
    sub 8
    bnez CHANGE_BIT3_D

    CHANGE_BIT0_D:
    acc 2
    b DONE_D

    CHANGE_BIT1_D:
    acc 4
    b DONE_D

    CHANGE_BIT2_D:
    acc 8
    b DONE_D

    CHANGE_BIT3_D:
    inc*-reg 0
    from-reg 0
    beqz SKIP_CB3_D
    inc*-reg 1
    SKIP_CB3_D:
    acc 1
    b DONE_D

DONE_D:
    rcrd 162
    to-mdc
    rcrd 160
    from-reg 1 
    to-mdc
    rcrd 161
    from-reg 0
    to-mdc

    rcrd 162
    from-mdc
    and-ba
    bnez NO_COLLISION_D
    
    rcrd 52
    from-mdc
    rarb 160
    xor-ba
    beqz RESTART

    rcrd 53
    from-mdc
    rarb 161
    xor-ba
    beqz RESTART

    rcrd 162
    from-mdc
    sub 2
    beqz RESTART  
    
    NO_COLLISION_D: call GET_STORED_POS
    to-mba
    b DONE_MOVE
    

STORE_NEXT_POS:
    from-reg 1 //GET HEAD
    rcrd 160
    to-mdc
    from-reg 0
    rcrd 161
    to-mdc
    rcrd 162
    from-mba
    to-mdc 
    ret

GET_STORED_POS:
    rcrd 160
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0
    rcrd 162
    from-mdc
    ; to-mba 
    ret

DONE_MOVE:
    call STORE_NEXT_POS

    call CHECK_EAT
    rcrd 54
    from-mdc
    sub 1
    beqz DO_UPDATE
    call GEN_FOOD
    call GROW_BODY
    b SKIP_UPDATE

    DO_UPDATE:
    call GET_STORED_POS
    call LOOP_UPDATE

    SKIP_UPDATE:
    call GET_STORED_POS
    call LOAD_SNAKE
    call LOAD_FOOD
    b RESET

CHECK_BOUNDARY_VERT:
    rcrd 160 //GET HEAD
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0

    from-reg 1
    sub 11
    bnez RESTART  // below address 192 = 0xc0
    from-reg 1
    sub 15
    bnez CHECK_RA 
    ret // below address 240 = 0xf0
    CHECK_RA: from-reg 0
    and 14  // get upper three bits
    rot-r   // shift right
    beqz RESTART // above address 241 = 0xf1
    ret

CHECK_BOUNDARY_LEFT: // 
    rcrd 160 //GET HEAD
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0

    from-reg 1
    sub 12
    bnez CHECK_FIRST_SET

    from-reg 1
    sub 13
    bnez CHECK_SECOND_SET

    from-reg 1
    sub 14
    bnez CHECK_THIRD_SET
    ret

    CHECK_FIRST_SET:
        from-reg 0
        bnez CHECK_BIT
        from-reg 0
        sub 5
        bnez CHECK_BIT
        from-reg 0
        sub 10
        bnez CHECK_BIT
        from-reg 0
        sub 15
        bnez CHECK_BIT
        ret 

    CHECK_SECOND_SET:
        from-reg 0
        sub 4
        bnez CHECK_BIT
        from-reg 0
        sub 9
        bnez CHECK_BIT
        from-reg 0
        sub 14
        bnez CHECK_BIT
        ret

    CHECK_THIRD_SET:
        from-reg 0
        sub 3
        bnez CHECK_BIT
        from-reg 0
        sub 8
        bnez CHECK_BIT
        from-reg 0
        sub 13
        bnez CHECK_BIT
        ret

    CHECK_BIT:
        rcrd 162
        from-mdc
        sub 1
        bnez RESTART
        ret
    
CHECK_BOUNDARY_RIGHT:
    rcrd 160 //GET HEAD
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0

    from-reg 1
    sub 12
    bnez CHECK_FIRST_SET_R

    from-reg 1
    sub 13
    bnez CHECK_SECOND_SET_R

    from-reg 1
    sub 14
    bnez CHECK_THIRD_SET_R

    from-reg 1
    sub 15
    bnez CHECK_LAST
    ret

    CHECK_FIRST_SET_R:
        from-reg 0
        sub 4
        bnez CHECK_BIT_R
        from-reg 0
        sub 9
        bnez CHECK_BIT_R
        from-reg 0
        sub 14
        bnez CHECK_BIT_R
        ret 

    CHECK_SECOND_SET_R:
        from-reg 0
        sub 3
        bnez CHECK_BIT_R
        from-reg 0
        sub 8
        bnez CHECK_BIT_R
        from-reg 0
        sub 13
        bnez CHECK_BIT_R
        ret

    CHECK_THIRD_SET_R:
        from-reg 0
        sub 2
        bnez CHECK_BIT_R
        from-reg 0
        sub 7
        bnez CHECK_BIT_R
        from-reg 0
        sub 12
        bnez CHECK_BIT_R
        ret

    CHECK_LAST:
        from-reg 0
        sub 1
        bnez CHECK_BIT_R
        ret

    CHECK_BIT_R:
        rcrd 162
        from-mdc
        sub 8
        bnez RESTART
        ret

INITIALIZE:
    rcrd 254 // initial seed1
    from-mdc
    rcrd 50 // seed1
    to-mdc

    rcrd 255
    from-mdc
    rcrd 51 // seed2
    to-mdc
    
    rcrd 90
    acc 3 // initial body size
    to-mdc
    
    // POS OF BODY 2 (218) <- TAIL
    rcrd 100 
    acc 13
    to-mdc
    rcrd 101 
    acc 10
    to-mdc
    rcrd 102 
    acc 4
    to-mdc

    // load body 2
    rcrd 100
    from-mdc
    to-reg 1
    rcrd 101
    from-mdc
    to-reg 0
    rcrd 102
    from-mdc
    or*-mba
    // after load mem[218] = 4

    // POS OF BODY 1 (218)
    rcrd 103 
    acc 13
    to-mdc
    rcrd 104
    acc 10
    to-mdc
    rcrd 105
    acc 8
    to-mdc

    // load body 1 
    rcrd 103
    from-mdc
    to-reg 1
    rcrd 104
    from-mdc
    to-reg 0
    rcrd 105 
    from-mdc 
    or*-mba
    
    // HEAD
    rcrd 106
    acc 13
    to-mdc
    rcrd 107
    acc 11
    to-mdc
    rcrd 108
    acc 1
    to-mdc

    rcrd 160
    acc 13
    to-mdc
    rcrd 161
    acc 11
    to-mdc
    rcrd 162
    acc 1
    to-mdc

    // load head
    rcrd 160
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0
    rcrd 162
    from-mdc
    or*-mba

    //next head
    rcrd 163
    acc 6
    to-mdc
    rcrd 164
    acc 13
    to-mdc
    ret


LOOP_UPDATE:
    rcrd 100
    from-mdc
    to-reg 1
    rcrd 101
    from-mdc
    to-reg 0 
    rcrd 102 
    acc 0
    and*-mba

    // LOOP UB
    rcrd 90
    from-mdc
    sub 1
    to-reg 4
    rcrd 100
    LOOP1:
        from-reg 4
        bnez EXIT_LOOP1

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz SKIP1
        inc*-reg 1
        
        SKIP1: inc*-reg 0
        from-reg 0
        beqz SKIP2
        inc*-reg 1

        SKIP2: inc*-reg 0
        from-reg 0
        beqz UPDATE_V1
        inc*-reg 1

        UPDATE_V1: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b LOOP1

    EXIT_LOOP1: rcrd 91
    from-mdc
    bnez UPDATE_LOOP1
    rcrd 91
    from-mdc
    to-reg 4

    from-reg 1
    to-reg 3
    from-reg 0
    to-reg 2

    L1:
        from-reg 4
        bnez UPDATE_LOOP1

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz S1
        inc*-reg 1
        
        S1: inc*-reg 0
        from-reg 0
        beqz S2
        inc*-reg 1

        S2: inc*-reg 0
        from-reg 0
        beqz UV1
        inc*-reg 1

        UV1: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b L1
        
    UPDATE_LOOP1: rcrd 160
    from-mdc
    to-mba




    // LOOP LB
    rcrd 90
    from-mdc
    sub 1
    to-reg 4
    rcrd 101
    LOOP2:
        from-reg 4
        bnez EXIT_LOOP2

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz SKIP3
        inc*-reg 1
        
        SKIP3: inc*-reg 0
        from-reg 0
        beqz SKIP4
        inc*-reg 1

        SKIP4: inc*-reg 0
        from-reg 0
        beqz UPDATE_V2
        inc*-reg 1

        UPDATE_V2: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b LOOP2

    EXIT_LOOP2: rcrd 91
    from-mdc
    bnez UPDATE_LOOP2
    rcrd 91
    from-mdc
    to-reg 4

    from-reg 1
    to-reg 3
    from-reg 0
    to-reg 2
    
    L2:
        from-reg 4
        bnez UPDATE_LOOP2

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz S3
        inc*-reg 1
        
        S3: inc*-reg 0
        from-reg 0
        beqz S4
        inc*-reg 1

        S4: inc*-reg 0
        from-reg 0
        beqz UV2
        inc*-reg 1

        UV2: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b L2


    UPDATE_LOOP2: rcrd 161
    from-mdc
    to-mba





    // LOOP BIT
    rcrd 90
    from-mdc
    sub 1
    to-reg 4
    rcrd 102
    LOOP3:
        from-reg 4
        bnez EXIT_LOOP3

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz SKIP5
        inc*-reg 1
        
        SKIP5: inc*-reg 0
        from-reg 0
        beqz SKIP6
        inc*-reg 1

        SKIP6: inc*-reg 0
        from-reg 0
        beqz UPDATE_V3
        inc*-reg 1

        UPDATE_V3: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b LOOP3

    EXIT_LOOP3: rcrd 91
    from-mdc
    bnez UPDATE_LOOP3
    rcrd 91
    from-mdc
    to-reg 4

    from-reg 1
    to-reg 3
    from-reg 0
    to-reg 2

    L3:
        from-reg 4
        bnez UPDATE_LOOP3

        from-reg 3
        to-reg 1
        from-reg 2
        to-reg 0

        inc*-reg 0
        from-reg 0
        beqz S5
        inc*-reg 1
        
        S5: inc*-reg 0
        from-reg 0
        beqz S6
        inc*-reg 1

        S6: inc*-reg 0
        from-reg 0
        beqz UV3
        inc*-reg 1

        UV3: from-mba
        to-mdc

        from-reg 1
        to-reg 3
        from-reg 0
        to-reg 2

        dec*-reg 4
        b L3

    UPDATE_LOOP3: rcrd 162
    from-mdc
    to-mba
    ret



    // LOAD SNAKE
    LOAD_SNAKE:
    rcrd 90
    from-mdc
    to-reg 4
    rcrd 100
    LOOP_LOAD_BODY:
        from-reg 4
        bnez LOOP_LOAD_BODY_EXIT

        from-mdc
        to-reg 1
        
        inc*-reg 2
        from-reg 2
        beqz SKIP_LOOP2_INC_RD1
        inc*-reg 3
        SKIP_LOOP2_INC_RD1:

        from-mdc
        to-reg 0

        inc*-reg 2
        from-reg 2
        beqz SKIP_LOOP2_INC_RD2
        inc*-reg 3
        SKIP_LOOP2_INC_RD2:

        from-mdc
        or*-mba

        inc*-reg 2
        from-reg 2
        beqz SKIP_LOOP2_INC_RD3
        inc*-reg 3
        SKIP_LOOP2_INC_RD3:

        dec*-reg 4
        b LOOP_LOAD_BODY
    LOOP_LOAD_BODY_EXIT: 
    rcrd 91
    from-mdc
    bnez RET

    rcrd 91
    from-mdc
    to-reg 4
    rcrd 145
    LLB:
        from-reg 4
        bnez RET

        from-mdc
        to-reg 1
        
        inc*-reg 2
        from-reg 2
        beqz SLIR1
        inc*-reg 3
        SLIR1: from-mdc
        to-reg 0

        inc*-reg 2
        from-reg 2
        beqz SLIR2
        inc*-reg 3
        SLIR2: from-mdc
        or*-mba

        inc*-reg 2
        from-reg 2
        beqz SLIR3
        inc*-reg 3
        SLIR3: dec*-reg 4
        b LLB
    RET: ret

GEN_FOOD:
    rcrd 160
    from-mdc
    to-reg 1
    rcrd 161
    from-mdc
    to-reg 0

    rcrd 97
    from-reg 1
    to-mdc
    rcrd 98
    from-reg 0
    to-mdc
    rcrd 99
    from-mba
    to-mdc


    rcrd 0
    rarb 50
    from-mba
    rot-r // pseudorandom logic
    rot-r
    xor-ba
    rot-r
    rot-r
    xor 11

    xor-ba
    rarb 53
    to-mba
    to-reg 2 // RC = random lower nibble
    
    rarb 51
    from-mba
    rot-r // pseudorandom logic
    rot-r
    xor-ba
    rot-r
    rot-r
    xor 4
    
    xor-ba
    or 12 
    rarb 52
    to-mba // save 
    to-reg 3 // RD = random upper nibble

    from-mdc 
    beqz RETRY // generate another number if mem[rd:rc] != 0

    from-reg 3
    xor 15
    beqz SET_LED
    from-reg 2
    and 1
    to-reg 2
    
SET_LED:
    acc 2
    to-mdc

NEXT_SEED:
    rarb 51
    from-mba
    add 8
    to-mba
    rarb 50
    from-mba
    add 1
    to-mba

    rcrd 97 
    from-mdc 
    to-reg 1
    rcrd 98
    from-mdc
    to-reg 0
    rcrd 99
    from-mdc
    to-mba
    ret

RETRY:
    rarb 51
    from-mba
    add 8
    to-mba
    rarb 50
    from-mba
    add 1
    to-mba
    b GEN_FOOD

LOAD_FOOD:
    rcrd 53
    from-mdc
    to-reg 0
    rcrd 52
    from-mdc
    to-reg 1

    acc 2
    or*-mba
    ret

CHECK_EAT:
    rcrd 52
    from-mdc
    rarb 160
    xor-ba
    beqz NO_EAT

    rcrd 53
    from-mdc
    rarb 161
    xor-ba
    beqz NO_EAT

    rcrd 162
    from-mdc
    sub 2
    beqz NO_EAT

    rcrd 242
    inc*-mdc

    rcrd 90
    from-mdc
    sub 15
    bnez ADD_TO_91
    inc*-mdc
    rcrd 54
    acc 1
    to-mdc
    ret

    ADD_TO_91: rcrd 91
    inc*-mdc

    rcrd 54
    acc 1
    to-mdc
    ret

    NO_EAT: rcrd 54
    acc 0
    to-mdc
    ret
    
GROW_BODY:
    rcrd 163
    from-mdc
    to-reg 1

    rcrd 164
    from-mdc
    to-reg 0

    rcrd 160
    from-mdc
    to-mba

    inc*-reg 0
    from-reg 0
    beqz GROW_CONT1
    inc*-reg 1

    GROW_CONT1: rcrd 161
    from-mdc
    to-mba

    inc*-reg 0
    from-reg 0
    beqz GROW_CONT2
    inc*-reg 1

    GROW_CONT2: rcrd 162
    from-mdc
    to-mba
    
    inc*-reg 0
    from-reg 0
    beqz GROW_CONT3
    inc*-reg 1

    GROW_CONT3: rcrd 163 // next head RB
    from-reg 1
    to-mdc

    rcrd 164 // next head RA
    from-reg 0
    to-mdc
    ret

RESTART:
    rcrd 253 // skip global seed [254:255]
    loop_mem:
    from-reg 3 // check if RD == 0
    beqz cont
    from-reg 2 // check if RC == 0
    bnez loop_exit

    cont: acc 0
    to-mdc
    from-reg 2
    beqz skp
    dec*-reg 3
    skp: nop
    dec*-reg 2
    b loop_mem

    loop_exit: acc 0
    to-mdc
    acc 0
    to-reg 0
    to-reg 1
    to-reg 2
    to-reg 3
    to-reg 4
    clr-cf

    rcrd 254
    from-mdc
    add 1
    to-mdc

    b START

EXIT:
    shutdown