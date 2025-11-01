#!/usr/bin/env python3
"""
VexRiscv Verification Framework - Build System
Executes tasks defined in build_config.yaml
Author: Vaishnav RKV
"""

import argparse
import sys
import subprocess
import yaml
import os
from pathlib import Path
from typing import Dict, List, Any, Set
from collections import deque


class BuildSystem:
    """Manages task execution and dependency resolution"""

    def __init__(self, config_file: str = "build_config.yaml"):
        self.config_file = config_file
        self.config = self._load_config()
        self.tasks = self.config.get("tasks", {})
        self.executed = set()
        self.failed = set()

    def _load_config(self) -> Dict[str, Any]:
        """Load YAML configuration"""
        if not os.path.exists(self.config_file):
            print(f"[ERROR] Config file not found: {self.config_file}")
            sys.exit(1)

        try:
            with open(self.config_file, "r") as f:
                return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"[ERROR] Failed to parse YAML: {e}")
            sys.exit(1)

    def _print_header(self, title: str):
        """Print formatted header"""
        print(f"\n{'='*60}")
        print(f"  {title}")
        print(f"{'='*60}\n")

    def _print_task_header(self, task_name: str, description: str):
        """Print task header"""
        print(f"\n[Task: {task_name}] {description}")
        print("-" * 60)

    def _run_command(self, command: str, step_name: str = "") -> bool:
        """Execute shell command and return success status"""
        if step_name:
            print(f"  → {step_name}")

        try:
            result = subprocess.run(
                command,
                shell=True,
                executable="/bin/bash",
                capture_output=False
            )
            return result.returncode == 0
        except Exception as e:
            print(f"[ERROR] Command execution failed: {e}")
            return False

    def _resolve_dependencies(self, task_name: str) -> List[str]:
        """Resolve task dependencies using topological sort"""
        if task_name not in self.tasks:
            print(f"[ERROR] Task not found: {task_name}")
            return []

        visited = set()
        order = []
        stack = deque([task_name])

        while stack:
            current = stack[-1]
            if current in visited:
                stack.pop()
                if current not in order:
                    order.append(current)
                continue

            visited.add(current)
            task = self.tasks.get(current, {})
            deps = task.get("dependencies", [])

            for dep in reversed(deps):
                if dep not in visited:
                    stack.append(dep)

        return order

    def _execute_task(self, task_name: str) -> bool:
        """Execute a single task"""
        if task_name in self.executed:
            print(f"[SKIP] {task_name} already executed")
            return True

        if task_name in self.failed:
            print(f"[ERROR] {task_name} previously failed, skipping")
            return False

        if task_name not in self.tasks:
            print(f"[ERROR] Task not found: {task_name}")
            return False

        task = self.tasks[task_name]
        description = task.get("description", "")
        steps = task.get("steps", [])

        self._print_task_header(task_name, description)

        # Execute all steps in order
        for step in steps:
            step_name = step.get("name", "")
            command = step.get("command")
            on_success = step.get("on_success")
            on_failure = step.get("on_failure")
            actions = step.get("actions", [])

            # Handle conditional checks
            if command:
                if not self._run_command(command, step_name):
                    if on_failure:
                        print(f"  ⚠ Condition failed, executing fallback...")
                        if not self._run_command(on_failure):
                            print(f"[ERROR] Step '{step_name}' failed")
                            self.failed.add(task_name)
                            return False
                    continue
                else:
                    if on_success:
                        self._run_command(on_success)
            else:
                # Execute all actions in the step
                for action in actions:
                    if not self._run_command(action, step_name):
                        print(f"[ERROR] Action failed: {action}")
                        self.failed.add(task_name)
                        return False

        print(f"\n[SUCCESS] {task_name} completed\n")
        self.executed.add(task_name)
        return True

    def run_task(self, task_name: str) -> bool:
        """Run a task with all its dependencies"""
        print("\n")
        self._print_header(f"Build Task: {task_name}")

        # Resolve and execute dependencies
        order = self._resolve_dependencies(task_name)

        if not order:
            print(f"[ERROR] Failed to resolve dependencies for: {task_name}")
            return False

        print(f"[INFO] Execution order: {' → '.join(order)}\n")

        for task in order:
            if not self._execute_task(task):
                print(f"\n[FAILED] Build stopped at task: {task}")
                return False

        self._print_header("Build Complete!")
        print(f"[SUCCESS] All tasks completed successfully\n")
        return True

    def list_tasks(self):
        """List all available tasks"""
        self._print_header("Available Tasks")
        for task_name, task_info in self.tasks.items():
            description = task_info.get("description", "No description")
            deps = task_info.get("dependencies", [])
            deps_str = f" (depends on: {', '.join(deps)})" if deps else ""
            print(f"  • {task_name:20} - {description}{deps_str}")
        print()

    def show_task_details(self, task_name: str):
        """Show detailed information about a task"""
        if task_name not in self.tasks:
            print(f"[ERROR] Task not found: {task_name}")
            return

        task = self.tasks[task_name]
        self._print_header(f"Task Details: {task_name}")
        print(f"Description: {task.get('description', 'N/A')}")
        print(f"Dependencies: {', '.join(task.get('dependencies', [])) or 'None'}")
        print(f"\nSteps:")

        for i, step in enumerate(task.get("steps", []), 1):
            print(f"  {i}. {step.get('name', 'Unknown')}")
            if step.get("command"):
                print(f"     Command: {step['command']}")
            if step.get("actions"):
                for action in step["actions"]:
                    print(f"     Action: {action}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description="VexRiscv Verification Framework Build System",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 build.py deps              # Install dependencies
  python3 build.py whisper           # Build Whisper with dependencies
  python3 build.py all               # Run full build pipeline
  python3 build.py --list            # Show all available tasks
  python3 build.py --info riscv-dv   # Show task details
  python3 build.py clean             # Clean build artifacts
        """
    )

    parser.add_argument(
        "task",
        nargs="?",
        help="Task name to execute"
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List all available tasks"
    )
    parser.add_argument(
        "--info",
        metavar="TASK",
        help="Show detailed information about a task"
    )
    parser.add_argument(
        "--config",
        default="build_config.yaml",
        help="Path to build configuration file (default: build_config.yaml)"
    )

    args = parser.parse_args()

    # Initialize build system
    build = BuildSystem(args.config)

    # Handle different modes
    if args.list:
        build.list_tasks()
        return 0

    if args.info:
        build.show_task_details(args.info)
        return 0

    if not args.task:
        parser.print_help()
        return 1

    # Execute task
    success = build.run_task(args.task)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())