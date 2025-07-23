from collections import defaultdict

REGS = ["RA", "RB", "RC", "RD", "RE", "RF"]

encoding_map: dict[str,str] = defaultdict()
with open("parta1/encode.txt", "r") as f:
    for line in f:
        line = line.strip()
        i = line.index(':')
        encoding_map[line[:i]] = line[i+1:]

def assemble(f_name: str, conv: str):
    """ Converts each Arch242 instruction in f_name to their corresponding encoding bits/hex """
    instructions: list[list[str]] = []
    labels: dict[str, int] = {}

    mem_dest = open("parta1/mem.txt", "w")
    mem_dest.write(f"v3.0 hex bytes\n")
    with open(f_name) as file:  # pseudo-compiler
        pc = 0
        for line in file:
            line = line.replace(',', ' ')
            if '//' in line: line = line[:line.index('//')]
            line = line.split()

            if not line: continue
            if line[0] == ".byte":
                mem_dest.write(f"{line[1]}\n")

            if not line[0][0].isalpha(): continue
            if line[0].endswith(':'):
                if line[0][:-1] in labels: 
                    raise ValueError(f"Label {line[0][:-1]} already exists!")
                labels[line[0][:-1]] = pc
                line = line[1:]
                if not line: continue
            instructions.append(line)
            pc += 1
            if line[0] in ("b-bit","bnz-a","bnz-b","beqz","bnez","beqz-cf","bnez-cf","bnz-d","b","call","add","sub","and","xor","or","r4","rarb","rcrd","shutdown"):
                instructions.append(["Two-byte_line_extender"])
                pc += 1
    mem_dest.close()
    for line in instructions:
        for i in range(len(line)):
            if line[i] in labels: line[i] = f"{labels[line[i]]}"

    instr_dest = open("parta1/instr.txt", "w")
    instr_dest.write(f"v3.0 hex bytes\n")
    def writeByte(val: int):
        assert val <= 0xff
        if conv == "hex": 
            instr_dest.write(f"0x{val :02x}\n")
        if conv == "Hex": 
            instr_dest.write(f"0x{val :02X}\n")
        if conv == "bin":
            instr_dest.write(f"0b{val :08b}\n")

    for instr in instructions:
        if instr[0] == "Two-byte_line_extender": continue
        if instr[0] in encoding_map:
            val = encoding_map[instr[0]]

        if any(char.isdigit() for x in instr for char in x): # includes immediate
            if len(instr) == 2:
                val, imm = instr
            else:
                val, k, imm = instr
                k = int(k)

            val = encoding_map[val]
            imm = int(imm)
            if 'i' in val: # case for when we replace iiii with immediate
                val = val.replace("iiii", f"{imm :04b}")
            elif 'R' in val:
                val = val.replace("RRR", f"{imm :03b}")

            elif 'X' in val: # case for when we replace XXXX and YYYY with immediate. Abstracted encoding is 0101XXXX0000YYYY
                imm_bin = f"{imm :08b}"
                val = val.replace("XXXX", imm_bin[4:])
                val = val.replace("YYYY", imm_bin[:4])
            
            elif 'K' in val: # case for when we replace KKBBBAAAAAAAA with the immediates. Abstracted encoding is 100KKBBBAAAAAAAA
                k_bin = f"{k :02b}"
                imm_bin = f"{imm :011b}"
                val = val.replace("KK", k_bin)
                val = val.replace("BBBAAAAAAAA", imm_bin)

            elif val.count("B") == 3: # case for when we replace BBBAAAAAAAA with the immediates. Abstracted encoding is -----BBBAAAAAAAA
                val = val.replace("BBBAAAAAAAA", f"{imm :011b}")

            else: # case for when we replace BBBBAAAAAAAA with the immediates. Abstracted encoding is ----BBBBAAAAAAAA
                val = val.replace("BBBBAAAAAAAA", f"{imm :012b}")
    
        val = int(val, 2)
        x = val>>8
        if x: writeByte(x)
        writeByte(val & 0xff)
    instr_dest.close()

if __name__ == "__main__":
    assemble("input.asm", "hex")