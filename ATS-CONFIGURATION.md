# Fix App Transport Security for HTTP Connections

The app is failing to connect because iOS blocks HTTP connections by default. Here's how to fix it:

## Option 1: Through Xcode UI (Recommended)

1. **Select the project** in Xcode's navigator (top item named "moria")
2. **Select the "moria" target** (under TARGETS)
3. **Click the "Info" tab** at the top
4. **Find or add "App Transport Security Settings"**:
   - If it doesn't exist: Click the **"+"** button next to any key
   - Type: **"App Transport Security Settings"** (it should autocomplete)
   - It will appear as `NSAppTransportSecurity` (Dictionary)

5. **Expand "App Transport Security Settings"** by clicking the disclosure triangle
6. **Add "Exception Domains"**:
   - Click the **"+"** next to "App Transport Security Settings"
   - Select: **"Exception Domains"** (Dictionary)
   - It will appear as `NSExceptionDomains`

7. **Add exception for your server IP**:
   - Click the **"+"** next to "Exception Domains"
   - Type: **"3.141.170.173"** (String) - then press Enter
   - Change the Type dropdown from "String" to **"Dictionary"**

8. **Configure the exception**:
   - Click the **"+"** next to "3.141.170.173"
   - Add: **"NSExceptionAllowsInsecureHTTPLoads"** (Boolean) = **YES**
   - Click the **"+"** again next to "3.141.170.173"
   - Add: **"NSIncludesSubdomains"** (Boolean) = **YES**

9. **Add exception for localhost** (optional, for local testing):
   - Click the **"+"** next to "Exception Domains"
   - Type: **"localhost"** (String) - then press Enter
   - Change Type to **"Dictionary"**
   - Click the **"+"** next to "localhost"
   - Add: **"NSExceptionAllowsInsecureHTTPLoads"** (Boolean) = **YES**

## Final Structure Should Look Like:

```
App Transport Security Settings (Dictionary)
  └─ Exception Domains (Dictionary)
      ├─ 3.141.170.173 (Dictionary)
      │   ├─ NSExceptionAllowsInsecureHTTPLoads = YES (Boolean)
      │   └─ NSIncludesSubdomains = YES (Boolean)
      └─ localhost (Dictionary)
          └─ NSExceptionAllowsInsecureHTTPLoads = YES (Boolean)
```

## After Adding:

1. **Clean Build**: Press `⇧⌘K`
2. **Rebuild**: Press `⌘B`
3. **Run**: Press `⌘R`

The app should now connect successfully!

---

## Option 2: Edit Info Manually (If Option 1 Doesn't Work)

If the target already has a custom Info.plist file referenced:

1. In Xcode, look at the "Info" tab
2. Right-click on any key and select **"Show Raw Keys/Values"**
3. Add the following raw XML structure:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>3.141.170.173</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

---

## Verification

After rebuilding, you should see in the console:
- ✅ Connection tests passing
- ✅ Login successful
- ✅ No more "ATS policy" errors

## Security Note

⚠️ **This is for DEVELOPMENT ONLY**

For production:
- Use HTTPS with valid SSL certificates
- Remove these ATS exceptions
- Enable certificate pinning
