# Authentication Module Documentation

## 🔥 **BACKEND INTEGRATION COMPLETED** ✅

### **Overview**
The authentication module now has **full backend integration** with the ZeroWasteAI API, combining Firebase Authentication with JWT tokens for secure backend communication.

### **Architecture**
- **Frontend**: Firebase Auth (Google, Apple, Facebook, Email/Password)
- **Backend**: JWT tokens with automatic refresh
- **Storage**: Secure token storage with encryption
- **Sync**: Firestore + MySQL hybrid architecture

---

## 🚀 **How It Works**

### **Authentication Flow**
1. **User signs in** with Firebase (any provider)
2. **Firebase ID Token** is obtained
3. **Backend exchange** Firebase token → JWT tokens
4. **Secure storage** of access/refresh tokens
5. **Automatic token refresh** for API calls

### **Supported Sign-In Methods**
- ✅ **Email/Password** - Traditional authentication
- ✅ **Google Sign-In** - OAuth integration
- ✅ **Apple Sign-In** - iOS native authentication
- ⚠️ **Facebook Sign-In** - Requires additional setup

---

## 📱 **Usage Examples**

### **Basic Sign-In**
```dart
// Email/Password Sign-In
await ref.read(authControllerProvider.notifier)
  .signInWithEmailAndPassword('user@example.com', 'password123');

// Google Sign-In
await ref.read(authControllerProvider.notifier)
  .signInWithGoogle();

// Apple Sign-In
await ref.read(authControllerProvider.notifier)
  .signInWithApple();
```

### **Auth State Listening**
```dart
// Listen to auth state changes
ref.listen<AsyncValue>(authControllerProvider, (_, state) {
  state.whenData((user) {
    if (user != null) {
      // User is signed in
      context.go('/home');
    } else {
      // User is signed out
      context.go('/login');
    }
  });
});

// Get current auth state
final authState = ref.watch(authControllerProvider);
final user = authState.value; // UserModel? or null
```

### **User Profile Management**
```dart
// Update user profile
await ref.read(authControllerProvider.notifier)
  .updateUserProfile(
    displayName: 'New Name',
    photoURL: 'https://example.com/photo.jpg',
  );

// Save user preferences (stored in Firestore)
final authRepo = ref.read(authRepositoryProvider);
await authRepo.saveUserCookingLevel('intermediate');
await authRepo.saveUserLanguage('es');
await authRepo.saveUserAllergyItems(['nuts', 'seafood']);
```

---

## 🔧 **Configuration**

### **Enable/Disable Backend**
```dart
// lib/features/auth/application/providers/auth_config.dart
class AuthConfig {
  static const bool USE_BACKEND_AUTH = true; // Set to false for testing
  static const bool ENABLE_GOOGLE_SIGNIN = true;
  static const bool ENABLE_APPLE_SIGNIN = true;
  static const bool ENABLE_FACEBOOK_SIGNIN = false; // Requires setup
}
```

### **Debug Flags**
```dart
static const bool DEBUG_AUTH_FLOW = true;
static const bool DEBUG_TOKEN_STORAGE = true;
static const bool DEBUG_BACKEND_INTEGRATION = true;
```

---

## 🔐 **Security Features**

### **Token Management**
- ✅ **Secure Storage** - Encrypted token storage
- ✅ **Auto Refresh** - Automatic token renewal
- ✅ **Expiration Handling** - Proactive token refresh
- ✅ **Logout Cleanup** - Complete token cleanup

### **Backend Integration**
- ✅ **JWT Authentication** - Secure API communication
- ✅ **Firebase Sync** - ID token exchange
- ✅ **Error Handling** - Comprehensive error management
- ✅ **Rate Limiting** - Built-in API protection

---

## 📊 **API Endpoints Used**

### **Authentication Endpoints**
- `POST /api/auth/firebase-signin` - Exchange Firebase token for JWT
- `POST /api/auth/refresh` - Refresh JWT tokens
- `POST /api/auth/logout` - Invalidate all tokens

### **User Profile Endpoints**
- `GET /api/user/profile` - Get complete user profile
- `PUT /api/user/profile` - Update user profile

---

## 🐛 **Troubleshooting**

### **Common Issues**

#### **"Failed to get Firebase ID token"**
- Ensure user is properly authenticated with Firebase
- Check network connectivity
- Verify Firebase configuration

#### **"Backend authentication failed"**
- Check if backend server is running
- Verify API base URL in configuration
- Check backend logs for detailed errors

#### **"Token refresh failed"**
- May indicate expired refresh token
- User needs to sign in again
- Check secure storage permissions

### **Debug Steps**
1. **Enable debug flags** in `AuthConfig`
2. **Check console logs** for detailed error messages
3. **Verify network requests** in development tools
4. **Test with different auth providers**

---

## 🔄 **Migration from Mock Auth**

If you were using mock authentication before:

1. **Update providers** - No changes needed, already using `authControllerProvider`
2. **Backend integration** - Automatically enabled with `USE_BACKEND_AUTH = true`
3. **Token storage** - Automatically handled by `SecureTokenService`
4. **Error handling** - Enhanced error messages and recovery

---

## 📋 **Login Form Validation Rules**

### Email Validation
- Email is required (cannot be empty)
- Email must be in a valid format (e.g., user@example.com)
- A valid email will show a green border and a check mark icon

### Password Validation
- Password is required (cannot be empty)
- Password must meet all of the following criteria:
  - At least 6 characters long
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character (e.g., !@#$%^&*(),.?":{}|<>)
- A valid password will show a green border

### Login Button
- The login button will be enabled only when both email and password are valid
- The button will be disabled when:
  - Either field is empty
  - Email format is invalid
  - Password does not meet all requirements (length, uppercase, lowercase, number, special character)
  - The form is in a loading state

## Visual Feedback
- Valid input: Green border and check mark icon (for email)
- Invalid input: Error message displayed below the field
- Loading state: Circular progress indicator in the login button

---

## 🎯 **Next Steps**

### **Completed** ✅
- Firebase Authentication integration
- JWT token management
- Secure token storage
- Backend API integration
- User profile management
- Social sign-in (Google, Apple)

### **Future Enhancements** 🚀
- Biometric authentication
- Multi-factor authentication (MFA)
- Social sign-in with Facebook (requires setup)
- Advanced user preferences sync
- Offline authentication support

---

## 📞 **Support**

For issues or questions:
- Check the troubleshooting section above
- Review console logs with debug flags enabled
- Verify backend API documentation
- Test with different authentication providers

**Happy coding!** 🚀🔐
