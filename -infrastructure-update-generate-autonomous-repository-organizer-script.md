```python
import os
import shutil

def organize_nexus_repo():
    """
    Autonomously cleans up and restructures the root directory of the Nexus Core repository.
    Moves specific file types into designated directories with cyberpunk-themed telemetry.
    """

    # Define target directories
    vault_dir = "Premium-Ebooks-Vault"
    scripts_dir = "AI-Core-Scripts"

    # Define files to be explicitly ignored during routing
    ignored_md_files = ["README.md", "CONTRIBUTING.md", "SECURITY.md"]
    
    # The name of this script itself, to prevent it from moving itself
    current_script_name = os.path.basename(__file__)

    print("[+] INITIALIZING NEXUS RESTRUCTURING PROTOCOL...")
    print("[SYS] Establishing secure conduit to filesystem...")

    # 1. Directory Creation
    print(f"[CREATE] Verifying data vault: {vault_dir}/")
    if not os.path.exists(vault_dir):
        os.makedirs(vault_dir)
        print(f"[SUCCESS] Data vault constructed: {vault_dir}/")
    else:
        print(f"[STATUS] Data vault already exists: {vault_dir}/")

    print(f"[CREATE] Forging script repository: {scripts_dir}/")
    if not os.path.exists(scripts_dir):
        os.makedirs(scripts_dir)
        print(f"[SUCCESS] Script repository forged: {scripts_dir}/")
    else:
        print(f"[STATUS] Script repository already exists: {scripts_dir}/")

    print("[DIR_SCAN] Initiating root directory scan for autonomous routing...")

    # Scan the current directory
    for item in os.listdir('.'):
        if os.path.isfile(item):  # Process only files
            filename, file_extension = os.path.splitext(item)
            file_extension = file_extension.lower()

            # 2. Asset Routing for .md files
            if file_extension == ".md":
                if item in ignored_md_files:
                    print(f"[SKIP] Preserving core directive: {item}")
                else:
                    try:
                        shutil.move(item, os.path.join(vault_dir, item))
                        print(f"[>>] ROUTING ASSET: {item} -> {vault_dir}/")
                    except Exception as e:
                        print(f"[ERROR] Failed to route {item} to {vault_dir}/: {e}")

            # 3. Engine Routing for .py and .rb files
            elif file_extension in [".py", ".rb"]:
                if item == current_script_name:
                    print(f"[SELF] Acknowledging self-preservation protocol for: {current_script_name}")
                else:
                    try:
                        shutil.move(item, os.path.join(scripts_dir, item))
                        print(f"[>>] RE-ROUTING ENGINE: {item} -> {scripts_dir}/")
                    except Exception as e:
                        print(f"[ERROR] Failed to re-route {item} to {scripts_dir}/: {e}")

    print("[COMPLETE] NEXUS RESTRUCTURING PROTOCOL CONCLUDED. SYSTEM OPTIMIZED.")

if __name__ == "__main__":
    organize_nexus_repo()