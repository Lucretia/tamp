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
   
end Kick;
pragma No_Return (Kick);

