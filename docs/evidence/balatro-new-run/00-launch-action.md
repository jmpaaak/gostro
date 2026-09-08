# 00-launch — Balatro landing checkpoint

- Observed at: 2026-09-08 17:19 KST
- Device: physical iPhone Air, iOS 26.6.1
- App: Balatro 1.0.19 (50), `com.playstack.balatropremium`
- Automation: Appium 3.7.0, XCUITest driver 12.11.0, signed WDA 16.12.1
- Action: created an Appium session with `noReset=true` and the Balatro bundle identifier. No in-app touch was performed before capture.
- Capture: Appium `GET /session/:id/screenshot` and `GET /session/:id/source` from the same active session.
- Result: `00-launch.png` is a 1368×630 downscaled copy of the 2736×1260 physical-device screenshot. `00-launch.xml` identifies the foreground AUT as Balatro and bundle id `com.playstack.balatropremium`; the game canvas exposes no internal button accessibility nodes.
- Visual transcription from the screenshot (macOS Vision OCR): title `BALATRO`; primary `PLAY`; secondary `Profile`, `OPTIONS`, `COLLECTION`; version `1.0.10-FULL [M]` as rendered on screen. OCR is used only as a transcription aid; the PNG is the visual source of truth.
