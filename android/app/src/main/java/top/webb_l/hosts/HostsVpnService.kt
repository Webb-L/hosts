package top.webb_l.hosts

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import kotlin.concurrent.thread

class HostsVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onDestroy() {
        super.onDestroy()
        // 清理资源
        vpnInterface?.close()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 启动 VPN
        startVpn()
        return START_STICKY
    }

    private fun startVpn() {
        // 配置 VPN
        val builder = Builder()
        builder.setSession("MyVPN")
            .addAddress("10.0.0.2", 24) // VPN 地址
            .addRoute("0.0.0.0", 0) // 路由

        vpnInterface = builder.establish()

        // 这里是处理网络流量的逻辑
        // 你需要实现读取数据包、解析 DNS 请求、根据 hosts 文件进行重定向等
        Log.e("TAG", "run: ${vpnInterface}")
        val inputStream = FileInputStream(vpnInterface!!.fileDescriptor)
        val outputStream = FileOutputStream(vpnInterface!!.fileDescriptor)

        val buffer = ByteArray(32767)
        thread {
            while (true) {
                // 读取数据包
                val length = inputStream.read(buffer)
                if (length > 0) {
                    // 处理数据包
                    // 这里可以添加 DNS 解析和 hosts 文件的处理逻辑
                    Log.e("TAG", "startVpn: ${String(buffer, 0, length)}", )
                    // 将数据包写回输出流
                    outputStream.write(buffer, 0, length)
                }
            }
        }
    }
}
