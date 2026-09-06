import sys
import os
import subprocess

# Colors
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
RESET = "\033[0m"
BOLD = "\033[1m"

def print_result(check_name, status, details=""):
    color = GREEN if status else RED
    icon = "✅" if status else "❌"
    print(f"{color}{icon} {check_name}{RESET}")
    if details:
        print(f"   └─ {details}")
    return status

def check_python_version():
    version_info = sys.version_info
    status = version_info >= (3, 10)
    details = f"Current version: {version_info.major}.{version_info.minor}.{version_info.micro}"
    return print_result("Python >= 3.10", status, details)

def check_pytorch_mps():
    try:
        import torch
        status = torch.backends.mps.is_available()
        details = f"PyTorch {torch.__version__} | MPS Available: {status}"
        return print_result("PyTorch & Apple Metal (MPS)", status, details)
    except ImportError:
        return print_result("PyTorch & Apple Metal (MPS)", False, "PyTorch not installed")

def check_microphone():
    try:
        import sounddevice as sd
        status = True
        try:
            with sd.InputStream(samplerate=16000, channels=1, dtype='float32') as stream:
                _ = stream.read(1024)
            details = "Microphone accessible"
        except Exception as e:
            status = False
            details = f"Error accessing microphone: {e}"
        return print_result("Audio Input (Microphone)", status, details)
    except ImportError:
        return print_result("Audio Input (Microphone)", False, "sounddevice not installed")

def check_hammerspoon_symlink():
    target = os.path.expanduser("~/.hammerspoon/init.lua")
    project_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "hammerspoon", "init.lua"))
    
    if not os.path.exists(target):
        return print_result("Hammerspoon Symlink", False, f"Not found at {target}")
    
    if not os.path.islink(target):
        return print_result("Hammerspoon Symlink", False, "File exists but is not a symlink")
        
    actual_target = os.path.realpath(target)
    if actual_target == project_path:
        return print_result("Hammerspoon Symlink", True, f"Correctly points to {project_path}")
    else:
        return print_result("Hammerspoon Symlink", False, f"Points to {actual_target} instead of {project_path}")

def main():
    print(f"\n{BOLD}========================================{RESET}")
    print(f"{BOLD}    BAKWAAS HEALTH DIAGNOSTICS          {RESET}")
    print(f"{BOLD}========================================{RESET}\n")

    results = [
        check_python_version(),
        check_pytorch_mps(),
        check_microphone(),
        check_hammerspoon_symlink()
    ]

    print(f"\n{BOLD}========================================{RESET}")
    all_passed = all(results)
    if all_passed:
        print(f"{GREEN}{BOLD}🎉 ALL SYSTEMS GO! Bakwaas is healthy.{RESET}")
    else:
        print(f"{RED}{BOLD}⚠️  SOME CHECKS FAILED. Please review the errors above.{RESET}")
    print(f"{BOLD}========================================{RESET}\n")

if __name__ == "__main__":
    main()
