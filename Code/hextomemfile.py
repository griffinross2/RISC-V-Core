def convert_intel_hex_to_vivado_mem(file_path):
    memsize = 16384
    hex_strings = []

    # Fill with zeros
    for i in range(memsize):
        hex_strings.append('00000000')

    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith(':'):
                hex_data = line[1:].strip()

                record_type = int(hex_data[6:8], 16)
                if record_type != 0:
                    # Only process data records
                    continue

                data_size = int(hex_data[0:2], 16)
                record_addr = int(hex_data[2:6], 16)

                # Loop through each byte in the record
                for i in range(data_size):
                    # Get the hex for that byte
                    data = hex_data[8 + i*2:8 + i*2 + 2]

                    addr = (record_addr + i)

                    # Write to the row floor(addr/4) at position (6-2*(addr%4)):(8-2*(addr%4))
                    hex_strings[addr//4] = hex_strings[addr//4][0:(6-2*(addr%4))] + data + hex_strings[addr//4][(8-2*(addr%4)):]

    return '\n'.join(hex_strings)

if __name__ == '__main__':
    mem = convert_intel_hex_to_vivado_mem('main.hex')
    with open('main.mem', 'w') as file:
        file.write(mem)