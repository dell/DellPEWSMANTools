## NOTE: This repository is archived and is read-only. For PowerShell commands to manage Dell PowerEdge Servers, see https://github.com/dell/iDRAC-Redfish-Scripting

# PowerShell Tools for Dell EMC PowerEdge Server Management (WS-MAN) #
### Using the iDRAC with Lifecycle Controller WS-MAN API with PowerShell scripting to automate PowerEdge management ###

## iDRAC with Lifecycle Controller Overview ##
The Integrated Dell Remote Access Controller (iDRAC) is designed to enhance the productivity of server administrators and improve the overall availability of PowerEdge servers. iDRAC alerts administrators to server problems, enabling remote server management, and reducing the need for an administrator to physically visit the server. iDRAC with Lifecycle Controller allows administrators to deploy, update, monitor and manage Dell servers from any location without the use of agents in a one-to-one or one-to-many method. This out-of-band management allows configuration changes and firmware updates to be managed from Dell EMC, appropriate third-party consoles, and custom scripting directly to iDRAC with Lifecycle Controller using supported industry-standard API’s. 

The iDRAC with Lifecycle Controller includes support for the IPMI, SNMP, WS-Man, and Redfish standard APIs. 

For complete information concerning iDRAC with Lifecycle Controller, see the documents at http://www.dell.com/idracmanuals

## WS-MAN Overview ##
Web Services-Management also known as WS-Management or WS-MAN, is a DMTF open standard defining a SOAP-based protocol for the management of servers, devices, applications and various Web services. WS-MAN provides a common way for systems to access and exchange management information across the IT infrastructure. The specification, based on DMTF open standards and Internet standards for Web services, supports get/set of simple variables and more complex operations. Developed by a coalition of vendors, WS-MAN was published as a V1.1 standard in March 2010.

For more details on WS-MAN, see the DMTF specifications at https://www.dmtf.org/standards/wsman 

## DellPEWSMANTools Overview ##
The DellPEWSMANTools repository contains a robust library of Microsoft PowerShell cmdlets, enabling PowerShell scripting to perform a range of server lifecycle operations including:

-	Reset and power control
-	Inventory hardware and firmware
-	Configure all server components including BIOS, iDRAC, RAID, and networking
-	Manage OS deployment
-	Access server logs

