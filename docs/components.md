# 🧩 Components

Every component in Qeetrix for iOS, and its `@qeetrix/react` counterpart. Each one's API is in the DocC catalogue
(**Product › Build Documentation** in Xcode, or `Scripts/docs.sh`), and the showcase app has a page for each. ui.qeet.in
will carry the iOS pages.

| Group | Component | API | `@qeetrix/react` |
|:--|:--|:--|:--|
| 👆 Actions | Button | `QeetrixButton`, `.buttonStyle(.qeetrix())` | Button |
| 👆 Actions | Icon button | `QeetrixIconButton` | IconButton |
| 👆 Actions | Copy button and field | `QeetrixCopyButton`, `QeetrixCopyField` | CopyButton, CopyField |
| 👆 Actions | Segmented control | `QeetrixSegmentedControl` | ToggleGroup (segmented) |
| 👆 Actions | Bottom action bar | `.qeetrixBottomActionBar(primary:secondary:)`, `QeetrixScreenAction` | — (iOS only) |
| 👆 Actions | Haptics | `QeetrixFeedback`, `.qeetrixFeedback(_:trigger:)` | — (iOS only) |
| ✍️ Forms | Field | `QeetrixField` | Field |
| ✍️ Forms | Fieldset | `QeetrixFieldset` | Fieldset |
| ✍️ Forms | Text field | `QeetrixTextField` | TextField, Input |
| ✍️ Forms | Textarea | `QeetrixTextarea` | Textarea |
| ✍️ Forms | Password input | `QeetrixPasswordInput` | PasswordInput |
| ✍️ Forms | OTP input | `QeetrixOTPInput` | OTPInput |
| ✍️ Forms | Checkbox | `QeetrixCheckbox`, `.toggleStyle(.qeetrixCheckbox)` | Checkbox |
| ✍️ Forms | Radio group | `QeetrixRadioGroup`, `QeetrixOption` | RadioGroup |
| ✍️ Forms | Switch | `QeetrixSwitch`, `.toggleStyle(.qeetrixSwitch)` | Switch |
| ✍️ Forms | Select | `QeetrixSelect`, `QeetrixOption` | Select |
| ✍️ Forms | Searchable picker | `QeetrixCombobox` | Combobox |
| ✍️ Forms | Number field | `QeetrixNumberField` | NumberField |
| ✍️ Forms | Search field | `QeetrixSearchField`, `.qeetrixSearchable(text:…)` | SearchField |
| ✍️ Forms | Slider | `QeetrixSlider` | Slider |
| ✍️ Forms | Date picker and range | `QeetrixDatePicker`, `QeetrixDateRangePicker`, `QeetrixCalendar`, `QeetrixRangeCalendar` | DatePicker, DateRangePicker, Calendar, RangeCalendar |
| ✍️ Forms | Time picker | `QeetrixTimePicker` | — (iOS only) |
| ✍️ Forms | Attachments | `QeetrixFileUpload`, `QeetrixFileRow`, `QeetrixFileLimits` | FileUpload |
| ✍️ Forms | Form | `QeetrixErrorSummary`, `QeetrixFormActions` | Form, ErrorSummary |
| 📊 Data display | Text | `QeetrixText` (`size`, `weight`, `tone`, `mono`, `truncate`) | Text |
| 📊 Data display | Heading | `QeetrixHeading` (`level`, `size`, `tone`) | Heading |
| 📊 Data display | Avatar | `QeetrixAvatar` | Avatar |
| 📊 Data display | Avatar group | `QeetrixAvatarGroup` | AvatarGroup |
| 📊 Data display | Badge | `QeetrixBadge` | Badge |
| 📊 Data display | Chip | `QeetrixChip`, `QeetrixChipGroup`, `.toggleStyle(.qeetrixChip())` | Chip, ChipGroup |
| 📊 Data display | List item | `QeetrixListItem`, `QeetrixListItemIcon`, `.buttonStyle(.qeetrixListItem())`, `.qeetrixListStyle()` | — (iOS only) |
| 📊 Data display | Section header | `QeetrixSectionHeader` | — (iOS only) |
| 📊 Data display | Swipe actions | `QeetrixSwipeAction`, `.qeetrixSwipeActions(…)` | — (iOS only) |
| 📊 Data display | Pull to refresh | `.qeetrixRefreshable(…)`, `QeetrixRefreshResult` | — (iOS only) |
| 📊 Data display | Description list | `QeetrixDescriptionList`, `QeetrixDescriptionItem` | DescriptionList |
| 📊 Data display | Timeline | `QeetrixTimeline`, `QeetrixTimelineGroup`, `QeetrixTimelineItem` | Timeline |
| 📊 Data display | Stat | `QeetrixStat`, `QeetrixStatGroup` | Stat, StatGroup |
| 📊 Data display | Check list | `QeetrixCheckList`, `QeetrixCheckItem` | CheckList |
| 📊 Data display | Relative time | `QeetrixRelativeTime` | RelativeTime |
| 📊 Data display | Format | `QeetrixFormat` (numbers, currency, percent, sizes, durations, dates, times, ranges, relative time) | format |
| 📊 Data display | QR code | `QeetrixQRCode` | QRCode |
| 📊 Data display | OTP code | `QeetrixOTPCode` | — (iOS and Android) |
| 📊 Data display | Search | native `.searchable` with `QeetrixEmptyState` and `QeetrixChipGroup` | — |
| 💬 Feedback | Alert | `QeetrixAlert` | Alert |
| 💬 Feedback | Progress | `QeetrixProgress`, `.progressViewStyle(.qeetrix())` | Progress |
| 💬 Feedback | Circular progress | `QeetrixCircularProgress`, `.progressViewStyle(.qeetrixCircular())` | — (Progress's track and tones) |
| 💬 Feedback | Spinner | `QeetrixSpinner` | Spinner |
| 💬 Feedback | Skeleton | `QeetrixSkeleton`, `.qeetrixSkeletonGroup(label:)` | Skeleton |
| 💬 Feedback | Toast | `QeetrixToast`, `.qeetrixToast(_:)` | Toast |
| 💬 Feedback | Empty and data state | `QeetrixEmptyState`, `QeetrixDataState` | EmptyState, DataState |
| 🪟 Overlays | Alert dialog | `QeetrixAlertDialog`, `.qeetrixAlertDialog(_:)`, `QeetrixDialogAction` | Dialog (`intent` danger) |
| 🪟 Overlays | Confirmation dialog | `QeetrixConfirmationDialog`, `.qeetrixConfirmationDialog(_:)` | — (iOS action sheet) |
| 🪟 Overlays | Sheet | `.qeetrixSheet(isPresented:…)`, `.qeetrixSheet(item:…)`, `QeetrixSheetContent` | Drawer, Dialog |
| 🪟 Overlays | Full-screen form | `QeetrixFullScreenForm`, `.qeetrixFullScreenForm(isPresented:…)` | Dialog (`size="fullscreen"`) |
| 🪟 Overlays | Popover | `.qeetrixPopover(isPresented:…)` | Popover |
| 🪟 Overlays | Menu | `QeetrixMenu`, `QeetrixMenuItem` | Menu, ContextMenu |
| 🧭 Navigation | Tabs | `QeetrixTabs`, `QeetrixTab` | Tabs |
| 🧭 Navigation | Navigation and tab bars | `.qeetrixNavigationBar(background:)`, `.qeetrixTabBar()`, `.qeetrixTabItem(_:icon:badge:)` | — (styles the system bars) |
| 🧭 Navigation | Large title | `.qeetrixNavigationBar(background:title:)` | — (styles the system bar) |
| 🧭 Navigation | Sidebar and detail | `QeetrixSidebar`, `QeetrixNavigationScaffold`, `QeetrixNavigationItem` | Sidebar, AppShell |
| 🧭 Navigation | Steps | `QeetrixSteps`, `QeetrixStep` | Steps |
| 🧭 Navigation | Page indicator | `QeetrixPageIndicator` | — (iOS only) |
| 📐 Layout | Card | `QeetrixCard`, `.buttonStyle(.qeetrixCard())` | Card |
| 📐 Layout | Accordion | `QeetrixAccordion`, `QeetrixAccordionItem`, `.disclosureGroupStyle(.qeetrixAccordion())` | Accordion, Collapsible |
| 📐 Layout | Separator | `QeetrixSeparator` | Separator |
| 🧰 Utilities | QR scanner | `QeetrixQRScanner` | — (iOS only) |
| 🧰 Utilities | Permission primer | `QeetrixPermissionPrimer` | — (iOS only) |

Where SwiftUI has a style protocol, the style works on native controls too: `NavigationLink`, `ShareLink`, `Toggle`,
`ProgressView`.

## What every component shares

- **It wraps the system control or presentation** (`TextField`, `SecureField`, `Toggle`, `Menu`, `.sheet`, `.alert`),
  so VoiceOver, Full Keyboard Access and AutoFill behave as iOS users expect.
- **The app owns the state.** Values, selections and presentations come in as bindings; Qeetrix keeps no global state.
- **One brand, no colour parameters.** Customisation is the `@qeetrix/react` axes (variant, tone, size) and the density,
  set per region through the environment.
- **Accessibility:** a 44 pt touch target even where the drawn control is smaller, VoiceOver labels, values and traits,
  Dynamic Type to the largest size (layouts wrap rather than cut), right to left, Reduce Motion.
- **Values from the tokens and the family's CSS,** restated with the CSS rule beside each literal.
