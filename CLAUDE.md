# AnchorBloom - Claude Code Project Instructions

## Project Overview
AnchorBloom is an iOS app (SwiftUI, iOS 17+) with Firebase backend.

## Build Rules - READ BEFORE EVERY CHANGE

### Swift Compiler Rules (CRITICAL)
These are the errors that have burned us before. Check every time:

1. **Font parameter ordering**: `.system(size:weight:design:)` — `weight` MUST come before `design`
   - Correct: `.font(.system(size: 10, weight: .bold, design: .serif))`
   - Wrong: `.font(.system(size: 10, design: .serif, weight: .bold))`

2. **Argument label ordering**: Always verify parameter order matches the Swift API signature. When in doubt, check Apple docs or existing working calls in the codebase.

3. **Missing files**: Never reference files (plist, assets, etc.) that don't exist in the project. Check with Glob first.

4. **Optional handling**: Don't force-unwrap optionals. Use `if let`, `guard let`, or nil-coalescing.

## Before Pushing Code
- Search the entire changed file for common Swift errors (wrong parameter order, missing imports, type mismatches)
- Grep for patterns known to cause issues (e.g., `design: .*, weight:` which indicates wrong parameter order)
- If multiple files were changed, review each one before committing

## Project Structure
- `AnchorBloom/AnchorBloom/` — Main app source
- `AnchorBloom/AnchorBloom/App/` — App entry point, Firebase config
- `AnchorBloom/AnchorBloom/Views/` — SwiftUI views
- `AnchorBloom/AnchorBloom/Services/` — Firebase and other services
- `GoogleService-Info.plist` is gitignored — each developer must add their own

## Dependencies (via SPM)
- Firebase (Auth, Firestore, Analytics)
