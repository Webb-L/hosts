# HTTP服务器模块

这个模块为Hosts Editor应用提供了内置的HTTP服务器功能，允许通过RESTful API远程管理hosts文件。

## 功能特性

- 🚀 内置HTTP服务器，支持RESTful API
- 📝 完整的hosts文件CRUD操作
- 🔧 灵活的服务器配置管理
- 🎯 CORS支持，允许跨域访问
- 📱 集成的Flutter设置页面
- 🔄 自动启动功能
- 📋 完整的API文档

## 模块结构

```
lib/server/
├── hosts_server.dart      # HTTP服务器核心实现
├── server_manager.dart    # 服务器生命周期管理
├── server_settings_page.dart # Flutter设置页面
├── example.dart          # 使用示例
├── index.dart           # 模块导出
└── README.md           # 模块文档
```

## 快速开始

### 1. 基本使用

```dart
import 'package:hosts/server/index.dart';

// 创建并启动服务器
final serverManager = ServerManager();
await serverManager.initialize();
await serverManager.startServer();

// 服务器现在运行在 http://localhost:1204
print('服务器URL: ${serverManager.server.serverUrl}');
```

### 2. 自定义配置

```dart
// 更新服务器配置
await serverManager.updateServerConfig(
  port: 9090,
  host: '0.0.0.0',
  autoStart: true,
);

// 启动服务器
await serverManager.startServer();
```

### 3. 在Flutter应用中集成

```dart
// 在main函数中初始化
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final serverManager = ServerManager();
  await serverManager.initialize();
  
  runApp(MyApp());
}

// 在设置页面中添加服务器设置
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ServerSettingsPage(),
  ),
);
```

## API接口

### 服务器状态
- `GET /` - 获取服务器状态和API文档

### Hosts文件管理
- `GET /api/hosts` - 获取所有hosts文件列表（JSON格式）
- `GET /api/hosts/{fileId}` - 获取特定hosts文件内容（纯文本格式）

### 历史记录管理
- `GET /api/hosts/{fileId}/history` - 获取hosts文件历史记录（JSON格式）
- `GET /api/hosts/{fileId}/history/{historyId}` - 获取特定历史记录内容（纯文本格式）

## API示例

### 获取所有hosts文件
```bash
curl http://localhost:1204/api/hosts
```

响应：
```json
{
  "success": true,
  "data": [
    {"fileName": "system", "remark": "系统默认"},
    {"fileName": "custom", "remark": "自定义配置"}
  ]
}
```

### 获取hosts文件内容（纯文本）
```bash
curl http://localhost:1204/api/hosts/system
```

响应（纯文本）：
```
127.0.0.1 localhost
::1 localhost
# 这里是hosts文件的实际内容
```

### 获取hosts文件历史记录（JSON）
```bash
curl http://localhost:1204/api/hosts/system/history
```

响应（JSON）：
```json
{
  "success": true,
  "data": [
    {
      "id": "1672531200000",
      "fileName": "1672531200000", 
      "timestamp": "1672531200000",
      "createTime": "2023-01-01T00:00:00.000Z"
    }
  ]
}
```

### 获取特定历史记录内容（纯文本）
```bash
curl http://localhost:1204/api/hosts/system/history/1672531200000
```

响应（纯文本）：
```
127.0.0.1 localhost
::1 localhost
# 这里是历史记录的实际内容
```

## 配置选项

| 选项 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| port | int | 1204 | 服务器端口号 |
| host | String | 'localhost' | 服务器绑定地址 |
| autoStart | bool | false | 应用启动时自动启动服务器 |

## 安全注意事项

1. **网络访问**: 默认只绑定到localhost，如需远程访问请谨慎设置host为0.0.0.0
2. **端口冲突**: 确保选择的端口未被其他应用占用
3. **文件权限**: 系统hosts文件操作可能需要管理员权限
4. **CORS策略**: 当前配置允许所有来源的跨域请求，生产环境请根据需要调整

## 故障排除

### 服务器启动失败
- 检查端口是否被占用
- 确认防火墙设置
- 验证host地址格式

### API请求失败
- 确认服务器正在运行
- 检查请求URL和参数格式
- 查看服务器日志输出

### 权限错误
- 系统hosts文件操作可能需要提升权限
- macOS可能需要授权访问系统文件

## 依赖项

```yaml
dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
```

## 版本历史

- v1.0.0 - 初始版本，基本HTTP服务器功能
- 支持完整的hosts文件CRUD操作
- 集成Flutter设置页面
- 提供自动启动和配置管理功能

## 贡献

欢迎提交Issue和Pull Request来改进这个模块！