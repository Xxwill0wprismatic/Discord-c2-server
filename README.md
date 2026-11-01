English: This project is a Proof of Concept (PoC) developed for EDUCATIONAL and RESEARCH purposes only. It demonstrates how Command and Control (C2) channels can operate over legitimate web services (Discord) to help Blue Teams understand detection strategies. The author is not responsible for any misuse of this code.

Discord C2 is a stealthy post-exploitation framework leveraging Discord's infrastructure as a communication channel. By using a Discord Bot as a relay, C2 traffic blends with legitimate HTTPS traffic, making detection challenging for traditional firewalls.

This project features an Agent (implant) deployed on the target, a Server (controller), and a modern Web Dashboard to manage agents, execute commands, and exfiltrate data in real-time.

 # Key Highlights
Stealth: Communication via Discord API (TLS encrypted traffic + internal AES-256 encryption).
Web Interface: Reactive dashboard to manage multiple agents simultaneously.
Advanced Features: Keylogger, Password Stealer, Screenshots, File Transfer

# Agent Capabilities
Remote Shell: Execute system commands (cmd.exe) remotely.
File Operations:
!upload: Upload files from the C2 to the target.
!download: Exfiltrate files from the target to the C2.
Surveillance:
!screenshot: Capture the target's screen.
!keys: Retrieve keystrokes (Keylogger).
Credential Harvesting:
!dumppass: Decrypt and dump saved passwords from browsers (Chrome, Edge, Brave).
Persistence:
!persist: Install the agent in the Windows Startup folder.
Stealth & Evasion:
Single Instance: Uses a Global Mutex to prevent multiple instances.
Hidden Window: Runs silently in the background.
Obfuscation: Supports garble for binary obfuscation.


# C2 Server & Dashboard
Real-time Logs: Live feed of agent activities and exfiltrated data.
Multi-Agent Support: Manage multiple infected hosts from a single interface.
File Attribution: Automatically links downloaded files (screenshots, passwords) to the specific agent.
Modern UI: Dark mode interface with terminal-like experience.

flowchart TB
    subgraph Infrastructure["Attacker Infrastructure"]
        A["Web Dashboard"]
        B["C2 Server"]
        A --> B
    end

    subgraph Target["Authorized Target Machine"]
        C["Management Agent"]
    end

    subgraph Communication["Secure Communication"]
        D["HTTPS / WebSocket"]
    end

    B --> D
    D --> C
    C --> D
    D --> B

    Agent checks in and listens for commands on a Discord Channel.
Operator sends commands via the Web Dashboard.
Server relays commands to Discord.
Agent executes commands and sends results (text/files) back to Discord.
Server retrieves results and updates the Dashboard


# Setup & Installation

1. Prerequisites

- Go 1.21 or later
- Discord application created through the "Discord Developer Portal" (https://discord.com/developers/applications)
- A dedicated test Discord server
- Two private channels:
  - "#commands"
  - "#results"

2. Configuration

Rename ".env.example" to ".env" and configure the required environment variables:

DISCORD_TOKEN=your_bot_token_here
COMMAND_CHANNEL_ID=your_command_channel_id
RESULT_CHANNEL_ID=your_results_channel_id
ENCRYPTION_KEY=your_32_byte_encryption_key

Keep your bot token and encryption key private. Never commit ".env" to a public repository.

3. Building

Build the server:

go build -o bin/server.exe ./cmd/server

4. Running the Server

Start the server:

./bin/server.exe

The web dashboard will be available at:

http://localhost:8080

---

Usage

1. Start the Server

Launch the server and verify that the dashboard is accessible.

2. Connect an Authorized Test Agent

Use only explicitly authorized test machines. The agent should operate visibly, require user consent, and provide a clear shutdown mechanism.

3. Available Commands

Command| Description
"status"| Display agent status
"sysinfo"| Display basic system information
"whoami"| Display the current account
"dir"| List an authorized test directory
"help"| Display available commands

---

Detection (Blue Team)

1. Traffic Analysis

- Monitor unusual outbound connections to Discord infrastructure.
- Investigate repetitive beaconing patterns.
- Review unexpected WebSocket connections.
- Examine unusual network traffic originating from endpoints.

2. Process Inspection

- Identify unsigned executables making unexpected network connections.
- Investigate suspicious background processes.
- Review unusual process execution chains.
- Monitor unexpected application startup behavior.

3. File Artifacts

- Inspect unexpected executables in user startup directories.
- Review recently created or modified files.
- Investigate suspicious scheduled tasks.
- Verify executable signatures and file hashes.

4. Incident Response

- Isolate affected endpoints when necessary.
- Preserve relevant logs and forensic evidence.
- Revoke compromised credentials and tokens.
- Remove unauthorized applications.
- Review network and endpoint security alerts.

---

License

This project is licensed under the MIT License.
