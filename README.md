# ldprotect

QQ: 20667728

locustwei@outlook.com

#### 介绍
驱动保护文件、隐藏文件、进程保护.

文件保护：保护文件（夹）不被删除、读取、修改、重命名。
隐藏文件：文件本身不会任何形式的修改或移到，但不会被如资源管理器、命令（dir）或其它
          列举文件的程序列举出来，除非进行文件分配表扫描。
进程保护：保护正在运行的进程不被强制终止、远程内存读写、进程注入，
          也可以禁止指定文件名运行


#### 安装教程

安装 LdProtec.inf，驱动安装后重启系统，或手动启动驱动（命令行执行 sc ）

说明：Windows 64位系统驱动需要数字签名（有关驱动数字签名参考https://docs.microsoft.com/zh-cn/windows-hardware/drivers/install/windows-driver-signing-tutorial）
      32系统位则不需要。可以禁用Windows驱动数字签名测试（有关如何禁用签名请Google）

