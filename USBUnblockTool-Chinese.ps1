<#
.SYNOPSIS
    检测导致 USB/外接硬盘无法弹出的占用进程。
    基于 Windows 事件日志 (Kernel-PnP Event ID 225)。

.DESCRIPTION
    当用户尝试弹出设备失败后，运行此脚本。
    脚本会查找最近生成的“弹出失败”系统日志，并解析出占用设备的进程名称和 PID。

.NOTES
    需要管理员权限运行 (Run as Administrator) 才能读取系统日志。
#>

<#
    自动请求管理员权限的头部代码
    如果不加这段，双击运行默认是普通用户，无法读取系统日志和系统进程路径。
#>
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # 获取当前脚本的完整路径
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # 重新启动 PowerShell，并带上 -Verb RunAs 参数（请求管理员）
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    
    # 关闭当前的普通权限窗口
    Exit
}

# 设置控制台编码，防止中文乱码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      外接设备占用检测工具 (基于事件日志)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 提示用户操作
Write-Host "⚠️  请注意：此工具依赖于系统的弹出失败记录。" -ForegroundColor Yellow
Write-Host "1. 请先尝试点击右下角的'弹出 USB 设备'。"
Write-Host "2. 等到 Windows 提示'设备正在使用中'后..."
Write-Host "3. 按任意键开始检测..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`n正在扫描系统日志..." -ForegroundColor Green

try {
    # 获取最近 5 条 Kernel-PnP 的 225 事件 (设备无法移除)
    # Event ID 225: 应用程序 X 阻止了移除或弹出设备 Y。
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-Kernel-PnP'
        ID = 225
    } -ErrorAction Stop -MaxEvents 5

    if ($events) {
        $found = $false
        
        foreach ($evt in $events) {
            # 检查事件时间，只看最近 5 分钟内的，避免误报旧信息
            if ($evt.TimeCreated -gt (Get-Date).AddMinutes(-5)) {
                $found = $true
                $msg = $evt.Message
                
                # 使用正则表达式提取进程 ID (PID) 和 进程路径
                # 典型消息格式：进程 1234 (应用.exe) 停止了移除或弹出...
                # 或者：The application \Device\HarddiskVolume...\xxx.exe with process id 1234 stopped...
                
                Write-Host "------------------------------------------"
                Write-Host "发现时间: $($evt.TimeCreated.ToString('HH:mm:ss'))" -ForegroundColor White
                
                # 尝试提取 PID
                if ($msg -match "process id (\d+)") {
                    $pidValue = $matches[1]
                    
                    # 尝试获取当前进程状态
                    try {
                        $proc = Get-Process -Id $pidValue -FileVersionInfo -ErrorAction SilentlyContinue
                        if ($proc) {
                            Write-Host "占用进程: $($proc.FileName)" -ForegroundColor Red
                            Write-Host "进程 ID : $pidValue" -ForegroundColor Yellow
                            Write-Host "窗口标题: $($proc.MainWindowTitle)"
                            
                            # 询问是否结束进程
                            Write-Host "`n想要强制结束该进程吗？(不推荐)(Y/N)" -NoNewline
                            $response = Read-Host
                            if ($response -eq 'Y' -or $response -eq 'y') {
                                Stop-Process -Id $pidValue -Force
                                Write-Host "进程已结束！请尝试重新弹出。" -ForegroundColor Green
                            }
                        } else {
                            Write-Host "占用进程 (PID: $pidValue) 似乎已经自行关闭了。" -ForegroundColor Gray
                        }
                    } catch {
                        Write-Host "无法获取 PID $pidValue 的详细信息。" -ForegroundColor Red
                    }
                } else {
                    # 如果正则没匹配到，直接显示原始消息辅助判断
                    Write-Host "日志详情: $msg" -ForegroundColor Gray
                }
            }
        }

        if (-not $found) {
            Write-Host "❌ 最近 5 分钟内没有找到'弹出失败'的记录。" -ForegroundColor Red
            Write-Host "可能原因：你还没有点击'弹出'，或者系统没有记录该事件。"
        }
    }
}
catch {
    Write-Host "❌ 未找到相关日志，或没有权限读取日志。" -ForegroundColor Red
    Write-Host "请确保右键点击脚本选择 '以管理员身份运行'。" -ForegroundColor Yellow
}

Write-Host "`n检测结束，按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")