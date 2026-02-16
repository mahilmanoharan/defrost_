# DEFROST

Anonymous community reporting for ICE activity. Stay informed, stay safe.

## What is this?

DEFROST lets people anonymously report and view ICE checkpoints, patrols, and raids in their area. Reports appear in real-time on everyone's feed, and you get notifications when activity is reported within 5 miles of you.

## Tech Stack

- Swift + SwiftUI (native iOS)
- Firebase (Firestore + Storage)
- CoreLocation for GPS
- MVVM architecture

## Setup

1. Clone the repo
2. Open `defrost.xcodeproj` in Xcode
3. Firebase Setup
4. Build and run

## Firebase Setup

You'll need to:
- Create a Firebase project
- Enable Firestore and Storage
- Download your `GoogleService-Info.plist`
- Add security rules 

## Usage

**Submit a report:**
1. Tap the [REPORT_] button
2. Select type (checkpoint, patrol, or raid)
3. Add location name and description
4. Optional: attach a photo
5. Swipe up to submit

**Get notifications:**
- Grant location permission (Always for background alerts)
- Keep app open or running in background
- You'll get alerted when reports come in nearby

## Notes

- Location permission must be set to "Always" for background tracking
- Notifications work best when app is open 
- All reports are anonymous - no user data is stored

## Privacy

This app doesn't collect any personal information. Location data is only used to calculate distances and trigger proximity alerts. Nothing is tied to your identity.

## License

MIT - use it however you want

## Contributing

This was built for Hack_NCState 2026 hackathon. 
