# Makefile for VexRiscv RTL dependencies and build

# Default target
.PHONY: all deps rtl-gen clean
all: deps rtl-gen

# -----------------------------
# Dependencies: Java + sbt
# -----------------------------
deps:
	@echo "=== Installing dependencies (JDK 8 + sbt) ==="
	sudo add-apt-repository -y ppa:openjdk-r/ppa
	sudo apt-get update
	sudo apt-get install -y openjdk-8-jdk
	@echo "=== Installing sbt ==="
	echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
	echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
	curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add -
	sudo apt-get update
	sudo apt-get install -y sbt

# -----------------------------
# RTL generation
# -----------------------------
rtl-gen:
	@echo "=== Generating RTL ==="
	cd VexRiscv && sbt "runMain vexriscv.demo.GenFull" && cd ..

# -----------------------------
# Clean project
# -----------------------------
clean:
	@echo "=== Cleaning project ==="
sbt clean
