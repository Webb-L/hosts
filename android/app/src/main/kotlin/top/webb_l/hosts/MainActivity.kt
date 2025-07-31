package top.webb_l.hosts

import android.content.Intent
import android.net.VpnService
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        val intent = VpnService.prepare(this)
        startService(Intent(this, HostsVpnService::class.java))
        Log.e("TAG", "configureFlutterEngine: ", )
//        if (intent != null) {
//            startActivityForResult(intent, 0)
//        } else {
//            onActivityResult(0, RESULT_OK, null)
//        }
        super.configureFlutterEngine(flutterEngine)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode == RESULT_OK) {
            startService(Intent(this, HostsVpnService::class.java))
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
