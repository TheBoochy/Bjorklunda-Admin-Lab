# Björklunda Admin Lab

**Name:** Robert
**GitHub:** TheBoochy
**Project:** Voluntary portfolio lab based on Björklunda kommun IT technician case
**Focus:** RHEL, Windows Server, Active Directory, Identity Management, scripting, documentation and administration

---

## Work log

### 2026-06-11

**Worked on:**
Initial project setup, Git repository structure, signature scripts and GitHub remote setup.

**What I did:**
Created the project folder, initialized Git, created the folder structure, started the main Markdown logbook, created signature scripts for Linux and Windows Server, and pushed the repository to GitHub.

**Problems and solutions:**
I first had trouble finding the correct project folder because Windows showed both OneDrive Documents and the local Documents folder. I solved this by using the full path to the project folder: `C:\Users\rband\Documents\Bjorklunda-Admin-Lab`.

**Decisions I made:**
I chose to use the repository name `Bjorklunda-Admin-Lab` because this is a voluntary portfolio project and not a formal school submission.

**Sources I used:**

* School assignment PDF: Case IT-tekniker på Björklunda kommun

---

## Part 1 — Preparation and repository setup

I created the project folder `Bjorklunda-Admin-Lab` on my Windows computer and initialized it as a Git repository.

The folder structure was created with:

* `screenshots/` for screenshots and evidence
* `scripts/` for Bash and PowerShell scripts
* `data/` for CSV and input files
* `results/` for output and result files

The purpose of this structure is to keep documentation, scripts, screenshots and result files separated and easy to find.

I created the first screenshot showing the initial Git commit history.

![Screenshot 01 - Initial Git commit](screenshots/screenshot-01-git-initial-commit.png)

I created two signature scripts:

* `scripts/signature.sh` for Linux servers
* `scripts/signature.ps1` for Windows Server

The purpose of the signature scripts is to show name, email, timestamp, hostname and IP address in screenshots, so each screenshot can be connected to the correct server and moment.

The Linux script is used on RHEL servers to show my name, email, timestamp, hostname and IP address before taking screenshots.

The Windows PowerShell script is used on Windows Server for the same purpose.

The second commit was created with the message:

`Complete part 1: setup and signature scripts`

The Git history showed two commits, which confirmed that the initial repository setup and Part 1 signature scripts were saved in version control.

![Screenshot 02 - Part 1 complete Git log](screenshots/screenshot-02-part1-complete-git-log.png)

The local Git repository was connected to GitHub using a remote called `origin`.

The branch was renamed to `main`, and the project was pushed to GitHub.

Commands used:

```powershell
git branch -M main
git remote add origin https://github.com/TheBoochy/Bjorklunda-Admin-Lab.git
git push -u origin main
```

The command `git branch -M main` renamed the local branch to `main`.

The command `git remote add origin ...` connected the local repository to the GitHub repository.

The command `git push -u origin main` uploaded the local commits to GitHub and connected the local `main` branch to the GitHub `main` branch.

After pushing, `git status` showed that the working tree was clean and up to date with `origin/main`.

![Screenshot 03 - First GitHub push](screenshots/screenshot-03-github-first-push.png)

---

## Part 2 — Planning

In this part I planned the server environment before starting the installation. The environment will contain three servers: one RHEL application server, one RHEL Identity Management server, and one Windows Server domain controller.

### Server roles

| Server        | Operating system                                     | Purpose                                                                                                          |
| ------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `srv-linux01` | Red Hat Enterprise Linux                             | Application server for Linux services and applications. It will later authenticate users against the IdM server. |
| `srv-idm01`   | Red Hat Enterprise Linux with Identity Management    | Central identity server for Linux users, SSH authentication, groups and access policies.                         |
| `srv-dc01`    | Windows Server with Active Directory Domain Services | Windows domain controller for Windows users, computers, groups and Group Policy.                                 |

### Documentation questions

**What does Red Hat recommend for the `/boot` partition size?**
For this lab I will use a separate `/boot` partition of 1 GB, which also matches the minimum requirement in the assignment. The `/boot` partition stores files required to boot the operating system, such as the kernel and bootloader files.

**What is the difference between XFS and ext4?**
XFS is the default filesystem in Red Hat Enterprise Linux and is designed for scalability, performance and large filesystems. ext4 is also a common Linux filesystem and is familiar from older Linux systems, but it has lower supported limits for filesystem and file sizes compared with XFS. Because this is a RHEL server lab, I will use XFS for the Linux partitions.

**What is RHEL IdM and what is it used for?**
RHEL Identity Management, IdM, is used to centralize Linux identity services. It can manage users, groups, authentication, authorization policies and access control for Linux systems. In this lab, `srv-idm01` will be used as the central identity server for the Linux environment.

**One thing I did not fully understand at first:**
At first I did not fully understand why `/home` should be separated from `/`. I researched it and understood that separating `/home` can help protect user files and settings if the root filesystem has problems or needs to be reinstalled.

### Sources used

* Red Hat documentation about RHEL installation and manual partitioning
* Red Hat documentation about XFS and ext4 filesystems
* Red Hat documentation about Identity Management
* Microsoft Learn documentation about Active Directory Domain Services

### Planned partition layout for `srv-linux01`

| Mount point |  Size | Filesystem | Motivation                                                                                                                                  |
| ----------- | ----: | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `/boot`     |  1 GB | XFS        | Stores boot files required to start the system.                                                                                             |
| `/`         | 25 GB | XFS        | Stores the operating system, services and installed packages. I chose more than the minimum because this server may later run applications. |
| `/home`     | 10 GB | XFS        | Stores user files and personal settings. Keeping it separate makes the layout easier to manage.                                             |
| `swap`      |  2 GB | swap       | Provides extra virtual memory if RAM becomes pressured.                                                                                     |

### Planned partition layout for `srv-idm01`

| Mount point |  Size | Filesystem | Motivation                                                                                                                                                                                    |
| ----------- | ----: | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `/boot`     |  1 GB | XFS        | Stores boot files required to start the system.                                                                                                                                               |
| `/`         | 35 GB | XFS        | IdM is more important than a normal application server because it handles identity, authentication and related services. I chose a larger root partition for packages, logs and service data. |
| `/home`     | 15 GB | XFS        | Gives more room for administrator files and future user-related data.                                                                                                                         |
| `swap`      |  4 GB | swap       | Gives more safety margin because the IdM server provides central authentication services.                                                                                                     |

### Network planning

All three servers will be placed in the same lab network so that they can communicate with each other.

Planned hostnames:

| Server                    | Hostname                       |
| ------------------------- | ------------------------------ |
| Linux application server  | `srv-linux01.bjorklunda.local` |
| RHEL IdM server           | `srv-idm01.bjorklunda.local`   |
| Windows domain controller | `srv-dc01.bjorklunda.local`    |

Planned network mode in VMware: NAT.

I chose NAT because it gives the virtual machines network access through the host computer while keeping the lab separated from the rest of the physical network. This is safer for a school and portfolio lab because the servers can communicate in the virtual network without exposing everything directly to the home network.

---

## Part 3 — Linux server installation

I created and installed the RHEL server `srv-linux01`.

The server was installed with the hostname:

`srv-linux01.bjorklunda.local`

I used VMware NAT networking because it keeps the lab environment separated from the physical network while still allowing internet access through the host computer.

The static network configuration for `srv-linux01` is:

| Setting    | Value                          |
| ---------- | ------------------------------ |
| IP address | `192.168.80.10/24`             |
| Gateway    | `192.168.80.2`                 |
| DNS        | `192.168.80.2`                 |
| Hostname   | `srv-linux01.bjorklunda.local` |

### Installation screenshots

The manual partitioning screen was saved as:

![Screenshot 01 - Manual partitioning](screenshots/screenshot-01.png)

The network and hostname configuration screen was saved as:

![Screenshot 02 - Network and hostname](screenshots/screenshot-02.png)

### Verification commands

I verified the installation with these commands:

```bash
lsblk
df -h
ip addr show
hostnamectl
cat /etc/os-release
```

The command `lsblk` showed the disk and partition layout. This confirmed that the server disk was divided into the planned partitions.

The command `df -h` showed mounted filesystems and disk usage in a human-readable format. This confirmed that the partitions were mounted correctly.

The command `ip addr show` showed the network interfaces and IP addresses. This confirmed that `srv-linux01` had the static IP address `192.168.80.10/24`.

The command `hostnamectl` showed the configured hostname and system information. This confirmed that the hostname was set to `srv-linux01.bjorklunda.local`.

The command `cat /etc/os-release` showed the installed operating system version. This confirmed that the server is running Red Hat Enterprise Linux 10.1.

![Screenshot 03 - Disk and filesystem verification](screenshots/screenshot-03.png)

![Screenshot 04 - Network and hostname verification](screenshots/screenshot-04.png)

### Signature script activation

I copied the Linux signature script from my Windows host to `srv-linux01` using `scp`.

Command used from the Windows host:

```powershell
scp scripts/signature.sh vulkan@192.168.80.10:~/signature.sh
```

The command `scp` copies files securely over SSH. I used it to copy `signature.sh` from my local `scripts/` folder to the home folder of the user `vulkan` on `srv-linux01`.

On `srv-linux01`, I made the script executable with:

```bash
chmod +x ~/signature.sh
```

The command `chmod +x` gives the script permission to run as a program.

I tested the script with:

```bash
~/signature.sh
```

The script printed my name, email, timestamp, hostname and IP address.

![Screenshot 07 - Linux signature script](screenshots/screenshot-07.png)

### Running services and listening ports

I checked which services were running on `srv-linux01` with:

```bash
~/signature.sh
systemctl list-units --type=service --state=running --no-pager
```

The command `systemctl list-units --type=service --state=running` lists active systemd services. This shows which background services are currently running on the server.

![Screenshot 05 - Running services](screenshots/screenshot-05.png)

I checked listening TCP ports with:

```bash
~/signature.sh
ss -tlnp
```

The command `ss -tlnp` shows TCP ports that are listening for incoming connections. The output showed that SSH is listening on port `22`, and Cockpit is listening on port `9090`.

![Screenshot 06 - Listening ports](screenshots/screenshot-06.png)

I checked the network device status with:

```bash
nmcli device status
```

The output showed that `ens160` is an Ethernet interface and that it is connected. The `lo` interface is the local loopback interface, which the system uses to communicate with itself.

### Service questions

**Three running services and what they do**

| Service                  | Explanation                                                                                                                                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sshd.service`           | This is the OpenSSH server service. It allows remote login to the server through SSH. This is needed so administrators can manage the server remotely. |
| `NetworkManager.service` | This manages network connections and network configuration. It is needed so the server can use its IP address, gateway and DNS settings.               |
| `firewalld.service`      | This manages firewall rules. It is needed to control which network traffic is allowed to reach the server.                                             |

**Which port does SSH listen on and what is it used for?**
SSH listens on TCP port `22`. It is used for secure remote login and administration of the server.

**What would happen if a critical service was stopped?**
If a critical service was stopped, parts of the server could stop working. For example, if `sshd.service` stopped, remote SSH login would no longer work. If `NetworkManager.service` stopped or was misconfigured, the server could lose network connectivity.

**How can I find out which services are critical?**
I can check service status with `systemctl status service-name`, read service descriptions with `systemctl cat service-name`, check logs with `journalctl -u service-name`, and look at what other services depend on it with `systemctl list-dependencies service-name`.

---

### Troubleshooting checks

I performed troubleshooting checks on `srv-linux01` to verify that important server functions were working correctly.

### SSH service check

Command used:

```bash
~/signature.sh
systemctl status sshd --no-pager
```

The command `systemctl status sshd` checks the status of the OpenSSH server service. SSH is used for secure remote administration of the server.

In the output, I looked for `active (running)`, which means that the SSH service is started and working.

If SSH was stopped, the output would show `inactive`, `failed` or `dead`. To start SSH again, I would use:

```bash
sudo systemctl start sshd
```

To make sure SSH starts automatically after reboot, I would use:

```bash
sudo systemctl enable sshd
```

![Screenshot 08 - SSH service status](screenshots/screenshot-08.png)

### Hostname check

Command used:

```bash
~/signature.sh
hostnamectl
```

The command `hostnamectl` shows the system hostname and basic system information.

The output confirmed that the static hostname was set to:

`srv-linux01.bjorklunda.local`

If the hostname was wrong, it could cause problems with DNS, certificates, authentication and communication with other servers. To correct the hostname, I would use:

```bash
sudo hostnamectl set-hostname srv-linux01.bjorklunda.local
```

![Screenshot 09 - Hostname check](screenshots/screenshot-09.png)

### IP address check

Command used:

```bash
~/signature.sh
ip addr show ens160
```

The command `ip addr show ens160` shows IP address information for the network interface `ens160`.

The output confirmed that the server had the planned static IP address:

`192.168.80.10/24`

If the IP address was missing or incorrect, the server might not be reachable on the network. To troubleshoot this, I would check the NetworkManager connection with:

```bash
nmcli connection show
```

Then I would correct the IP settings with `nmcli` or through the installer/network configuration.

![Screenshot 10 - IP address check](screenshots/screenshot-10.png)

### Partition and mount check

Command used:

```bash
~/signature.sh
lsblk
df -h
```

The command `lsblk` shows the disk and partition layout.

The command `df -h` shows mounted filesystems and disk usage in a human-readable format.

The output confirmed that the planned partitions and mount points were present, including `/`, `/home`, `/boot` and `/boot/efi`.

If a partition was mounted in the wrong place, files could be stored on the wrong filesystem or services could fail to find their data. I would troubleshoot this by checking `/etc/fstab`, using `lsblk`, `df -h`, and testing mounts with:

```bash
sudo mount -a
```

![Screenshot 11 - Partition and mount check](screenshots/screenshot-11.png)

### Network connectivity check

Command used:

```bash
~/signature.sh
ping -c 4 192.168.80.2
ping -c 4 8.8.8.8
```

The command `ping -c 4 192.168.80.2` tested connectivity to the VMware NAT gateway.

The command `ping -c 4 8.8.8.8` tested internet connectivity by IP address.

Both tests showed `0% packet loss`, which means the server could reach both the local gateway and the internet.

If the gateway ping failed, I would check the IP address, gateway, subnet mask and VMware NAT settings.

If the gateway ping worked but the internet ping failed, I would check NAT, firewall settings and DNS/internet access from the host computer.

![Screenshot 12 - Network connectivity check](screenshots/screenshot-12.png)

### VM snapshot after Part 3

After completing the installation, verification, service checks and troubleshooting checks for `srv-linux01`, I shut down the server cleanly and created a VMware snapshot.

Snapshot name:

`Part 3 complete - srv-linux01 installed and verified`

The purpose of this snapshot is to create a safe rollback point before continuing with Windows Server, Active Directory and RHEL IdM. If a later configuration breaks the lab environment, I can restore `srv-linux01` to this working state instead of reinstalling it.

The snapshot was taken after confirming:

- RHEL 10.1 was installed
- Static IP address `192.168.80.10/24` was configured
- Hostname `srv-linux01.bjorklunda.local` was configured
- SSH was working
- The signature script was working
- Running services and listening ports were checked
- Troubleshooting checks were completed

![srv-linux01 Part 3 snapshot](screenshots/screenshot-srv-linux01-part3-snapshot.png)

## Part 4 — Windows Server and Active Directory

## Part 5 — Account management with scripts

## Part 6 — Shared folders and permissions

## Part 7 — Printing system

## Part 8 — Virtualization

## Part 9 — Laws and security

## Part 10 — Advice and support

## Part 11 — Environment reflection
