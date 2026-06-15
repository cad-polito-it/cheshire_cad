#!/bin/bash

module load license/default
module load mentor_graphics/questa_cdc_fml/10.3d_2
module load mentor_graphics/questa_codelink/10.4_1
module load mentor_graphics/questa_infact/10.3d_2 
module load siemens/questa_core_prime/2022.4
module load siemens/questa_vip/2022.4 

module load synopsys/vcs/2024.09-SP1
module load synopsys/verdi/2024.09-SP1
module load synopsys/zoix/2024.09-SP1

#module load synopsys/vcs/2023.12-SP1
#module load synopsys/verdi/2023.12-SP1
module load compiler/riscv/wally


# Cheshire base
export CHS_ROOT="$HOME/rigoletto/cheshire_cad"

# Bender
export BENDER="$CHS_ROOT/bender"
#export PATH="$HOME/.cargo/bin:$PATH"
source .venv/bin/activate


