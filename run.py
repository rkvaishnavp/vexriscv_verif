#!/usr/bin/env python3
"""
VexRiscv Build System (YAML-driven Makefile replacement)
Author: Vaishnav Prasad R K
Date: 2025-11-12
"""

import argparse
import subprocess
import sys
import os
import yaml
from collections import deque
from typing import Dict, Any, List


class BuildRunner:
    def __init__(self, config_file="build_config.yaml"):
        self.config_file = config_file
        self.config = self._load_config()
        self.tasks = self.config.get("tasks", {})
        self.executed = set()

    def _load_config(self) -> Dict[str, Any]:
        if not os.path.exists(self.config_file):
            print(f"[ERROR] Config file '{self.config_file}' not found.")
            sys.exit(1)
        with open(self.config_file, "r") as f:
            return yaml.safe_load(f)

    def _print_header(self, title: str):
        print(f"\n{'='*60}\n{title}\n{'='*60}")

    def _run_command(self, cmd: str) -> bool:
        try:
            result = subprocess.run(cmd, shell=True, executable="/bin/bash")
            return result.returncode == 0
        except KeyboardInterrupt:
            print("\n[ABORTED] User interrupted.")
            sys.exit(1)
        except Exception as e:
            print(f"[ERROR] Command failed: {e}")
            return False

    def _resolve_dependencies(self, task_name: str) -> List[str]:
        visited, order = set(), []
        stack = deque([task_name])
        while stack:
            current = stack[-1]
            if current in visited:
                stack.pop()
                if current not in order:
                    order.append(current)
                continue
            visited.add(current)
            deps = self.tasks.get(current, {}).get("dependencies", [])
            for dep in reversed(deps):
                if dep not in visited:
                    stack.append(dep)
        return order

    def _execute_task(self, task_name: str) -> bool:
        if task_name in self.executed:
            print(f"[SKIP] {task_name} already executed")
            return True

        if task_name not in self.tasks:
            print(f"[ERROR] Unknown task: {task_name}")
            return False

        task = self.tasks[task_name]
        desc = task.get("description", "")
        print(f"\n[Task: {task_name}] {desc}")
        print("-" * 60)

        for step in task.get("steps", []):
            step_name = step.get("name", "Unnamed Step")
            cmd = step.get("command")
            on_success = step.get("on_success")
            on_failure = step.get("on_failure")

            print(f"→ {step_name}")
            if cmd and not self._run_command(cmd):
                if on_failure:
                    print("  ⚠ Condition failed, running on_failure...")
                    if not self._run_command(on_failure):
                        print(f"[ERROR] Step failed: {step_name}")
                        return False
                else:
                    print(f"[ERROR] Step failed: {step_name}")
                    return False
            elif on_success:
                self._run_command(on_success)

        print(f"[SUCCESS] {task_name} complete\n")
        self.executed.add(task_name)
        return True

    def run(self, task_name: str):
        if task_name not in self.tasks:
            print(f"[ERROR] No such task: {task_name}")
            return False

        self._print_header(f"Executing: {task_name}")
        order = self._resolve_dependencies(task_name)
        print(f"[INFO] Execution order: {' → '.join(order)}")

        for t in order:
            if not self._execute_task(t):
                print(f"[FAILED] Build stopped at {t}")
                return False
        return True

    def list_tasks(self):
        self._print_header("Available Tasks")
        for t, info in self.tasks.items():
            print(f"  {t:15} - {info.get('description', '')}")
        print()


def main():
    parser = argparse.ArgumentParser(description="VexRiscv YAML Build Runner")
    parser.add_argument("tasks", nargs="*", help="One or more task names to execute")
    parser.add_argument("--list", action="store_true", help="List all tasks")
    parser.add_argument("--config", default="build_config.yaml", help="Path to YAML config")
    args = parser.parse_args()

    runner = BuildRunner(args.config)

    if args.list:
        runner.list_tasks()
        return

    if not args.tasks:
        parser.print_help()
        return

    # Run tasks sequentially
    for task in args.tasks:
        success = runner.run(task)
        if not success:
            print(f"[BUILD FAILED] at task: {task}")
            sys.exit(1)

    print("\n✅ All tasks finished successfully.")


if __name__ == "__main__":
    main()
