# Simulate using Verilator
import sys
import subprocess

compile_command = ("wsl -e verilator --cc --binary {top} --trace --threads 4 -o sim "
"-Isource -Itestbench -Iinclude "
"-IIP/primitives/src/xeclib "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/axi "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/clocking "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/controller "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/ecc "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/ip_top "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/phy "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl/ui "
"-IIP/mig_7series_0/mig_7series_0/user_design/rtl "
"-IIP/mig_7series_0/mig_7series_0/example_design/sim "
"-sv --clk clk -DSIMULATOR ")

if __name__ == "__main__":
    print(compile_command)
    if(len(sys.argv) < 2):
        print("Usage: python simulate_verilator.py <action>")
        print("Actions:")
        print("  build <top_level>: Build the Verilator simulation")
        print("  run: Run the Verilator simulation")
        sys.exit(1)

    action = sys.argv[1]
    if action == "build":
        if(len(sys.argv) < 3):
            print("Usage: python simulate_verilator.py build <top_level>")
            sys.exit(1)
        subprocess.run(compile_command.format(top=sys.argv[2]), shell=True, check=True)
    elif action == "run":
        subprocess.run("wsl -e obj_dir/sim", shell=True, check=True)
    else:
        print("Invalid action: {}".format(action))
        sys.exit(1)
    
