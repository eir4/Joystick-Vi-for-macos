#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

static GCController *ds4Controller = nil;

#ifdef __cplusplus
extern "C" {
#endif

int initDS4(void) {
    NSArray<GCController*> *controllers = [GCController controllers];
    if (controllers.count > 0) {
        ds4Controller = controllers.firstObject;
        return 1;
    }

    [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GCControllerDidConnectNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        if (!ds4Controller) {
            ds4Controller = note.object;
        }
    }];
    return 0; 
}

void getDS4State(float *axes, int *buttons, int *povs) {
    if (axes == NULL || buttons == NULL || povs == NULL) return;

    if (!ds4Controller || !ds4Controller.extendedGamepad) {
        for(int i = 0; i < 6; i++) axes[i] = 0.0f;
        for(int i = 0; i < 32; i++) buttons[i] = 0;
        for(int i = 0; i < 4; i++) povs[i] = -1;
        return;
    }
    
    GCExtendedGamepad *pad = ds4Controller.extendedGamepad;
    
    // AXES: Scale from macOS (-1.0 to 1.0) to Windows DirectInput (-32767.0 to 32767.0)
    // Y-axes are inverted (-32767.0) to match standard Windows DirectInput behavior
    axes[0] = pad.leftThumbstick.xAxis.value * 32767.0f;
    axes[1] = pad.leftThumbstick.yAxis.value * -32767.0f;
    axes[2] = pad.rightThumbstick.xAxis.value * 32767.0f;
    axes[3] = pad.rightThumbstick.yAxis.value * -32767.0f;
    axes[4] = pad.leftTrigger.value * 32767.0f;
    axes[5] = pad.rightTrigger.value * 32767.0f;
    
    for(int i = 0; i < 32; i++) buttons[i] = 0;
    
    // STANDARD BUTTONS (Indices 0-5)
    buttons[0] = pad.buttonX.isPressed ? 1 : 0; // Square
    buttons[1] = pad.buttonA.isPressed ? 1 : 0; // Cross
    buttons[2] = pad.buttonB.isPressed ? 1 : 0; // Circle
    buttons[3] = pad.buttonY.isPressed ? 1 : 0; // Triangle
    buttons[4] = pad.leftShoulder.isPressed ? 1 : 0; // L1
    buttons[5] = pad.rightShoulder.isPressed ? 1 : 0; // R1
    
    // TRIGGERS AS BUTTONS (Indices 6-7)
    buttons[6] = pad.leftTrigger.isPressed ? 1 : 0; // L2
    buttons[7] = pad.rightTrigger.isPressed ? 1 : 0; // R2
    
    // MENU & OPTIONS (Indices 8-9)
    buttons[8] = pad.buttonOptions ? (pad.buttonOptions.isPressed ? 1 : 0) : 0; // Share
    buttons[9] = pad.buttonMenu ? (pad.buttonMenu.isPressed ? 1 : 0) : 0; // Options
    
    // THUMBSTICK CLICKS (Indices 10-11)
    if (@available(macOS 10.14.1, *)) {
        buttons[10] = pad.leftThumbstickButton ? (pad.leftThumbstickButton.isPressed ? 1 : 0) : 0; // L3
        buttons[11] = pad.rightThumbstickButton ? (pad.rightThumbstickButton.isPressed ? 1 : 0) : 0; // R3
    }
    
    // PS BUTTON & TOUCHPAD (Indices 12-13)
    if (@available(macOS 11.0, *)) {
        buttons[12] = pad.buttonHome ? (pad.buttonHome.isPressed ? 1 : 0) : 0; // PS Home
        if ([pad isKindOfClass:[GCDualShockGamepad class]]) {
            GCDualShockGamepad *dsPad = (GCDualShockGamepad *)pad;
            buttons[13] = dsPad.touchpadButton.isPressed ? 1 : 0; // Touchpad Click
        }
    }
    
    // D-PAD AS BUTTONS (Indices 14-17)
    buttons[14] = pad.dpad.up.isPressed ? 1 : 0;
    buttons[15] = pad.dpad.down.isPressed ? 1 : 0;
    buttons[16] = pad.dpad.left.isPressed ? 1 : 0;
    buttons[17] = pad.dpad.right.isPressed ? 1 : 0;
    
    // POV / DIRECTION ARRAY (Maintains the rotational angles for standard D-Pad mapping)
    for(int i = 0; i < 4; i++) povs[i] = -1;
    
    BOOL up = pad.dpad.up.isPressed;
    BOOL down = pad.dpad.down.isPressed;
    BOOL left = pad.dpad.left.isPressed;
    BOOL right = pad.dpad.right.isPressed;
    
    int povVal = -1;
    if (up && right) povVal = 4500;
    else if (down && right) povVal = 13500;
    else if (down && left) povVal = 22500;
    else if (up && left) povVal = 31500;
    else if (up) povVal = 0;
    else if (right) povVal = 9000;
    else if (down) povVal = 18000;
    else if (left) povVal = 27000;
    
    povs[0] = povVal; 
}

#ifdef __cplusplus
}
#endif