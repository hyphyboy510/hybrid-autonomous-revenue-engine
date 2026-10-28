# Native iPhone Open-Source Starter

This folder adds a native SwiftUI starter for the Hybrid Autonomous Revenue Engine, tuned for the iPhone 17 Pro Max display and usable as an open-source iOS app foundation.

## What it is

- A native SwiftUI dashboard for revenue pipelines, CRM, and status monitoring
- Dark-mode polish for premium mobile use
- API-ready data model that connects to the Python backend at `http://localhost:5001/api/v1/metrics`
- MIT-licensed project code, matching the repo license

## How to use it

1. Open Xcode.
2. Create a new iOS App project named `HybridRevenueEngine`.
3. Replace the generated `App.swift` and content files with the files in this folder.
4. Run it on a simulator or a native iPhone 17 Pro Max device.
5. Point the backend at your local Flask server or update the API URL in `RevenueStore.swift`.

## Notes

The repo already contains the Python backend in the root. This iOS starter is intended to sit on top of that API and remain open-source.
