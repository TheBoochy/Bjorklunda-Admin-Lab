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

In this part I installed and configured the Windows Server domain controller `srv-dc01`.

The server was installed with Windows Server 2025 and configured as the Windows domain controller for the lab environment.

### Windows Server installation

I created a VMware virtual machine for `srv-dc01` with the following settings:

| Setting          | Value               |
| ---------------- | ------------------- |
| VM name          | `srv-dc01`          |
| Operating system | Windows Server 2025 |
| Memory           | 4 GB                |
| Processors       | 2                   |
| Disk             | 60 GB               |
| Network mode     | NAT                 |

The Windows Server installer created the required system, reserved and primary partitions automatically.

![Windows Server disk layout](screenshots/screenshot-windows-install-disk-layout.png)

### Hostname and network configuration

After installation, I renamed the server to:

`srv-dc01`

I configured the server with a static IP address so that it can be used reliably as a domain controller and DNS server.

Network configuration:

| Setting         | Value           |
| --------------- | --------------- |
| Hostname        | `srv-dc01`      |
| IP address      | `192.168.80.12` |
| Subnet mask     | `255.255.255.0` |
| Default gateway | `192.168.80.2`  |
| DNS server      | `192.168.80.12` |

The DNS server was set to `192.168.80.12` because the server will run DNS for the Active Directory domain.

The configuration was verified with:

```powershell
ipconfig /all
```

The command `ipconfig /all` shows the full network configuration, including hostname, IP address, gateway and DNS server.

![Windows Server IP configuration](screenshots/screenshot-windows-ipconfig-before-ad.png)

### Windows signature script

I created a Windows PowerShell signature script on `srv-dc01`.

Script location:

`C:\Scripts\signature.ps1`

The script prints my chosen portfolio name, email placeholder, timestamp, hostname and IP address.

I allowed the script to run in the current PowerShell session with:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

The command `Set-ExecutionPolicy` changes PowerShell script execution rules.

The option `-Scope Process` means the change only applies to the current PowerShell window.

The option `-ExecutionPolicy Bypass` allows the script to run for this session.

I tested the script with:

```powershell
C:\Scripts\signature.ps1
```

![Screenshot 15 - Windows signature script](screenshots/screenshot-15.png)

### Installing Active Directory Domain Services and DNS

I installed the following server roles on `srv-dc01`:

* Active Directory Domain Services
* DNS Server

Active Directory Domain Services, AD DS, is used to manage domain users, computers, groups, organizational units and authentication.

DNS Server is needed because Active Directory depends on DNS to locate domain controllers and domain services.

The roles were installed through Server Manager using the Add Roles and Features Wizard.

![Screenshot 16 - AD DS and DNS roles selected](screenshots/screenshot-16.png)

After the roles were installed, Server Manager showed that additional configuration was required. I then promoted the server to a domain controller.

### Domain controller promotion

I promoted `srv-dc01` to a domain controller and created a new Active Directory forest.

Root domain name:

`bjorklunda.local`

The server was configured as:

* Domain controller
* DNS server
* Global Catalog server

The prerequisites check passed successfully before installation.

![Screenshot 17 - AD DS prerequisites passed](screenshots/screenshot-17.png)

After the promotion, the server restarted. I logged in as the domain administrator account.

I verified the domain controller promotion with:

```powershell
hostname
whoami
ipconfig
```

The command `hostname` confirmed that the server name was `srv-dc01`.

The command `whoami` confirmed that I was logged in as:

`bjorklunda\administrator`

The command `ipconfig` confirmed that the server still had the IP address `192.168.80.12`.

![Screenshot 18 - Domain controller verification](screenshots/screenshot-18.png)

### Active Directory verification

I opened Active Directory Users and Computers from Server Manager.

This confirmed that the domain `bjorklunda.local` exists and that the server is functioning as a domain controller.

Active Directory Users and Computers is used to manage domain objects such as users, groups, computers and organizational units.

![Screenshot 19 - Active Directory Users and Computers](screenshots/screenshot-19.png)

### Communication between Linux and Windows servers

I tested network communication between `srv-linux01` and `srv-dc01`.

From `srv-linux01`, I tested connectivity to `srv-dc01` with:

```bash
~/signature.sh
ping -c 4 192.168.80.12
```

The command `ping -c 4 192.168.80.12` sends four ICMP packets from the Linux server to the Windows domain controller.

The output showed `0% packet loss`, which means `srv-linux01` can reach `srv-dc01`.

![Screenshot 13 - Linux to Windows ping](screenshots/screenshot-13.png)

From `srv-dc01`, I tested connectivity to `srv-linux01` with:

```powershell
C:\Scripts\signature.ps1
ping 192.168.80.10
```

The command `ping 192.168.80.10` sends ICMP packets from the Windows domain controller to the Linux server.

The output showed successful replies, which means `srv-dc01` can reach `srv-linux01`.

![Screenshot 14 - Windows to Linux ping](screenshots/screenshot-14.png)

The successful ping tests confirm that both servers are on the same VMware NAT network and can communicate with each other.

### Organizational Unit structure

I created a custom Organizational Unit structure inside Active Directory Users and Computers.

The main OU is:

`Bjorklunda`

Inside `Bjorklunda`, I created these OUs:

* `Users`
* `Groups`
* `Computers`
* `Servers`
* `Departments`

Inside `Departments`, I created these department OUs:

* `IT`
* `HR`
* `Finance`
* `Education`

An Organizational Unit, OU, is used to organize Active Directory objects such as users, groups and computers. OUs also make it possible to apply Group Policy settings to specific parts of the domain instead of applying the same settings everywhere.

The OU structure was created in Active Directory Users and Computers.

![Screenshot 20 - Active Directory OU structure](screenshots/screenshot-20.png)

### Active Directory groups

I created four global security groups inside:

`Bjorklunda > Groups`

Groups created:

| Group                | Type                  | Purpose                   |
| -------------------- | --------------------- | ------------------------- |
| `GG_IT_Users`        | Global security group | Group for IT users        |
| `GG_HR_Users`        | Global security group | Group for HR users        |
| `GG_Finance_Users`   | Global security group | Group for Finance users   |
| `GG_Education_Users` | Global security group | Group for Education users |

A security group can be used to assign permissions to several users at once. This is better than giving permissions directly to individual users, because group-based permissions are easier to manage and audit.

The prefix `GG_` means Global Group. I used this naming style to make the group purpose clearer.

![AD groups created](screenshots/screenshot-ad-groups-created.png)

### Active Directory users

I created four test users inside:

`Bjorklunda > Users`

Users created:

| Display name       | User logon name    | Department |
| ------------------ | ------------------ | ---------- |
| `IT User01`        | `it.user01`        | IT         |
| `HR User01`        | `hr.user01`        | HR         |
| `Finance User01`   | `finance.user01`   | Finance    |
| `Education User01` | `education.user01` | Education  |

The users were created as test accounts for the lab environment. Each user represents one department.

![Screenshot 21 - AD users created](screenshots/screenshot-21.png)

### Group membership

Each test user was added to the matching department group:

| User               | Group                |
| ------------------ | -------------------- |
| `it.user01`        | `GG_IT_Users`        |
| `hr.user01`        | `GG_HR_Users`        |
| `finance.user01`   | `GG_Finance_Users`   |
| `education.user01` | `GG_Education_Users` |

This means permissions can later be assigned to the groups instead of directly to the users. For example, if the IT department needs access to a folder, the folder permission can be assigned to `GG_IT_Users`.

### RHEL IdM server installation

I installed the second RHEL server for the lab environment:

`srv-idm01.bjorklunda.local`

This server will later be used as the RHEL Identity Management, IdM, server. RHEL IdM is used to centrally manage Linux users, groups, authentication and access control.

The VMware virtual machine was configured with the following settings:

| Setting          | Value                         |
| ---------------- | ----------------------------- |
| VM name          | `srv-idm01`                   |
| Operating system | Red Hat Enterprise Linux 10.1 |
| Memory           | 4 GB                          |
| Processors       | 2                             |
| Disk             | 60 GB                         |
| Network mode     | NAT                           |

![srv-idm01 VM settings](screenshots/screenshot-23-srv-idm01-vm-settings.png)

### srv-idm01 manual partitioning

During the installation, I used manual partitioning for `srv-idm01`.

The partition layout was based on the plan from Part 2, but I also added `/boot/efi` because the VM uses UEFI boot.

Final partition layout:

| Mount point |    Size | Filesystem           | Purpose                                                  |
| ----------- | ------: | -------------------- | -------------------------------------------------------- |
| `/boot/efi` | 600 MiB | EFI System Partition | Stores UEFI boot files                                   |
| `/boot`     |   1 GiB | XFS                  | Stores kernel and boot files                             |
| `/`         |  35 GiB | XFS                  | Stores the operating system, services, packages and logs |
| `/home`     |  15 GiB | XFS                  | Stores user home directories and administrator files     |
| `swap`      |   4 GiB | swap                 | Provides extra virtual memory if RAM becomes pressured   |

The root partition `/` was given more space than on `srv-linux01` because the IdM server will later run identity-related services and needs more room for packages, logs and service data.

![srv-idm01 manual partitioning](screenshots/screenshot-24-srv-idm01-partitioning.png)

### srv-idm01 network and hostname configuration

I configured `srv-idm01` with a static IP address during installation.

Network configuration:

| Setting           | Value                        |
| ----------------- | ---------------------------- |
| Hostname          | `srv-idm01.bjorklunda.local` |
| IP address        | `192.168.80.11/24`           |
| Default gateway   | `192.168.80.2`               |
| DNS server        | `192.168.80.2`               |
| Network interface | `ens160`                     |

The server was placed on the same VMware NAT network as `srv-linux01` and `srv-dc01`.

![srv-idm01 network and hostname](screenshots/screenshot-25-srv-idm01-network-hostname.png)

### srv-idm01 installation verification

After the installation, I logged in as the user:

`vulkan`

I verified the installation with these commands:

```bash
hostnamectl
ip addr show ens160
cat /etc/os-release
df -h
```

The command `hostnamectl` shows the configured hostname and system information.

The command `ip addr show ens160` shows the IP address configured on the network interface.

The command `cat /etc/os-release` shows the installed operating system version.

The command `df -h` shows mounted filesystems and disk usage in a human-readable format.

The verification confirmed that:

* `srv-idm01.bjorklunda.local` was configured as hostname
* `192.168.80.11/24` was configured as IP address
* Red Hat Enterprise Linux 10.1 was installed
* the manual partitions were mounted correctly

![srv-idm01 installation verification](screenshots/screenshot-26-srv-idm01-install-verification.png)

### srv-idm01 signature script

I copied the Linux signature script to `srv-idm01` and made it executable.

Command used from the Windows host:

```powershell
scp scripts/signature.sh vulkan@192.168.80.11:~/signature.sh
```

The command `scp` securely copies the signature script from my local repository to the home directory of the user `vulkan` on `srv-idm01`.

On `srv-idm01`, I made the script executable with:

```bash
chmod +x ~/signature.sh
```

The command `chmod +x` gives the script permission to run as a program.

I tested the script with:

```bash
~/signature.sh
```

The script printed the portfolio name, email placeholder, timestamp, hostname and IP address.

![srv-idm01 signature script](screenshots/screenshot-27-srv-idm01-signature-script.png)

### srv-idm01 status

At this point, `srv-idm01` is installed and reachable on the lab network.

The next step will be to install and configure RHEL Identity Management on `srv-idm01`, verify that the IdM services are active, create IdM groups, and later connect `srv-linux01` to the IdM server.


## Part 5 — Account management with scripts

In this part I started preparing account management scripts for the Björklunda Admin Lab.

The goal of this part is to show how user and group management can be automated instead of creating every account manually.

In a real administration environment, scripting is useful because it makes account creation faster, more consistent and easier to repeat. It also reduces the risk of small manual mistakes, such as placing a user in the wrong OU or forgetting a group membership.

### PowerShell script for Active Directory users and groups

I created a PowerShell script for Active Directory account management.

Script file:

`scripts/create_ad_users_groups.ps1`

The purpose of this script is to create and verify the Active Directory OU structure, groups, users and group memberships for the lab environment.

The script is designed to work with the domain:

`bjorklunda.local`

It uses the Active Directory PowerShell module:

```powershell
Import-Module ActiveDirectory
```

The command `Import-Module ActiveDirectory` loads the PowerShell commands used to manage Active Directory, such as commands for users, groups and organizational units.

The script defines these important AD paths:

```powershell
$DomainDN = "DC=bjorklunda,DC=local"
$MainOU = "OU=Bjorklunda,$DomainDN"
$UsersOU = "OU=Users,$MainOU"
$GroupsOU = "OU=Groups,$MainOU"
$DepartmentsOU = "OU=Departments,$MainOU"
```

These variables make the script easier to read and maintain. Instead of writing the full OU path many times, the script stores the paths in variables.

### OU creation logic

The script contains a function called:

```powershell
Ensure-OU
```

The purpose of this function is to create an OU only if it does not already exist.

This is important because a script should be safe to run more than once. If the OU already exists, the script should not create a duplicate or stop with unnecessary errors.

The script creates the main OU structure:

* `Bjorklunda`
* `Users`
* `Groups`
* `Computers`
* `Servers`
* `Departments`
* `IT`
* `HR`
* `Finance`
* `Education`

### Group creation logic

The script contains a function called:

```powershell
Ensure-Group
```

The purpose of this function is to create a group only if it does not already exist.

The script is prepared to create these global security groups:

| Group                | Purpose                   |
| -------------------- | ------------------------- |
| `GG_IT_Users`        | Group for IT users        |
| `GG_HR_Users`        | Group for HR users        |
| `GG_Finance_Users`   | Group for Finance users   |
| `GG_Education_Users` | Group for Education users |

The groups are global security groups, which means they can be used for assigning permissions to users in this domain.

### User creation logic

The script contains a function called:

```powershell
Ensure-User
```

The purpose of this function is to create a user only if it does not already exist.

The script is prepared to create these test users:

| User               | Logon name         | Group                |
| ------------------ | ------------------ | -------------------- |
| `IT User01`        | `it.user01`        | `GG_IT_Users`        |
| `HR User01`        | `hr.user01`        | `GG_HR_Users`        |
| `Finance User01`   | `finance.user01`   | `GG_Finance_Users`   |
| `Education User01` | `education.user01` | `GG_Education_Users` |

The script uses a temporary lab password and sets the accounts to require a password change at next logon.

This is useful because the administrator can create accounts with a temporary password, but the user must choose their own password when they first log in.

### Group membership logic

The script uses:

```powershell
Add-ADGroupMember
```

The command `Add-ADGroupMember` adds users to Active Directory groups.

This means permissions can later be assigned to the groups instead of directly to individual users.

For example, if the IT department needs access to an IT folder, the permission can be assigned to `GG_IT_Users`. Any IT user who is a member of that group will then receive the correct access.

### Verification script

I also created a verification script.

Script file:

`scripts/verify_ad_users_groups.ps1`

The purpose of this script is to verify which users and groups exist in the Björklunda OUs and to show group membership.

The script checks:

* users inside `Bjorklunda > Users`
* groups inside `Bjorklunda > Groups`
* members of each department group

This makes it easier to prove that the account structure exists and that users are placed in the correct groups.

### Script screenshot

I saved a screenshot showing the Part 5 scripts in VS Code.

![Screenshot 22 - AD account management scripts](screenshots/screenshot-22.png)

### Notes about the lab workflow

The AD users and groups were first created manually in Active Directory Users and Computers because VMware clipboard paste caused formatting problems when trying to paste longer PowerShell commands into the Windows Server VM.

After that, I created scripts in the repository to document how the same structure can be automated.

This is useful for the portfolio because the scripts show the intended automation logic even if the first setup was done manually.

### Part 5 status

The Active Directory script preparation is completed.

The IdM Bash script part is still pending because `srv-idm01` has not been fully configured yet in this lab workflow. When the IdM server is ready, the Bash account creation script and IdM user verification can be added.


## Part 6 — Shared folders and permissions

## Part 7 — Printing system

## Part 8 — Virtualization

## Part 9 — Laws and security

## Part 10 — Advice and support

## Part 11 — Environment reflection
