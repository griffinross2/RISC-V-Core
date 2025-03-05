# Script to automatically simulate the CPU against a specified test case or cases

import os
import sys
import subprocess

def find_asm_files(prompt):
    asm_dir = "Assembly"

    # Get list of assembly files
    asm_files = []
    for file in os.listdir(asm_dir):
        if file.endswith(".asm"):
            asm_files.append(file)

    # For each assembly see if it starts with the prompt
    matching_files = []
    for file in asm_files:
        if file.startswith(prompt):
            matching_files.append(file)

    return matching_files

def run_test():
    if(len(sys.argv) < 2):
        print("Usage: python testasm.py <prompt>")
        sys.exit(1)

    prompt = sys.argv[1]
    matching_files = find_asm_files(prompt)
    if len(matching_files) == 0:
        print("No assembly files found for search term \"{}\"".format(prompt))
        sys.exit(1)

    for file in matching_files:
        print("Running test case: {}".format(file))

        # Assemble the file
        try:
            subprocess.run("python assemble.py \"Assembly/{}\"".format(file), shell=True, check=True)
        except Exception as e:
            print("Error assembling file: {}".format(e))
            continue

        # Emulate the file
        try:
            subprocess.run("python emulate.py \"Assembly/{}.asm\"".format('.'.join(file.split('.')[:-1])), shell=True, check=True)
        except Exception as e:
            print("Error emulating file: {}".format(e))
            continue

        # Simulate the CPU
        try:
            subprocess.run("python simulate.py system_tb".format('.'.join(file.split('.')[:-1])), shell=True, check=True)
        except Exception as e:
            print("Error simulating file: {}".format(e))
            continue

if __name__ == "__main__":
    run_test()