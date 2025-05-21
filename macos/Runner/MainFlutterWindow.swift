import Cocoa
import FlutterMacOS
import Security

class MainFlutterWindow: NSWindow {
    private var hostsChannel: FlutterMethodChannel?

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)

        // 设置方法通道
        hostsChannel = FlutterMethodChannel(
            name: "top.webb_l.hosts/system",
            binaryMessenger: flutterViewController.engine.binaryMessenger)

        hostsChannel?.setMethodCallHandler { [weak self] (call, result) in
            print("收到方法调用: \(call.method)")
            switch call.method {
            case "modifyHostsFile":
                if let args = call.arguments as? [String: Any],
                   let hostsContent = args["content"] as? String {
                    self?.modifyHostsFile(content: hostsContent, completion: { success, errorMessage in
                        if success {
                            result(true)
                        } else {
                            result(FlutterError(code: "HOSTS_MODIFY_ERROR",
                                                message: errorMessage,
                                                details: nil))
                        }
                    })
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                        message: "缺少内容参数",
                                        details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        RegisterGeneratedPlugins(registry: flutterViewController)

        super.awakeFromNib()
    }

    func modifyHostsFile(content: String, completion: @escaping (Bool, String?) -> Void) {
        print("尝试修改 Hosts 文件...")

        guard !content.isEmpty else {
            print("内容不能为空")
            completion(false, "Hosts 文件内容不能为空")
            return
        }

        // 1. 将新内容写入临时文件
        let tempFilePath = NSTemporaryDirectory().appending("top.webb_l.hosts.temp")
        do {
            try content.write(toFile: tempFilePath, atomically: true, encoding: .utf8)
        } catch {
            print("写入临时文件失败: \(error)")
            completion(false, "写入临时文件失败: \(error.localizedDescription)")
            return
        }

        // 2. 使用osascript尝试以管理员身份运行命令
        let scriptProcess = Process()
        scriptProcess.launchPath = "/usr/bin/osascript"
        scriptProcess.arguments = [
            "-e", "do shell script \"/bin/cp \(tempFilePath) /etc/hosts\" with administrator privileges"
        ]

        let pipe = Pipe()
        scriptProcess.standardError = pipe
        scriptProcess.standardOutput = pipe

        do {
            try scriptProcess.run()
            scriptProcess.waitUntilExit()

            if scriptProcess.terminationStatus == 0 {
                print("成功修改hosts文件")
                try? FileManager.default.removeItem(atPath: tempFilePath)
                completion(true, nil)
            } else {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorOutput = String(data: data, encoding: .utf8) ?? "未知错误"
                print("执行失败: \(errorOutput)")
                completion(false, "操作失败: \(errorOutput)")
            }
        } catch {
            print("启动进程失败: \(error)")
            completion(false, "无法启动进程: \(error.localizedDescription)")
        }

        // 清理临时文件
        try? FileManager.default.removeItem(atPath: tempFilePath)
    }
}
