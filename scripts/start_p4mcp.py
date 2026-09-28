"""Start the Perforce MCP server using this workspace's .p4config.

stdout is reserved for MCP. Diagnostics go to stderr.
"""
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_NAME = ".p4config"
REQUIRED = ("P4PORT", "P4USER", "P4CLIENT")


def fail(message):
    print(message, file=sys.stderr)
    raise SystemExit(1)


def load_p4config(path):
    values = {}
    with open(path, encoding="utf-8") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    return values


def find_server():
    override = os.environ.get("P4MCP_BIN", "").strip()
    if override:
        if not os.path.isfile(override):
            fail(f"P4MCP_BIN is not a file: {override}")
        return override, []
    uvx = shutil.which("uvx")
    if uvx is None:
        candidate = os.path.join(os.path.expanduser("~"), ".local", "bin", "uvx.exe")
        if os.path.isfile(candidate):
            uvx = candidate
    if uvx is None:
        fail("uvx was not found. Install uv, or set P4MCP_BIN to the p4mcp-server executable.")
    return uvx, ["p4mcp-server"]


def main():
    os.chdir(ROOT)
    config_path = os.path.join(ROOT, CONFIG_NAME)
    if not os.path.isfile(config_path):
        fail(
            f"Missing {config_path}. Copy .p4config.template to .p4config and set P4PORT, P4USER, and P4CLIENT."
        )
    values = load_p4config(config_path)
    if "P4PASSWD" in values:
        fail("Remove P4PASSWD from .p4config. Run p4 login and let the MCP server use the ticket.")
    missing = [key for key in REQUIRED if not values.get(key)]
    if missing:
        fail(".p4config is missing: " + ", ".join(missing))
    for key, value in values.items():
        os.environ[key] = value

    login = subprocess.run(
        ["p4", "login", "-s"],
        capture_output=True,
        text=True,
    )
    if login.returncode != 0:
        detail = (login.stderr or login.stdout or "p4 login -s failed").strip()
        fail(f"Helix login is not valid for {values['P4USER']} at {values['P4PORT']}. {detail}\nRun p4 login in this workspace.")

    user = subprocess.run(
        ["p4", "-ztag", "-F", "%Type%", "user", "-o", values["P4USER"]],
        capture_output=True,
        text=True,
    )
    user_type = (user.stdout or "").strip().lower()
    if user_type == "service":
        fail(f"P4USER {values['P4USER']} is a service user. The MCP server needs a standard user.")

    command, prefix = find_server()
    argv = [command, *prefix]
    os.execv(command, argv)


if __name__ == "__main__":
    main()
