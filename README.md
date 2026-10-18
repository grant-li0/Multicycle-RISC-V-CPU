# Multicycle RV32I-Style Processor

A SystemVerilog processor completed for the SiliconJackets Fall 2026 Digital Design Onboarding project. The core fetches instructions from instruction SRAM, executes a subset of RV32I instructions, accesses a separate data SRAM, and halts on `ebreak`.

## Implementation

The CPU work centers on the register file, instruction decoder, execution logic, and their integration through the controller in `cpu_top.sv`, using the supplied fetch and memory interfaces.

- **32-bit datapath and registers:** 32 integer registers, two combinational read ports, and a synchronous write port. Reads of `x0` always return zero and writes to it are ignored.
- **Multicycle control:** a non-pipelined state machine sequences instruction capture, execution, memory access, and PC advancement. The fetched instruction and its PC are saved for execution.
- **Separate instruction and data memories:** each SRAM contains 1,024 32-bit words (4 KiB).
- **Memory handshakes:** loads wait for the data SRAM's ready signal before writing the destination register.
- **Branches:** equality comparison between two registers, with a sign-extended PC-relative offset. This supports the assignment's branch-against-zero requirement and comparisons between other registers.
- **Debug access:** the provided crossbar exposes instruction memory, data memory, and architectural register state to the testbench while the CPU is inactive.

### Supported instructions

| Instruction | Behavior |
| --- | --- |
| `addi` | Add a sign-extended 12-bit immediate, including negative values |
| `add`, `sub` | Register-register addition and subtraction |
| `sll`, `srl` | Logical shifts using the low five bits of the second operand |
| `lw`, `sw` | Word load/store at a register base plus signed immediate offset |
| `beq` | Branch when the two source registers are equal |
| `ebreak` | Enter the halted state; reset is required to restart |

This is an educational RV32I subset, not a complete RV32I implementation. Unsupported encodings decode as `NOP` rather than raising an illegal-instruction exception. CPU memory accesses use address bits `[11:2]`; software should use aligned addresses within the 4 KiB memory regions. The implementation does not provide alignment or bounds exceptions.

### Controller flow

```text
FETCH -> EXECUTE -> ADVANCE -> FETCH
             |
             +-- sw -> MEM_REQUEST -> ADVANCE
             +-- lw -> MEM_REQUEST -> LOAD_WAIT -> ADVANCE
             +-- ebreak -> HALTED
```

`FETCH` waits for a valid instruction. Arithmetic instructions write back during `EXECUTE`; loads write back when data is ready in `LOAD_WAIT`. `ADVANCE` releases the fetch stall and selects the next sequential or branch PC.

## Repository layout

```text
src/verilog/cpu/       CPU controller, register file, decoder, execute, fetch, types
src/verilog/           Chip integration, memory infrastructure, and testbenches
sim/behav/Include/     Simulator source lists
tests/                Assembly programs, initial data, and expected results
tests/mock/           Mock chip for testing the verification infrastructure
```

The onboarding framework supplied the chip top level, memory controller, SRAM wrapper/model, processor testbench, and CPU/fetch/register-file starting points. Those framework files are dependencies of the project; their presence does not imply original authorship of all included code. The mock chip is an infrastructure test double, not a processor implementation.

## Verification

The processor testbench loads instruction and data images through the crossbar, enables the CPU, waits for halt with a cycle limit, then compares all 32 registers and the specified data-memory words against expected values.

The included regression record reports **12 passed, 0 failed**:

`add`, `addi`, `sub`, `sll`, `srl`, `lw`, `sw`, `branch_taken`, `branch_not_taken`, `ebreak`, `complex1`, and `complex2`.

These are recorded results from the supplied submission, not a fresh simulation run. `tb_decode.sv` also contains 14 directed decode checks, including signed immediates and an unsupported instruction. `tb_fetch.sv` provides a basic standalone fetch test.

Each processor test contains:

- `program.asm`: assembly source.
- `data.hex`: initial data-memory words.
- `expected_regs.hex`: expected final values for registers `x0` through `x31`.
- `expected_data.hex`: expected final data-memory words to check.

Keep the initial and expected `.hex` files under version control: they are test fixtures, even though the original tools can generate expected results.

## Running simulations

The original environment uses Cadence Xcelium (`xrun`) and SimVision. The fetch and processor testbenches call Cadence-specific `$shm_open` and `$shm_probe` tasks.

**This submission snapshot does not contain the original Makefiles, assembler/reference-model scripts, or generated `program.hex` images.** Restore those tools from the original project to use the assignment's workflow. The following commands describe that workflow and are not runnable from this snapshot alone:

```sh
# From the repository root, after restoring the original build tools:
make generate TEST=add
make test TEST=add
make regress
make test TEST=complex2 MAX_CPU_CYCLES=2000

# Standalone decode test, using the original simulation Makefile:
cd sim/behav
make run_and_view INCLUDE_FILE_NAME=decode.include TOP=tb_decode
```

The `.include` files list sources relative to `sim/behav/`. Compile `cpu_pkg.sv` before modules that import it, and select the intended testbench as the simulation top. Keep the mock-chip source list separate from the real processor source list because both define `chip_top`.

For a replacement simulation runner, `tb_processor` accepts these plusargs:

| Argument | Purpose |
| --- | --- |
| `+PROGRAM=<path>` | Required machine-code hex image |
| `+PROGRAM_WORDS=<n>` | Required instruction count, 1–1,024 |
| `+EXPECTED_REGS=<path>` | Required expected register image |
| `+DATA=<path>` and `+DATA_WORDS=<n>` | Optional initial data image and word count |
| `+EXPECTED_DATA=<path>` and `+EXPECTED_DATA_WORDS=<n>` | Optional expected data image and word count |
| `+MAX_CPU_CYCLES=<n>` | Halt timeout; default 1,000 cycles |
| `+CROSSBAR_TIMEOUT=<n>` | Crossbar read timeout; default 20 cycles |

Hex images contain one 32-bit word per line. Instruction images must be assembled for the supported subset. CPU load/store addresses are offsets into data SRAM; the external crossbar maps instruction SRAM at `0x0000`, data SRAM at `0x1000`, and register reads at `0x2000`.
