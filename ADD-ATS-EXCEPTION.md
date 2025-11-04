# Add ATS Exception Through Xcode

Your backend certificate is for "localhost" but you're connecting to `3.141.170.173`, causing a hostname mismatch. You need to add an App Transport Security exception.

## Steps to Add ATS Exception in Xcode:

### 1. Select Project
- Click on **"moria"** (top item in Project Navigator - left sidebar)

### 2. Select Target
- Under TARGETS, click **"moria"**

### 3. Go to Info Tab
- Click the **"Info"** tab at the top

### 4. Add App Transport Security Settings

**Right-click** anywhere in the list and select **"Add Row"** (or click the + button), then:

#### Add these keys in order:

```
App Transport Security Settings (Dictionary)
  └─ Exception Domains (Dictionary)
      └─ 3.141.170.173 (Dictionary)
          ├─ NSExceptionAllowsInsecureHTTPLoads (Boolean) = YES
          ├─ NSIncludesSubdomains (Boolean) = YES
          └─ NSExceptionRequiresForwardSecrecy (Boolean) = NO
```

### Step-by-Step:

1. **Click +** next to any key
2. Type: **"App Transport Security Settings"** → Press Enter
   - Type should be: **Dictionary**

3. **Click the disclosure triangle** to expand it
4. **Click +** next to "App Transport Security Settings"
5. Type: **"Exception Domains"** → Press Enter
   - Type should be: **Dictionary**

6. **Click the disclosure triangle** to expand "Exception Domains"
7. **Click +** next to "Exception Domains"
8. Type: **"3.141.170.173"** → Press Enter
   - Change Type dropdown from "String" to **Dictionary**

9. **Click the disclosure triangle** to expand "3.141.170.173"
10. **Click +** next to "3.141.170.173" THREE times and add:
    - Key: **NSExceptionAllowsInsecureHTTPLoads** → Type: **Boolean** → Value: **YES**
    - Key: **NSIncludesSubdomains** → Type: **Boolean** → Value: **YES**
    - Key: **NSExceptionRequiresForwardSecrecy** → Type: **Boolean** → Value: **NO**

### After Adding:

1. **Clean Build**: `⇧⌘K`
2. **Build**: `⌘B`
3. **Run**: `⌘R`

The app should now connect successfully!

## Why This Is Needed

Your backend SSL certificate is for "localhost" but you're connecting to the IP address `3.141.170.173`. This causes a hostname mismatch, which iOS rejects.

The ATS exception tells iOS to allow the connection despite the mismatch.

## For Production

Either:
1. **Generate a certificate with the IP in SAN** (Subject Alternative Name)
2. **Use a domain name** and get a proper certificate (recommended)
3. **Implement proper certificate pinning**

But for development testing, this exception is fine! ✅
