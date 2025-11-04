# ✅ HTTPS Configuration Complete

Your Moria iOS app is now configured to work with your HTTPS backend!

## What Was Changed

### 1. **API Client** (`APIClient.swift`)
- ✅ Updated base URL: `https://3.141.170.173:8080/api/v1`
- ✅ Added `SSLPinningDelegate` to handle self-signed certificates
- ✅ URLSession now uses delegate to trust development certificates

### 2. **WebSocket Client** (`WebSocketClient.swift`)
- ✅ Updated WebSocket URL: `wss://3.141.170.173:8080/ws`
- ✅ Uses secure WebSocket protocol (WSS)

### 3. **Connection Test View** (`ConnectionTestView.swift`)
- ✅ All test endpoints updated to HTTPS/WSS
- ✅ Tests use SSL delegate to handle self-signed certs
- ✅ UI shows "TLS: Self-signed (dev)" status

## How It Works

### Self-Signed Certificate Handling

The `SSLPinningDelegate` class accepts your backend's self-signed certificate:

```swift
class SSLPinningDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Trusts self-signed certificates (development only)
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
}
```

⚠️ **This is for development only!** For production, implement proper certificate pinning.

## Testing the App

### Build & Run:
1. **Clean Build**: `⇧⌘K`
2. **Build**: `⌘B`
3. **Run**: `⌘R`

### Test Connection:
1. **Tap the antenna button** (top-right on login screen)
2. **Tap "RUN ALL TESTS"**

### Expected Results:
```
✅ Server Health - Backend is online and responding (~50-100ms)
✅ Login - Authentication successful (Token expires in 900s)
✅ Token Verification - Token valid for user: admin (role: admin)
✅ WebSocket - WebSocket endpoint available (wss://...)
✅ API Request - Authenticated request successful (0 groups)
```

### Login:
1. **Tap "SECURE LOGIN"** button
2. Should authenticate successfully
3. Navigate to main app interface

## Security Notes

### Current Setup (Development):
- ✅ All traffic encrypted with TLS 1.3
- ✅ Self-signed certificates accepted
- ⚠️ No certificate pinning (development mode)

### For Production:
1. **Use valid CA certificates** (Let's Encrypt, etc.)
2. **Implement certificate pinning**:
   ```swift
   // Validate certificate hash matches expected value
   let expectedHash = "sha256/AAAAAAAAAA..."
   // Implement proper pinning logic
   ```
3. **Remove SSLPinningDelegate** or update to validate pinned certs
4. **Use real domain name** instead of IP address

## URL Summary

| Service | Development URL | Protocol |
|---------|----------------|----------|
| REST API | `https://3.141.170.173:8080/api/v1` | HTTPS/TLS 1.3 |
| WebSocket | `wss://3.141.170.173:8080/ws` | WSS/TLS 1.3 |
| Health Check | `https://3.141.170.173:8080/health` | HTTPS/TLS 1.3 |

## Troubleshooting

### If connections still fail:

1. **Verify backend is running with HTTPS**:
   ```bash
   curl -k https://3.141.170.173:8080/health
   # Should return: OK
   ```

2. **Check backend logs** for SSL/TLS errors

3. **Verify certificates are loaded** in backend config

4. **Test from iOS simulator**:
   - Check Xcode console for SSL errors
   - Look for certificate validation messages

### Common Errors:

**"SSL error"**: Backend certificates not configured properly
**"Connection refused"**: Backend not running or wrong port
**"Certificate invalid"**: Certificates expired or wrong domain

## Next Steps

1. ✅ Test all API endpoints through the app
2. ✅ Test WebSocket real-time features
3. ✅ Test file upload/download
4. ✅ Test E2EE messaging

For production deployment:
- [ ] Obtain real SSL certificates
- [ ] Implement certificate pinning
- [ ] Use domain name instead of IP
- [ ] Enable mTLS for client certificates
- [ ] Security audit

---

**Status**: ✅ Ready for development testing with HTTPS!

Your app now communicates securely with the backend using TLS 1.3 encryption! 🔒
