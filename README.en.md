# ldprotect

QQ: 20667728

locustwei@outlook.com

#### introduce
Drive protection files, hidden files, process protection.

File Protection: Protect files (folders) from being deleted, read, modified, and renamed.
Hidden files: The files themselves are not modified or moved in any way, but are not
           Programs that enumerate files are enumerated unless a file allocation table scan is performed.
Process protection: protect running processes from being forced to terminate, read and write remote memory, process injection,
           It is also possible to prohibit the specified file name from running


#### Installation Tutorial

Install LdProtec.inf, restart the system after the driver is installed, or start the driver manually (execute sc on the command line)

Note: The signature of the driver file LdPortect.sys is a test driver signature. If you want to install and test, you need to enter the test mode of the Windows system to start the driver.
       See: Command bcdedit /set testsigning on.