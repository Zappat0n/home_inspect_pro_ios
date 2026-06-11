# Fastlane Setup

## Prerequisites

1. **Ruby**: Install with `brew install ruby` if needed
2. **Fastlane**: `gem install fastlane` or `bundle install` from this directory
3. **Apple ID**: An Apple Developer account ($99/year)

## Environment Variables

Set these before running any deployment lane:

| Variable | Description |
|---|---|
| `APPLE_ID` | Your Apple Developer account email |
| `APP_ID_PASSWORD` | App-specific password (Apple ID → Security) |
| `ITC_TEAM_ID` | App Store Connect team ID |
| `TEAM_ID` | Apple Developer team ID |
| `MATCH_GIT_URL` | Private git URL for code signing certificates |
| `MATCH_PASSWORD` | Password for encrypting the match repo |

## Lanes

- `bundle exec fastlane test` — Build and run tests
- `bundle exec fastlane beta` — Build + upload to TestFlight
- `bundle exec fastlane release` — Submit to App Store
- `bundle exec fastlane screenshots` — Capture screenshots via UI tests

## First-Time Setup

```bash
bundle install
fastlane match init  # Set up code signing repo
fastlane match development  # Create dev certificates
fastlane match appstore     # Create distribution certificates
fastlane beta  # Build and upload first TestFlight build
```
