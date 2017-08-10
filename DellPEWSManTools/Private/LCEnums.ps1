Add-Type -TypeDefinition @"
   public enum PowerState
   {
      PowerOn = 2,
      PowerOff = 3,
      PowerCycle = 11
   }
"@

Add-Type -TypeDefinition @"
   public enum ShareType
   {
      NFS = 0,
      CIFS = 2,
      VFLASH = 4
   }
"@

Add-Type -TypeDefinition @"
   public enum HashType
   {
      MD5 = 1,
      SHA1 = 2
   }
"@

Add-Type -TypeDefinition @"
   public enum ExportUse
   {
      Default = 0,
      Clone = 1,
      Replace = 2
   }
"@

Add-Type -TypeDefinition @"
   public enum ShutdownType
   {
      Graceful = 0,
      Forced = 1
   }
"@

Add-Type -TypeDefinition @"
   public enum ResetType
   {
      Graceful = 0,
      Forced = 1
   }
"@

Add-Type -TypeDefinition @"
   public enum ConfigJobRebootType
   {
      None = 0,
      PowerCycle = 1,
      Graceful = 2,
      Forced = 3
   }
"@

Add-Type -TypeDefinition @"
    public enum EndHostPowerState
    {
        Off=0,
        On=1
    }
"@

Add-Type -TypeDefinition @"
    public enum JobType
    {
        Staged=0,
        Realtime=1
    }
"@

Add-Type -TypeDefinition @"
    public enum TechSupportSelector
    {
        HWDATA=0,
        OSAPPDATAWithoutPII=1,
        OSAPPDATA=2,
        TTYLOGS=3
    }
"@

Add-Type -TypeDefinition @"
    public enum OSAPPUpdateType
    {
        AgentLiteOSPlugin = 0,
        Manual=1
    }
"@

Add-Type -TypeDefinition @"
    using System;

    namespace iDRAC {
        [FlagsAttribute]
        public enum Privileges
        {
            Admin = 511,
            Operator = 499,
            Debug = 256,
            SystemOperation = 128,
            AccessVirtualMedia = 64,
            AccessVirtualConsole = 32,
            SystemControl = 16,
            Logs = 8,
            ConfigureUser = 4,
            Configure = 2,
            Login = 1,
            ReadOnly = 1
        }
    }
"@

Add-Type -TypeDefinition @"
    using System;

    namespace Disk {
        [FlagsAttribute]
        public enum BusProtocol
        {
            Unknown = 0,
            SCSI = 1,
            PATA = 2,
            FIBRE = 3,
            USB = 4,
            SATA = 5,
            SAS = 6,
            PCIe = 7
        }

        [FlagsAttribute]
        public enum MediaType
        {
            HDD = 0,
            SSD = 1
        }
    }
"@