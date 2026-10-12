# LabVIEW macOS Joystick VIs

This repository provides a macOS-compatible drop-in replacement for the native LabVIEW Joystick VIs (which are traditionally Windows-only). It uses a custom compiled dynamic library (`.dylib`) to interface with macOS's native gamepad APIs, allowing you to read axes, buttons, and POV (Point of View) data from a controller such as a DualShock 4 or Xbox controller directly within your Mac LabVIEW environment.

## Setup Instructions

Because absolute file paths vary from computer to computer, you will need to manually link the provided `.dylib` file to the VIs on your local machine before they will run correctly.

1. Download both the custom VIs and the `.dylib` file to a permanent folder on your Mac.
2. Open **Joystick Initialize.vi** in LabVIEW.
3. Open the Block Diagram (`Ctrl+E` or `Cmd+E`).
4. Locate the **Call Library Function Node**.
5. Double-click the node to open its configuration dialog.
6. In the **Library name or path** field, browse to and select the custom `.dylib` file you downloaded. 
7. Save the VI.
8. Repeat steps 2-7 for the **Joystick Acquire.vi**.

## Included VIs

This project replicates the core functionality of the standard LabVIEW Joystick VIs using two main blocks:

### 1. Joystick Initialize
This VI should be placed outside your main loop. It interfaces with the library to search for and connect to an available game controller. Internally, it triggers the discovery process and grabs the first connected controller it finds.
<img width="160" height="160" alt="dsinit" src="https://github.com/user-attachments/assets/305e94be-5dc9-41f5-9749-a48d7a7659c2" />


### 2. Joystick Acquire
This VI should be placed inside your main polling loop. It retrieves the current state of the controller. It outputs:
*   **Axes:** The thumbstick and trigger values. These are automatically scaled to match standard Windows DirectInput behavior (-32767.0 to 32767.0).
*   **Buttons:** A boolean array representing the state of the controller's buttons (Cross, Circle, Bumpers, Triggers, Thumbstick clicks, etc.).
*   **POV (Point of View):** The D-Pad directional angles.
<img width="160" height="160" alt="DSAcquire" src="https://github.com/user-attachments/assets/9bf12f76-0234-417e-94f8-7e5d884a586b" />


## How It Works

This project was built using the native macOS `GameController` framework in Xcode. The core logic bridging macOS gamepad data to a format LabVIEW can understand is contained in an Objective-C source file. 

If you wish to view or modify the underlying C/Objective-C code, you can refer to the source file named verbatim as `"DS4LabVIEW.m"`. This file handles controller discovery (`initDS4`) and state polling (`getDS4State`), including mapping the native macOS float values to the classic DirectInput integers that legacy LabVIEW applications expect.
