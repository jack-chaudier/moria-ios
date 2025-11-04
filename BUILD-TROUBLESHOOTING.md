# Build Troubleshooting Guide

## Common Build Issues

### 1. Files Not Found
If Xcode says it can't find certain files:
- Make sure all Swift files are in the `moria/` directory
- Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
- Close and reopen Xcode

### 2. Minimum iOS Version
The app requires iOS 17.0+. Check your deployment target:
- Select project in navigator
- Under "Deployment Info", set **iOS Deployment Target** to **17.0**

### 3. Missing Imports
All files should have:
```swift
import SwiftUI
import Foundation
import Combine // (where needed)
```

### 4. Common Error Fixes

#### "Cannot find type 'X' in scope"
This usually means a file isn't being compiled. Try:
1. Clean build folder (⇧⌘K)
2. Rebuild (⌘B)

#### "Value of type 'Y' has no member 'z'"
Check that all model properties match exactly (case-sensitive)

#### "Missing argument label 'xxx:' in call"
Check function signatures match the usage

## Quick Fix Steps

1. **Clean Build**: ⇧⌘K
2. **Rebuild**: ⌘B
3. **Restart Xcode**: Close completely and reopen
4. **Check File Structure**:
```
moria/
├── Network/
│   ├── APIClient.swift
│   └── WebSocketClient.swift
├── Models/
│   ├── User.swift
│   ├── Message.swift
│   ├── File.swift
│   ├── Vault.swift
│   ├── Notification.swift
│   └── Organization.swift
├── Services/
│   ├── MessageService.swift
│   ├── FileService.swift
│   ├── VaultService.swift
│   └── SecurityService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   └── MessagesViewModel.swift
├── Views/
│   ├── Authentication/
│   │   └── LoginView.swift
│   ├── Messages/
│   │   └── MessagesView.swift
│   ├── Testing/
│   │   └── ConnectionTestView.swift
│   └── MainTabView.swift
├── Design/
│   └── DesignSystem.swift
├── Utilities/
│   └── KeychainManager.swift
├── ContentView.swift
└── moriaApp.swift
```

5. **Verify iOS SDK**: Xcode → Settings → Locations → Command Line Tools is set

## If Build Still Fails

Please share the error messages from Xcode:
1. Click the error icon in top bar
2. Or open Issue Navigator (⌘+5)
3. Copy all error messages
4. Share them so we can fix the specific issues

## Quick Test

Try building with just the basic files first:
- moriaApp.swift
- ContentView.swift
- DesignSystem.swift

If that works, the issue is in one of the other files.
