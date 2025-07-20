# Firedart Example

This example demonstrates how to use Firedart with the SynchronizedTrackedTimeList package to interact with Firestore, including real-time synchronization of call data.

## Setup

### 1. Firebase Project Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firestore Database
3. Set up Firestore Security Rules (see below)
4. Create a service account for authentication

### 2. Service Account Configuration

Create a `service-account.json` file in the project root with the following structure:

```json
{
  "projectId": "your-firebase-project-id",
  "apiKey": "your-firebase-api-key",
  "email": "optional-email@example.com",
  "password": "optional-password"
}
```

**Note**: This example uses a simplified service account format. For production use with full Firebase service account authentication, you would need the complete service account JSON from Firebase Console with fields like `client_email`, `private_key`, etc.

### 3. Firestore Security Rules

The example is designed to work with the provided Firestore security rules. Make sure your Firestore rules match the ones in your project:

- **Companies Collection**: Users can create companies, read if they're members, write if they're admins
- **Calls Collection**: Whitelisted users can create calls, company members can read, admins can update/delete
- **Companion App Whitelist**: Controls which users can access the companion app features
- **Extensions Collection**: Company-specific extensions with proper access control

### 4. Running the Example

```bash
# Navigate to the project directory
cd synchronized_tracked_time_list

# Install dependencies
dart pub get

# Run the example
dart run example/firestore_example.dart
```

## What the Example Demonstrates

### 1. Firebase Authentication
- Initializes Firedart with project configuration
- Demonstrates authentication setup (currently using anonymous auth for demo)

### 2. Company Management
- Creates a company document with admin and member users
- Shows how the security rules control access based on user roles

### 3. Whitelist Management
- Adds users to the companion app whitelist
- Demonstrates permission-based access control

### 4. Call Management with SynchronizedTimedSet
- Creates a `SynchronizedTimedSet<Call>` for managing call data
- Sets up `FiredartSyncService` for real-time Firestore synchronization
- Demonstrates:
  - Adding calls with different lifetimes
  - Updating call status and metadata
  - Automatic expiration and cleanup
  - Real-time sync to Firestore

### 5. Real-time Synchronization
- Shows how changes to the `SynchronizedTimedSet` are automatically synced to Firestore
- Demonstrates event handling for added, modified, removed, and expired calls
- Includes proper cleanup and resource management

## Key Features Showcased

- **Timed Data Management**: Calls automatically expire after their specified lifetime
- **Real-time Sync**: Changes are immediately reflected in Firestore
- **Security Integration**: Works with Firestore security rules for proper access control
- **Event Handling**: Listen to all data changes (add, modify, remove, expire)
- **Resource Management**: Proper cleanup of timers and subscriptions

## Production Considerations

1. **Authentication**: Implement proper service account JWT token signing for production
2. **Error Handling**: Add comprehensive error handling and retry logic
3. **Security**: Ensure service account credentials are properly secured
4. **Performance**: Consider batch operations for large datasets
5. **Monitoring**: Add logging and monitoring for production deployments

## Troubleshooting

### Common Issues

1. **"service-account.json not found"**
   - Ensure the file exists in the project root
   - Check the file permissions

2. **Authentication errors**
   - Verify your Firebase project ID is correct
   - Check that Firestore is enabled in your Firebase project

3. **Permission denied errors**
   - Review your Firestore security rules
   - Ensure the authenticated user has the required permissions

4. **Connection issues**
   - Check your internet connection
   - Verify Firebase project settings

### Debug Tips

- Enable verbose logging to see detailed Firestore operations
- Use Firebase Console to monitor real-time database changes
- Check the Firestore rules simulator for permission testing