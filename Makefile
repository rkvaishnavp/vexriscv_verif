# ==========================================================
# Makefile for VexRiscv Verification Framework
# Includes RTL, Whisper, and RISC-V DV integration
# Author: Vaishnav RKV
# Updated: 2025-11-01
# ==========================================================

.PHONY: all deps rtl-gen whisper riscv-dv riscv-dv-gen style-check clean check help

# -----------------------------
# Default target
# -----------------------------
all: deps rtl-gen

# -----------------------------
# [1] Dependencies: Java + sbt + Python + Build Tools
# -----------------------------
deps:
	@echo "=== [Deps] Checking dependencies ==="
	@if command -v java >/dev/null 2>&1 && java -version 2>&1 | grep -q "1\.8"; then \
		echo "[OK] Java 8 already installed."; \
	else \
		echo "[INFO] Installing OpenJDK 8..."; \
		sudo apt-get update -qq && sudo apt-get install -y openjdk-8-jdk; \
	fi
	@if command -v sbt >/dev/null 2>&1; then \
		echo "[OK] sbt already installed."; \
	else \
		echo "[INFO] Installing sbt..."; \
		sudo apt-get install -y curl apt-transport-https gnupg; \
		echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list; \
		curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add -; \
		sudo apt-get update -qq && sudo apt-get install -y sbt; \
	fi
	@if command -v python3 >/dev/null 2>&1; then \
		echo "[OK] Python3 installed."; \
	else \
		echo "[INFO] Installing Python3..."; \
		sudo apt-get install -y python3 python3-pip; \
	fi
	@echo "=== [Deps] Done ==="

# -----------------------------
# [2] RTL generation
# -----------------------------
rtl-gen:
	@echo "=== [RTL] Generating VexRiscv RTL ==="
	@if [ -d "rtl/VexRiscv" ]; then \
		cd rtl/VexRiscv && sbt "runMain vexriscv.demo.GenFull"; \
	else \
		echo "[ERROR] rtl/VexRiscv not found. Initialize submodules first."; \
		exit 1; \
	fi
	@echo "=== [RTL] Generation complete ==="

# -----------------------------
# [3] Tenstorrent Whisper build
# -----------------------------
whisper:
	@echo "=== [Whisper] Building Tenstorrent Whisper ==="
	sudo apt-get install -y g++-11 build-essential libboost-all-dev gcc-riscv64-unknown-elf liblz4-dev libvncserver-dev
	@if [ -d "tools/whisper" ]; then \
		cd tools/whisper && make BOOST_DIR=/usr; \
	else \
		echo "[ERROR] tools/whisper not found. Run: git submodule update --init --recursive"; \
		exit 1; \
	fi
	@echo "=== [Whisper] Build complete ==="

# -----------------------------
# [4] ChipsAlliance RISC-V DV setup
# -----------------------------
riscv-dv:
	@echo "=== [RISCV-DV] Installing dependencies ==="
	@if [ -d "tools/riscv-dv" ]; then \
		cd tools/riscv-dv && pip3 install --user -r requirements.txt; \
	else \
		echo "[ERROR] tools/riscv-dv not found. Run: git submodule update --init --recursive"; \
		exit 1; \
	fi
	@echo "=== [RISCV-DV] Developer mode install (editable) ==="
	cd tools/riscv-dv && export PATH=$$HOME/.local/bin:$$PATH && pip3 install --user -e .
	@echo "=== [RISCV-DV] Installation complete ==="

# -----------------------------
# [5] Generate RISC-V DV random tests (generation only)
# -----------------------------
riscv-dv-gen:
	@echo "=== [RISCV-DV] Generating random instruction tests ==="
	@if [ -d "tools/riscv-dv" ]; then \
		cd tools/riscv-dv && \
		python3 run.py \
			--test riscv_rand_instr_test \
			--iterations 50 \
			--output ../../regression/tests/generated \
			-si "questa" \
			--steps gen; \
	else \
		echo "[ERROR] tools/riscv-dv not found."; \
		exit 1; \
	fi
	@echo "=== [RISCV-DV] Test generation complete ==="

# -----------------------------
# [6] Verilog style check using Verible
# -----------------------------
style-check:
	@echo "=== [RISCV-DV] Running Verilog style check ==="
	@if [ -d "tools/riscv-dv" ]; then \
		cd tools/riscv-dv/verilog_style && ./build-verible.sh && ./run.sh; \
	else \
		echo "[ERROR] tools/riscv-dv not found."; \
		exit 1; \
	fi
	@echo "=== [Style] Verilog style check complete ==="

# -----------------------------
# [7] Clean
# -----------------------------
clean:
	@echo "=== [Clean] Removing artifacts ==="
	@if [ -d "rtl/VexRiscv" ]; then cd rtl/VexRiscv && sbt clean; fi
	@if [ -d "tools/whisper/build" ]; then rm -rf tools/whisper/build-Linux; fi
	@if [ -d "tests/generated" ]; then rm -rf tests/generated; fi
	@echo "=== [Clean] Done ==="

# -----------------------------
# [8] Environment check
# -----------------------------
check:
	@echo "=== [Check] Toolchain Summary ==="
	@java -version 2>&1 | head -n 1 || echo "Java missing"
	@sbt sbtVersion | head -n 1 || echo "sbt missing"
	@python3 --version || echo "Python3 missing"
	@g++-11 --version | head -n 1 || echo "g++-11 missing"
	@riscv64-unknown-elf-gcc --version | head -n 1 || echo "RISC-V GCC missing"
	@echo "Boost: " && dpkg -l | grep libboost | head -n 1 || echo "Boost missing"
	@echo "=== [Check] Done ==="

# -----------------------------
# [9] Help
# -----------------------------
help:
	@echo "=========================================================="
	@echo " VexRiscv Verification Framework — Make Targets"
	@echo "----------------------------------------------------------"
	@echo " make deps           : Install base toolchain (Java, sbt, Python)"
	@echo " make rtl-gen        : Generate VexRiscv RTL via SpinalHDL"
	@echo " make whisper        : Build Tenstorrent Whisper simulator"
	@echo " make riscv-dv       : Install ChipsAlliance RISC-V DV (editable)"
	@echo " make riscv-dv-gen   : Generate random tests using RISCV-DV"
	@echo " make style-check    : Run Verilog style checks (Verible)"
	@echo " make clean          : Remove build artifacts"
	@echo " make check          : Show current toolchain versions"
	@echo " make all            : Run deps + RTL build"
	@echo "----------------------------------------------------------"
	@echo " Notes:"
	@echo "  • Ensure submodules are initialized:"
	@echo "       git submodule update --init --recursive"
	@echo "  • RISCV-DV supports VCS, Xcelium, Questa, Riviera simulators"
	@echo "=========================================================="
