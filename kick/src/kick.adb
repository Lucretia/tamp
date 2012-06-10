--                              -*- Mode: Ada -*-
--  Filename        : kick.adb
--  Description     : Kickstart the operating system on the machine, i.e.
--                    Initialise the hardware ready for the kernel entry point.
--  Author          : Luke A. Guest
--  Created On      : Sun Jun 10 16:44:12 2012

procedure Kick is
begin
   --  The system image will be loaded by:
   --    GRUB      - PC
   --    VideoCore - RPi
   
   --  The system image will contain the necessary modules that are required
   --  for an OS to kickstart itself, i.e.
   --    This program, Kick.
   --    The TAMP kernel.
   --    Memory server - if we end up with one.
   --    Name server - provides a mechanism for naming things like files.
   --    Scheduler.
   --    Device drivers:
   --      USB
   --        Keyboard
   --        Mouse - if we need it
   --      SD card
   --        FAT Filesystem
   --      Ethernet
   --      Timer
   --
   --  GRUB on PC will have configured the machine to a certain point, similar
   --  with the binary blob on RPi. Kick will continue this initialisation so
   --  that rest of the machine can be configured the way we need. On 64-bit
   --  PC machines, we need to go a step further to enable long mode.
   --
   --  Kick will set up the memory pages that are available and also those which
   --  are used (i.e. all the modules already in the system image will be
   --  "used").
   --
   --  Kick will assign these module's pages to a set of system processes, i.e.
   --  Address Spaces, these will then be ready to run. So, Kick needs to know
   --  about TAMP's process structure.
   --
   --  TAMP needs to know which scheduler to use, so Kick must tell TAMP what
   --  that is, otherwise, when we jump to the kernel, the kernel won't be able
   --  to schedule any processes.
   --    ** What is a scheduler? A simple procedure or a full process/service?
   --
   --  Kick will set the pages used by it's own program as being free so that
   --  they can be reused by the kernel.
   --
   --  Kick will no jump into the TAMP kernel by calling it's initialise
   --  subprogram. We will not return to Kick as TAMP will take over ending
   --  by calling it's scheduler to start the processes we have loaded from
   --  the system image.
   --
   --  Whilst Kick will have access to the framebuffer's or serial lines for
   --  debug information, once TAMP is running there will need to be display
   --  drivers running, whether that is a framebuffer or access to 3D
   --  hardware. At this point, this driver will have a standard interface and
   --  a defined way of accessing it, as with all drivers.
end Kick;
pragma No_Return (Kick);

