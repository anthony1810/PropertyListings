# Settings Feature Specs

## Requirements from the brief

The brief asks for two tasks and neither mentions settings. Everything here is an **Addition**: the
four languages the brief's Swiss context implies become a choice inside the app, and the design
system's two palettes become a choice too.

## Story: Customer chooses how the app looks and speaks

### Narrative #1

> As a customer
> I want the app in the language I read best, whatever my phone is set to
> So I can browse listings comfortably

#### Scenarios (acceptance criteria)

**Addition.**

```
Given the app is showing listings in one language
 When the customer picks another language on the Settings tab
 Then every tab is relabelled at once, without a relaunch
  And prices keep the device's number format
  And the loaded listings stay on screen
```

**Addition.**

```
Given the customer picked a language
 When the customer kills the app and launches it again
 Then the app comes up in that language
```

**Addition.**

```
Given a fresh install
 When the customer opens the app
 Then the app speaks the language the phone chose for it
```

### Narrative #2

> As a customer
> I want to choose light or dark
> So the app matches how I use my phone

#### Scenarios (acceptance criteria)

**Addition.**

```
Given the app follows the phone's appearance
 When the customer picks Dark on the Settings tab
 Then every screen switches to the dark palette at once
  And the choice is still in effect after a relaunch
```

**Addition.** Failure handling.

```
Given a choice that cannot be saved to the device
 When the customer picks it
 Then the previous choice comes back
  And a message explains that the choice could not be saved
```

## Use cases

### Load Settings

Primary course:
1. Execute "Load Settings".
2. System reads the settings from the device.
3. System delivers the settings.

Empty course:
1. System delivers the default settings: system appearance, the language the phone chose for the app.

Unknown value course:
1. System delivers the default for the field it cannot read and keeps the rest.

### Save Settings

Data: settings (appearance, language)

Primary course:
1. Execute "Save Settings" with the settings.
2. System writes the settings to the device.
3. System notifies observers with the new settings.
4. System delivers success.

Saving error course (sad path):
1. System delivers the error.

### Observe Settings

Primary course:
1. Execute "Observe Settings".
2. System delivers the current settings immediately.
3. System delivers the settings again after every save, until the observer stops.

## Model specs

### Settings

| Property | Type | Notes |
|---|---|---|
| `appearance` | `Appearance` | `system`, `light`, `dark` |
| `language` | `AppLanguage` | `german`, `french`, `italian`, `english`; the raw value is the lproj name |

## Scenario to test map

Acceptance tests live in `PropertyListingsTests/SettingsAcceptanceTests`, through the real composition
over in-memory stores. A relaunch is a second composition over the same stores.

| Scenario | Proven by |
|---|---|
| Picking a language relabels every tab at once | `customerPicksFrench_seesEveryTabFollowAtOnce` · UI test `settingsTab_pickingFrenchRelabelsTheTabsAndSurvivesRelaunch` · snapshots `emptyFrench`, `settingsFrench` |
| The language survives a relaunch | `customerPicksFrench_seesItKeptAfterRelaunch` · UI test `settingsTab_pickingFrenchRelabelsTheTabsAndSurvivesRelaunch` |
| A fresh install follows the phone | `freshInstall_followsTheLanguageThePhoneChose` |
| Dark switches every screen and survives a relaunch | `customerPicksDark_seesItKeptAfterRelaunch` · snapshot `settings.dark` |
| A choice that cannot be saved comes back with an alert | `customerPicksDarkAndSavingFails_seesSystemBackAndAnAlert` |
