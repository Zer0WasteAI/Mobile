#!/bin/bash

# Deploy Firestore rules and indexes to Firebase
echo "Deploying Firestore rules and indexes..."

# Make sure you're logged in to Firebase CLI
# Run: firebase login

# Deploy only Firestore rules and indexes
firebase deploy --only firestore

echo "Firestore rules and indexes deployed successfully!"
echo ""
echo "If you see permission errors, make sure:"
echo "1. User is authenticated (logged in)"
echo "2. The userId in Firestore documents matches the authenticated user's UID"
echo "3. The Firestore rules have been deployed correctly"