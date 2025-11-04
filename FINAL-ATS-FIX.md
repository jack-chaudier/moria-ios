# Final ATS Configuration for Self-Signed Certificates

Your backend certificate is now correct (shows `3.141.170.173`), but it's **self-signed** and not trusted by iOS.

## Add This Configuration in Xcode:

### Step-by-Step Instructions:

1. **Open Xcode**
2. **Click "moria" in Project Navigator** (top item in left sidebar)
3. **Select the "moria" target** (under TARGETS)
4. **Click the "Info" tab**
5. **Right-click in the list** and select "Add Row" (or click the + button)

### Add These Exact Keys:

```
App Transport Security Settings
  └─ Exception Domains
      └─ 3.141.170.173
          ├─ NSExceptionAllowsInsecureHTTPLoads = YES
          └─ NSExceptionRequiresForwardSecrecy = NO
```

### Detailed Steps:

1. **Add "App Transport Security Settings"** (Type: Dictionary)
2. Expand it, click +
3. **Add "Exception Domains"** (Type: Dictionary)
4. Expand it, click +
5. **Add "3.141.170.173"** then change Type to Dictionary
6. Expand it, click + twice to add:
   - **NSExceptionAllowsInsecureHTTPLoads** (Boolean) = **YES**
   - **NSExceptionRequiresForwardSecrecy** (Boolean) = **NO**

### Screenshot Reference:

```
▼ App Transport Security Settings           Dictionary
  ▼ Exception Domains                        Dictionary
    ▼ 3.141.170.173                          Dictionary
        NSExceptionAllowsInsecureHTTPLoads   Boolean    YES
        NSExceptionRequiresForwardSecrecy    Boolean    NO
```

## After Adding:

1. **Clean Build**: `⇧⌘K`
2. **Build**: `⌘B`
3. **Run**: `⌘R`

The app will now:
- ✅ Accept self-signed certificates (via SSLPinningDelegate)
- ✅ Connect to HTTPS (via ATS exception)
- ✅ Use TLS 1.3 encryption

## Why Both Are Needed:

- **SSLPinningDelegate**: Accepts the self-signed certificate
- **ATS Exception**: Tells iOS to allow the connection attempt with our delegate

Without the ATS exception, iOS blocks the connection before our delegate can accept the certificate.

## Test After Building:

Run the connection tests - you should see:
```
✅ Server Health - Backend is online and responding
✅ Login - Authentication successful (Token expires in 900s)
✅ Token Verification - Token valid
✅ WebSocket - WebSocket endpoint available
✅ API Request - Authenticated request successful
```

All 5 tests should pass! 🎉
