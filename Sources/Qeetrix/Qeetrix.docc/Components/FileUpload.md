# ``Qeetrix/QeetrixFileUpload``

## Overview

Attach files on a phone — `@qeetrix/react`'s FileUpload: the system's pickers for photos, the camera
and files, the limits in the web's words, and a row for each file with its state. The files are the
app's, in a binding, and so are the uploads: Qeetrix never sends anything anywhere.

```swift
@State private var receipts: [QeetrixFileUploadItem] = []

QeetrixFileUpload(
    "Receipts", files: $receipts, allowedContentTypes: [.pdf, .jpeg, .png], maxSize: 10_000_000,
    allowsMultiple: true
) { chosen in
    for file in chosen { upload(file) }
}
```

### What Qeetrix draws, and what iOS draws

| Part | Drawn by | Look |
|:--|:--|:--|
| The picker | Qeetrix | The web's zone (file-upload.css): `color.bg.neutral.subtle` inside a 1-point dashed `color.border.strong` edge with 4-point corners, a sharp 24-point `cloud-upload` in `color.icon.subtle`, a ghost button per source, its label and sharp icon in `color.text.brand` as the web's "browse" link is Ember, and the hint in `body.sm`, `color.text.subtle` |
| **Photos** | iOS: the Photos picker (`PhotosPicker`), out of the app's process | The system's. It needs no permission: the app only gets what the person picks |
| **Camera** | iOS: the camera (`UIImagePickerController`), full screen | The system's. iOS asks for the camera the first time, with the app's `NSCameraUsageDescription` |
| **Files** | iOS: the document browser (`fileImporter`) | The system's, offering only the allowed types |
| The rows | Qeetrix | ``QeetrixFileRow``s in a 1-point `color.border.subtle` box with 4-point corners, ruled in `color.border.subtle` |

The system pickers aren't restyled: they are where people already know how to find a photo or a file.

### Choosing

- **The sources.** `sources` (all three by default) says which to offer, and each is offered only where
  it can work: **Photos** when the allowed types include images or videos (it then shows only those);
  **Camera** when the device has one, the app's `Info.plist` has `NSCameraUsageDescription` — without
  it iOS would end the app — and a JPEG is allowed; **Files** always.
- **The checks** are the web's: the type (a file passes when its type, or the type its extension names,
  conforms to one of `allowedContentTypes`), the size (`maxSize`), and one file at a time unless
  `allowsMultiple`. The hint says them, worded as the web's — "PDF, JPEG or PNG, up to 10 MB" — unless
  `hint` replaces it.
- **Files that pass** are copied into the app's temporary directory, one folder each, and appended to
  `files` as `.chosen`, with their name, size, type and `url`; `onSelect` gets them. Start each upload
  there and report its `status` in `files`: `.uploading(progress:)` (0 to 1, or `nil` while unknown),
  `.done`, or `.error(_:)` with a reason. Delete a copy once it's uploaded, or keep it to retry.
- **Files that don't** are listed under the app's with the reason — "Only PDF, JPEG or PNG files can be
  used here", "This kind of file can't be used here", "Larger than 10 MB", "Choose one file at a time" —
  until the next choice, or Remove. Their copies are deleted at once; the app never sees them.
- **Remove** takes a file out of `files` and calls `onRemove`, where its upload is cancelled.
- **Dragging, on iPad.** A file dragged over the picker turns it Ember — `color.border.brand` and
  `color.bg.selected`, the icon in `color.icon.brand` — with "Drop to upload"; dropping runs the same
  checks.
- A photo the library can't hand over (one still in iCloud while offline) is skipped and logged. Photos
  arrive in their most compatible form — JPEG, H.264 — rather than HEIC, for servers that read only
  those.

`QeetrixFileUpload` is a field: it takes a label, a description, an `error` (which turns the picker's
edge danger), `isRequired` and `isOptional`, and is disabled by `disabled(_:)`.

### Rows on their own

``QeetrixFileRow`` shows one file anywhere — a message's attachments, a record's documents:

```swift
QeetrixFileRow(invoice) { remove(invoice) }
```

Its icon follows the web's choice by extension — `file-image`, `file-spreadsheet`, `file-code`,
`file-archive`, else `file-text` — then the file's type, so a HEIC photo is an image. The name wraps;
under it the size (``QeetrixFormat/fileSize(_:locale:)``) or a failed file's reason; under them a
``QeetrixProgress`` while it uploads, or "Uploaded" with a sharp `circle-check` in
`color.text.success`, or "Not uploaded" with a sharp `circle-alert` in `color.text.danger`.

``QeetrixFileLimits`` runs the same checks, in the same words, on a file the app gets another way:

```swift
let limits = QeetrixFileLimits(allowedContentTypes: [.pdf, .png], maxSize: 10_000_000)
let hint = limits.hint(locale: locale)  // "PDF or PNG, up to 10 MB"
```

`messages` replaces the built-in words: the sources' names, "Drop to upload", "Uploaded" and
"Not uploaded".

### Accessibility

- VoiceOver reaches the picker as a group named by the field's label, then its buttons — "Photos",
  "Camera", "Files" — and the hint. The error under the field is read in order, and the system pickers
  are the system's own, with their own VoiceOver support.
- Each row is read as one element — the name, the size or reason, the state — then its progress bar
  ("Uploading invoice.pdf, 42 percent") and its Remove button ("Remove invoice.pdf"). After Remove,
  VoiceOver returns to the first source, as the web returns focus to its input.
- New rows are announced as they appear, and each upload as it ends ("invoice.pdf, Uploaded"), as the
  web's list is a polite live region.
- Every row is at least 44 points tall, and Remove has a 44-point target; the buttons are full-size
  controls. Everything wraps at the accessibility sizes — the buttons onto more rows, file names onto
  more lines — and right to left, the layout mirrors.

### Platform differences

- **The system's pickers instead of a file input** (ADR 0014): three sources a phone has, where the web
  has one input and a drop zone. The zone's prompt, "Drag a file here, or browse", is the buttons on a
  phone; dragging is an iPad's.
- **The state goes under the name.** The web gives the state a column of its own, with a 120-pixel
  progress bar; on a phone that would leave the name a third of the row, so the state sits under the
  size, and the bar spans the text, as qeetrix-android's row does. File names wrap instead of being cut
  short.
- **A binding instead of `items` and `onRemove(id)`.** The array is the app's, and Remove edits it; new
  files are appended for the app, which `onSelect` tells.
- **Files are copied**, because a picker's file is only lent: the copy is the app's to read, upload and
  delete. The web hands over `File` objects instead.
- **The reasons' words** come from the localisation table, not `messages`.

On the web: [FileUpload on ui.qeet.in](https://ui.qeet.in/components/file-upload).

## Topics

### Files

- ``QeetrixFileUploadItem``
- ``QeetrixFileUploadStatus``
- ``QeetrixFileRow``

### Choosing

- ``QeetrixFileUploadSources``
- ``QeetrixFileLimits``
- ``QeetrixFileUploadMessages``
