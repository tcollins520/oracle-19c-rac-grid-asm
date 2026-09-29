# Oracle 19c RAC, Grid Infrastructure & ASM

A hands-on Oracle Database 19c Real Application Clusters (RAC) implementation using Oracle Grid Infrastructure, ASM, and ASMLIB.

This project documents the complete installation and configuration of a two-node Oracle 19c RAC environment running on Oracle Linux 8.10 ARM64.

## Environment

| Component | Configuration |
|---|---|
| Operating System | Oracle Linux 8.10 ARM64 |
| Database | Oracle Database 19c 19.19 ARM64 |
| Cluster | 2-node Oracle RAC |
| Grid Infrastructure | Oracle Grid Infrastructure 19c |
| ASM | Oracle ASM / Flex ASM |
| ASMLIB | ASMLIB 3 |
| Database Architecture | CDB / PDB |
| Storage | VirtualBox VirtioSCSI shared disks |
| Nodes | rac1 / rac2 |
| Cluster Name | rac-cluster |
| SCAN | orarac-scan |

## RAC Architecture

### RAC Nodes

| Node | Public IP | Private IP | VIP |
|---|---|---|---|
| rac1 | 192.168.56.11 | 192.168.57.11 | 192.168.56.21 |
| rac2 | 192.168.56.12 | 192.168.57.12 | 192.168.56.22 |

### SCAN
~~~
orarac-scan
192.168.56.31
192.168.56.32
192.168.56.33
~~~
### Network Interfaces
~~~
eth0 → NAT / Internet
eth1 → Public RAC network
eth2 → Private RAC interconnect
~~~

## Shared Storage

| Disk | Size | ASM Disk Group | Purpose |
|---|---:|---|---|
| CRS01 | 4 GB | +CRS | Clusterware / Voting |
| DATA01 | 20 GB | +DATA | Database files, Controlfiles, and Spfile |
| FRA01 | 20 GB | +FRA |RMAN Backups, Fast Recovery Area |

ASMLIB labels:

CRS01
DATA01
FRA01

ASM discovery:
~~~
ORCL:CRS01
ORCL:DATA01
ORCL:FRA01
~~~
# Installation & Configuration

1. Oracle Linux 8.10 ARM64 RAC node preparation and OS configuration

2. Oracle 19c preinstallation requirements, kernel parameters, resource limits, swap, and system services

3. RAC public/private network, VIP, SCAN, hostname, and name-resolution configuration

4. Shared VirtualBox VirtioSCSI storage and ASMLIB disk preparation/discovery

5. Passwordless SSH trust for the grid and oracle users between both RAC nodes

6. Cluster Verification Utility (CVU/cvuqdisk) and RAC prerequisite validation

7. X11 forwarding and GUI administration setup for Grid, ASMCA, and DBCA

8. Oracle Grid Infrastructure 19c cluster creation and Clusterware configuration

9. OCR, voting disk, SCAN listener, VIP, and Clusterware resource configuration

10. ASM Flex ASM configuration and ASM disk group creation with ASMCA

11. Oracle Database 19c ARM64 RAC software installation on both RAC nodes

12. RAC CDB/PDB creation with DBCA, including OMF, FRA, archiving, and automatic memory management

13. Post-installation RAC validation — database, ASM, listeners, SPFILE, control files, redo logs, datafiles, and PDB

## Key Oracle Components

- Oracle RAC
- Oracle Grid Infrastructure
- Oracle Clusterware
- Oracle ASM
- Flex ASM
- ASMLIB
- OCR
- Voting Disks
- SCAN
- SCAN Listeners
- Node VIPs
- RAC Private Interconnect
- Oracle CDB/PDB
- Oracle Managed Files
- Fast Recovery Area
- Oracle Database 19c
- ASMCA
- DBCA
- ASMCMD
- SRVCTL
- CRSCTL
- CVU

## Validation

The completed environment was validated at the cluster, ASM, database, listener, storage, and PDB levels.

### Cluster

olsnodes -n -s
crsctl check cluster -all
crsctl stat res -t

### ASM

srvctl status asm
asmcmd lsdg

### Database

SELECT name, open_mode
FROM v$database;

SELECT instance_name, status
FROM gv$instance;

### PDB

SHOW PDBS;

### ASM Storage

SELECT name,
       state,
       type,
       total_mb,
       free_mb
FROM v$asm_diskgroup;

## Documentation

The repository includes installation and administration documentation covering the complete RAC build.

### Installation & Configuration

- Oracle Linux RAC node preparation
- Oracle 19c prerequisites
- RAC networking
- Shared storage and ASMLIB
- Passwordless SSH
- CVU and prerequisite validation
- X11 configuration
- Grid Infrastructure
- Clusterware
- ASM
- Oracle Database 19c RAC software
- RAC CDB/PDB creation
- Post-installation validation

### Cluster Administration

- Cluster status
- Cluster start/stop
- Cluster resources
- OCR
- Voting disks
- ASM
- ASM disk groups
- ASMCMD
- SCAN listeners
- RAC services
- Database instance management
- RAC validation

## Project Objectives
~~~
The objective of this project was to build a complete Oracle 19c RAC environment from the infrastructure layer through database deployment and validation.

Infrastructure
    ↓
Oracle Linux
    ↓
Networking
    ↓
Shared Storage
    ↓
ASMLIB
    ↓
Grid Infrastructure
    ↓
Clusterware
    ↓
ASM
    ↓
Oracle Database 19c RAC
    ↓
CDB / PDB
    ↓
Validation & Administration
```
## Project Focus

Oracle Database Administration | Oracle RAC | Grid Infrastructure | ASM | Linux | Cloud/Infrastructure Engineering

This project demonstrates end-to-end implementation of an Oracle RAC platform, including infrastructure preparation, cluster configuration, shared storage, ASM, database deployment, and operational validation.
