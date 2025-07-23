import pyxel as px
from typing import Literal

CELL_SIZE = 15
ROWS = 10
COLS = 20
DISPLAY_HEIGHT = ROWS * CELL_SIZE + CELL_SIZE
DISPLAY_WIDTH = COLS * CELL_SIZE + 1
PLAY_TYPE: Literal["Smooth", "Single", "Sexy"] = "Smooth" 
SNAKE_SPEED = 10 # Lower value is faster
class Emulator:
    def __init__(self, f_name: str):
        self.enabled = True
        self.regs = [0]*5   
        self.mem = [0]*256   
        self.pa: int = 0
        self.pc: int = 0
        self.temp: int = 0
        self.acum: int = 0  
        self.cf: int = 0
        self.ioa: int = 0   
        self.cycle: int = 0
        self.frame_count: int = 0
        self.instructions: list[list[str]] = []
        self.labels: dict[str, int] = {}
        with open(f_name) as file: 
            pc = byte = 0
            for line in file:
                line = line.replace('*', '')
                line = line.replace(',', ' ')
                line = line.replace('-', '_')
                if '//' in line: line = line[:line.index('//')]
                line = line.split()

                if not line: continue
                if  line[0] == ".byte":
                    self.mem[byte] = int(line[1], 16)
                    byte += 1

                if not line[0][0].isalpha(): continue
                if line[0] in ("and", "or"): line[0] += '_'
                if line[0].endswith(':'):
                    if line[0][:-1] in self.labels: 
                        raise ValueError(f"Label {line[0][:-1]} already exists!")
                    self.labels[line[0][:-1]] = pc
                    line = line[1:]
                    if not line: continue
                self.instructions.append(line)
                pc += 1
                if line[0] in ("b_bit","bnz_a","bnz_b","beqz","bnez","beqz_cf","bnez_cf","bnz_d","b","call","add","sub","and_","xor","or_","r4","rarb","rcrd","shutdown"):
                    self.instructions.append(["Two-byte_line_extender"])
                    pc += 1
        for line in self.instructions:
            for i in range(len(line)):
                if line[i] in self.labels: line[i] = f"{self.labels[line[i]]}"
        
        px.init(DISPLAY_WIDTH, DISPLAY_HEIGHT, title = "ARCH 242 Snake Game")
        px.run(self.update, self.draw)
            
    def update(self):    
        if px.btnp(px.KEY_Q):
            px.quit()
        self.keys_pressed: list[str] = []
        if px.btn(px.KEY_W): 
            self.keys_pressed.append("W")
        if px.btn(px.KEY_S): 
            self.keys_pressed.append("S")
        if px.btn(px.KEY_A): 
            self.keys_pressed.append("A")
        if px.btn(px.KEY_D): 
            self.keys_pressed.append("D")
        
        if not self.enabled: return
        if PLAY_TYPE == 'Smooth':
            if self.ioa == 0:
                self.ioa = (px.btn(px.KEY_W) << 0) + (px.btn(px.KEY_S) << 1) + (px.btn(px.KEY_A) << 2) + (px.btn(px.KEY_D) << 3)
            self.frame_count += 1
            if self.frame_count % SNAKE_SPEED != 0:
                return
            while self.enabled:
                self.emulate()
                if self.pc == self.labels["RESET"]:
                    break

            self.ioa = 0
        if PLAY_TYPE == 'Single':
            if px.btnp(px.KEY_T): self.emulate()
            if px.btn(px.KEY_KP_PLUS): self.emulate()
            if px.btn(px.KEY_KP_MULTIPLY):
                for _ in range(10): self.emulate()
            self.ioa = (px.btn(px.KEY_W) << 0) + (px.btn(px.KEY_S) << 1) + (px.btn(px.KEY_A) << 2) + (px.btn(px.KEY_D) << 3)
        if PLAY_TYPE == "Sexy":   
            self.ioa = (px.btn(px.KEY_W) << 0) + (px.btn(px.KEY_S) << 1) + (px.btn(px.KEY_A) << 2) + (px.btn(px.KEY_D) << 3)
            self.emulate()
        
        
    def draw(self): # Output
        px.cls(px.COLOR_GREEN)
        for r in range(ROWS):
            for c in range(COLS):
                val = self.mem[192 + (r*COLS+c)//4]
                led = (val >> c%4) & 0x1
                px.rect(CELL_SIZE*c+1, CELL_SIZE*r+1, CELL_SIZE-1, CELL_SIZE-1, led*px.COLOR_WHITE)
                # px.text(CELL_SIZE*c+2, CELL_SIZE*r+2, f"{192 + (r*COLS+c)//4}", px.COLOR_GRAY)
        # px.text(2, DISPLAY_HEIGHT - 7, f"Cycle: {self.cycle}, PC:
        #  {self.pc}, Key-pressed: {','.join(self.keys_pressed)}, IOA: {self.ioa}, SIZE: {self.mem[90]+self.mem[91]}", px.COLOR_WHITE)
        px.text(DISPLAY_WIDTH - 50, DISPLAY_HEIGHT - 7, f"Score: {self.mem[242]}/15", px.COLOR_WHITE)
                
    def emulate(self):
        global cntr
        self.cycle+=1
        if len(self.instructions) <= self.pc: return
        instr = self.instructions[self.pc]
        f = self.__getattribute__(f"{instr[0]}")
        self.pc = f(*instr[1:])
        
        # print(instr)
        # print(f"{self.regs}, acc: {self.acum}, cf: {self.cf}, temp: {self.temp}, pc: {self.pc}, cycle: {self.cycle}")
        # else: 
        # if PLAY_TYPE == "Single":
        #     print(instr)
        #     print(f"{self.regs}, acc: 0b{self.acum}, cf: {self.cf}, temp: {self.temp}, pc: {self.pc}, cycle: {self.cycle}")
        # else: 
        #     print(instr)
        #     print(f"{self.regs}, acc: 0b{self.acum}, cf: {self.cf}, temp: {self.temp}, pc: {self.pc}, cycle: {self.cycle}, mem255:256 {self.mem[254], self.mem[255]}")
        #     print()

    def rot(self, n: int, bits: int) -> int:
        val = (((n & 1) << bits) | n) >> 1
        return val & ((1 << bits) - 1)

    def rot_r(self):
        self.acum = self.rot(self.acum, 4)
        return self.pc + 1

    def rot_l(self):
        for _ in range(3):
            self.acum = self.rot(self.acum, 4)
        return self.pc + 1

    def rot_rc(self):
        cfacum = (self.cf << 4) | self.acum
        cfacum = self.rot(cfacum, 5)
        self.cf = (cfacum >> 4) & 0x1
        self.acum = cfacum & 0xf
        return self.pc + 1
                
    def rot_lc(self):
        cfacum = (self.cf << 4) | self.acum
        for _ in range(4): cfacum = self.rot(cfacum, 5)
        self.cf = (cfacum >> 4) & 0x1
        self.acum = cfacum & 0xf            
        return self.pc + 1

    def addr_rbra(self):
        return ((self.regs[1]<<4) | self.regs[0]) & 0xff

    def addr_rdrc(self):
        return ((self.regs[3]<<4) | self.regs[2]) & 0xff

    def from_mba(self):
        addr = self.addr_rbra()
        self.acum = self.mem[addr] & 0xf
        return self.pc + 1

    def to_mba(self):
        addr = self.addr_rbra()
        self.mem[addr] = self.acum & 0xf
        return self.pc + 1
        
    def from_mdc(self):
        addr = self.addr_rdrc()
        self.acum = self.mem[addr] & 0xf
        return self.pc + 1

    def to_mdc(self):
        addr = self.addr_rdrc()
        self.mem[addr] = self.acum & 0xf
        return self.pc + 1

    def addc_mba(self):
        addr = self.addr_rbra()
        val = (self.acum & 0xf) + (self.mem[addr] & 0xf) + (self.cf & 0x1)
        self.acum = val & 0xf
        self.cf = (val>>4) & 0x1
        return self.pc + 1
        
    def add_mba(self):
        addr = self.addr_rbra()
        val = (self.acum & 0xf) + (self.mem[addr] & 0xf)
        self.acum = val & 0xf
        self.cf = (val>>4) & 0x1 
        return self.pc + 1
        
    def subc_mba(self):
        addr = self.addr_rbra()
        val = (self.acum &0xf)- (self.mem[addr] & 0xf) + (self.cf & 0x1)
        self.acum = val & 0xf
        self.cf = 1 if val < 0 else 0
        return self.pc + 1

    def sub_mba(self):
        addr = self.addr_rbra()
        val = (self.acum & 0xf) - (self.mem[addr] & 0xf)
        self.acum = val & 0xf
        self.cf = 1 if val < 0 else 0
        return self.pc + 1

    def inc_mba(self):
        addr = self.addr_rbra()
        self.mem[addr] = (self.mem[addr]+1)&0xf
        return self.pc + 1

    def dec_mba(self):
        addr = self.addr_rbra()
        self.mem[addr] = (self.mem[addr]-1)&0xf
        return self.pc + 1

    def inc_mdc(self):
        addr = self.addr_rdrc()
        self.mem[addr] = (self.mem[addr]+1)&0xf
        return self.pc + 1

    def dec_mdc(self):
        addr = self.addr_rdrc()
        self.mem[addr] = (self.mem[addr]-1)&0xf
        return self.pc + 1

    def inc_reg(self, reg: str):
        reg_idx = int(reg)
        self.regs[reg_idx] = (self.regs[reg_idx] + 1) % 16
        return self.pc + 1

    def dec_reg(self, reg: str):    
        reg_idx  = int(reg)
        self.regs[reg_idx] = (self.regs[reg_idx] - 1) % 16
        return self.pc + 1

    def and_ba(self):
        self.acum = self.acum & self.mem[self.addr_rbra()]
        return self.pc + 1

    def xor_ba(self):
        self.acum = self.acum ^ self.mem[self.addr_rbra()]
        return self.pc + 1

    def or_ba(self):
        self.acum = self.acum | self.mem[self.addr_rbra()]
        return self.pc + 1

    def and_mba(self):
        self.mem[self.addr_rbra()] = self.acum & self.mem[self.addr_rbra()]
        return self.pc + 1

    def xor_mba(self):
        self.mem[self.addr_rbra()] = self.acum ^ self.mem[self.addr_rbra()]
        return self.pc + 1

    def or_mba(self):
        self.mem[self.addr_rbra()] = self.acum | self.mem[self.addr_rbra()]
        return self.pc + 1

    def to_reg(self, reg: str):
        reg_idx = int(reg)
        self.regs[reg_idx] = self.acum
        return self.pc + 1

    def from_reg(self, reg: str):
        reg_idx = int(reg)
        self.acum = self.regs[reg_idx]
        return self.pc + 1

    def clr_cf(self):
        self.cf = 0
        return self.pc + 1

    def set_cf(self):
        self.cf = 1
        return self.pc + 1

    def set_ei(self):
        self.ei = 1
        return self.pc + 1

    def clr_ei(self):
        self.ei = 0
        return self.pc + 1

    def ret(self):
        newpc = self.pc - (self.pc % (1<<12))
        newpc += self.temp % (1<<12)
        self.temp = 0
        return newpc 

    def from_ioa(self):
        self.acum = self.ioa
        return self.pc + 1 

    def inc(self):
        self.acum += 1
        return self.pc + 1
    
    def bcd(self):
        if self.acum >= 10 or self.cf == 1:
            self.acum += 6
            self.cf = 1
        return self.pc + 1
    
    def shutdown(self):
        # self.cycle += 1
        self.enabled = False
        return self.pc + 2

    def nop(self):
        return self.pc + 1
        
    def dec(self):
        self.acum = (self.acum - 1) & 0xf # Discard msb if overflow
        return self.pc + 1

    def add(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.acum = (self.acum + imm) & 0xf
        return self.pc + 2
    
    def sub(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.acum = (self.acum - imm) & 0xf
        return self.pc + 2
        
    def and_(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.acum = (self.acum & imm) & 0xf
        return self.pc + 2
    
    def xor(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.acum = (self.acum ^ imm) & 0xf
        return self.pc + 2

    def or_(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.acum = (self.acum | imm) & 0xf
        return self.pc + 2

    def r4(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.regs[4] = imm
        return self.pc + 2

    def rarb(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.regs[1] = imm >> 4
        self.regs[0] = imm & 15
        return self.pc + 2

    def rcrd(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.regs[3] = imm >> 4
        self.regs[2] = imm & 15
        return self.pc + 2
        
    def acc(self, sim: str):
        imm = int(sim)
        self.acum = imm
        return self.pc + 1

    def b_bit(self, dk: str, sim: str):
        # self.cycle += 1
        imm,k = int(sim), int(dk)
        if (self.acum >> k) & 1:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def bnz_a(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.regs[0] != 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def bnz_b(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.regs[1] != 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def beqz(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.acum != 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def bnez(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.acum == 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def beqz_cf(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.cf == 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def bnez_cf(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.cf != 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def bnz_d(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        if self.regs[3] != 0:
            return (self.pc & 0b1111100000000000) | (imm & 0b11111111111)
        return self.pc + 2

    def b(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        return (self.pc & 0b1111000000000000) | (imm & 0b111111111111)

    def call(self, sim: str):
        # self.cycle += 1
        imm = int(sim)
        self.temp = self.pc + 2
        return (self.pc & 0b1111000000000000) | (imm & 0b111111111111)

from sys import argv

if __name__ == "__main__":
    if len(argv) < 2: raise ValueError("No assembly file given!")
    asm = argv[1]
    Emulator(asm)
