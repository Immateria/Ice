//
//  HotKey+Key.swift
//  Ice
//

import Carbon.HIToolbox

extension HotKey {
    /// A representation of a physical key on a keyboard.
    public struct Key: RawRepresentable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Letters

        public static let a = Key(rawValue: kVK_ANSI_A)
        public static let b = Key(rawValue: kVK_ANSI_B)
        public static let c = Key(rawValue: kVK_ANSI_C)
        public static let d = Key(rawValue: kVK_ANSI_D)
        public static let e = Key(rawValue: kVK_ANSI_E)
        public static let f = Key(rawValue: kVK_ANSI_F)
        public static let g = Key(rawValue: kVK_ANSI_G)
        public static let h = Key(rawValue: kVK_ANSI_H)
        public static let i = Key(rawValue: kVK_ANSI_I)
        public static let j = Key(rawValue: kVK_ANSI_J)
        public static let k = Key(rawValue: kVK_ANSI_K)
        public static let l = Key(rawValue: kVK_ANSI_L)
        public static let m = Key(rawValue: kVK_ANSI_M)
        public static let n = Key(rawValue: kVK_ANSI_N)
        public static let o = Key(rawValue: kVK_ANSI_O)
        public static let p = Key(rawValue: kVK_ANSI_P)
        public static let q = Key(rawValue: kVK_ANSI_Q)
        public static let r = Key(rawValue: kVK_ANSI_R)
        public static let s = Key(rawValue: kVK_ANSI_S)
        public static let t = Key(rawValue: kVK_ANSI_T)
        public static let u = Key(rawValue: kVK_ANSI_U)
        public static let v = Key(rawValue: kVK_ANSI_V)
        public static let w = Key(rawValue: kVK_ANSI_W)
        public static let x = Key(rawValue: kVK_ANSI_X)
        public static let y = Key(rawValue: kVK_ANSI_Y)
        public static let z = Key(rawValue: kVK_ANSI_Z)

        // MARK: Numbers

        public static let zero = Key(rawValue: kVK_ANSI_0)
        public static let one = Key(rawValue: kVK_ANSI_1)
        public static let two = Key(rawValue: kVK_ANSI_2)
        public static let three = Key(rawValue: kVK_ANSI_3)
        public static let four = Key(rawValue: kVK_ANSI_4)
        public static let five = Key(rawValue: kVK_ANSI_5)
        public static let six = Key(rawValue: kVK_ANSI_6)
        public static let seven = Key(rawValue: kVK_ANSI_7)
        public static let eight = Key(rawValue: kVK_ANSI_8)
        public static let nine = Key(rawValue: kVK_ANSI_9)

        // MARK: Symbols

        public static let equal = Key(rawValue: kVK_ANSI_Equal)
        public static let minus = Key(rawValue: kVK_ANSI_Minus)
        public static let rightBracket = Key(rawValue: kVK_ANSI_RightBracket)
        public static let leftBracket = Key(rawValue: kVK_ANSI_LeftBracket)
        public static let quote = Key(rawValue: kVK_ANSI_Quote)
        public static let semicolon = Key(rawValue: kVK_ANSI_Semicolon)
        public static let backslash = Key(rawValue: kVK_ANSI_Backslash)
        public static let comma = Key(rawValue: kVK_ANSI_Comma)
        public static let slash = Key(rawValue: kVK_ANSI_Slash)
        public static let period = Key(rawValue: kVK_ANSI_Period)
        public static let grave = Key(rawValue: kVK_ANSI_Grave)

        // MARK: Keypad

        public static let keypad0 = Key(rawValue: kVK_ANSI_Keypad0)
        public static let keypad1 = Key(rawValue: kVK_ANSI_Keypad1)
        public static let keypad2 = Key(rawValue: kVK_ANSI_Keypad2)
        public static let keypad3 = Key(rawValue: kVK_ANSI_Keypad3)
        public static let keypad4 = Key(rawValue: kVK_ANSI_Keypad4)
        public static let keypad5 = Key(rawValue: kVK_ANSI_Keypad5)
        public static let keypad6 = Key(rawValue: kVK_ANSI_Keypad6)
        public static let keypad7 = Key(rawValue: kVK_ANSI_Keypad7)
        public static let keypad8 = Key(rawValue: kVK_ANSI_Keypad8)
        public static let keypad9 = Key(rawValue: kVK_ANSI_Keypad9)
        public static let keypadDecimal = Key(rawValue: kVK_ANSI_KeypadDecimal)
        public static let keypadMultiply = Key(rawValue: kVK_ANSI_KeypadMultiply)
        public static let keypadPlus = Key(rawValue: kVK_ANSI_KeypadPlus)
        public static let keypadClear = Key(rawValue: kVK_ANSI_KeypadClear)
        public static let keypadDivide = Key(rawValue: kVK_ANSI_KeypadDivide)
        public static let keypadEnter = Key(rawValue: kVK_ANSI_KeypadEnter)
        public static let keypadMinus = Key(rawValue: kVK_ANSI_KeypadMinus)
        public static let keypadEquals = Key(rawValue: kVK_ANSI_KeypadEquals)

        // MARK: Editing

        public static let space = Key(rawValue: kVK_Space)
        public static let tab = Key(rawValue: kVK_Tab)
        public static let `return` = Key(rawValue: kVK_Return)
        public static let delete = Key(rawValue: kVK_Delete)
        public static let forwardDelete = Key(rawValue: kVK_ForwardDelete)

        // MARK: Modifiers

        public static let control = Key(rawValue: kVK_Control)
        public static let option = Key(rawValue: kVK_Option)
        public static let shift = Key(rawValue: kVK_Shift)
        public static let command = Key(rawValue: kVK_Command)
        public static let rightControl = Key(rawValue: kVK_RightControl)
        public static let rightOption = Key(rawValue: kVK_RightOption)
        public static let rightShift = Key(rawValue: kVK_RightShift)
        public static let rightCommand = Key(rawValue: kVK_RightCommand)
        public static let capsLock = Key(rawValue: kVK_CapsLock)
        public static let function = Key(rawValue: kVK_Function)

        // MARK: Function

        public static let f1 = Key(rawValue: kVK_F1)
        public static let f2 = Key(rawValue: kVK_F2)
        public static let f3 = Key(rawValue: kVK_F3)
        public static let f4 = Key(rawValue: kVK_F4)
        public static let f5 = Key(rawValue: kVK_F5)
        public static let f6 = Key(rawValue: kVK_F6)
        public static let f7 = Key(rawValue: kVK_F7)
        public static let f8 = Key(rawValue: kVK_F8)
        public static let f9 = Key(rawValue: kVK_F9)
        public static let f10 = Key(rawValue: kVK_F10)
        public static let f11 = Key(rawValue: kVK_F11)
        public static let f12 = Key(rawValue: kVK_F12)
        public static let f13 = Key(rawValue: kVK_F13)
        public static let f14 = Key(rawValue: kVK_F14)
        public static let f15 = Key(rawValue: kVK_F15)
        public static let f16 = Key(rawValue: kVK_F16)
        public static let f17 = Key(rawValue: kVK_F17)
        public static let f18 = Key(rawValue: kVK_F18)
        public static let f19 = Key(rawValue: kVK_F19)
        public static let f20 = Key(rawValue: kVK_F20)

        // MARK: Navigation

        public static let pageUp = Key(rawValue: kVK_PageUp)
        public static let pageDown = Key(rawValue: kVK_PageDown)
        public static let home = Key(rawValue: kVK_Home)
        public static let end = Key(rawValue: kVK_End)
        public static let escape = Key(rawValue: kVK_Escape)
        public static let help = Key(rawValue: kVK_Help)
        public static let leftArrow = Key(rawValue: kVK_LeftArrow)
        public static let rightArrow = Key(rawValue: kVK_RightArrow)
        public static let downArrow = Key(rawValue: kVK_DownArrow)
        public static let upArrow = Key(rawValue: kVK_UpArrow)

        // MARK: Media

        public static let volumeUp = Key(rawValue: kVK_VolumeUp)
        public static let volumeDown = Key(rawValue: kVK_VolumeDown)
        public static let mute = Key(rawValue: kVK_Mute)
    }
}

// MARK: Key Equivalent
extension HotKey.Key {
    /// The system representation of the key.
    ///
    /// This value can be used to set the key equivalent of a menu item
    /// or other user interface element. Note that some keys may not have
    /// a valid system representation, in which case an empty string is
    /// returned.
    public var keyEquivalent: String {
        guard
            let inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
            let layoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData)
        else {
            return ""
        }

        let layoutBytes = CFDataGetBytePtr(unsafeBitCast(layoutData, to: CFData.self))
        let layoutPtr = unsafeBitCast(layoutBytes, to: UnsafePointer<UCKeyboardLayout>.self)

        let modifierKeyState: UInt32 = 0 // empty modifier key state
        var deadKeyState: UInt32 = 0
        let maxLength = 4
        var actualLength = 0
        var codeUnits = [UniChar](repeating: 0, count: maxLength)

        let status = UCKeyTranslate(
            layoutPtr,
            UInt16(rawValue),
            UInt16(kUCKeyActionDisplay),
            modifierKeyState,
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            maxLength,
            &actualLength,
            &codeUnits
        )

        guard status == noErr else {
            return ""
        }

        return String(utf16CodeUnits: codeUnits, count: actualLength)
    }
}

// MARK: Custom String Mappings
private let customStringMappings: [HotKey.Key: String] = {
    // standard mappings
    let standardKeys: [HotKey.Key: String] = [
        .space: "Space",
        .tab: "⇥",
        .return: "⏎",
        .delete: "⌫",
        .forwardDelete: "⌦",
        .f1: "F1",
        .f2: "F2",
        .f3: "F3",
        .f4: "F4",
        .f5: "F5",
        .f6: "F6",
        .f7: "F7",
        .f8: "F8",
        .f9: "F9",
        .f10: "F10",
        .f11: "F11",
        .f12: "F12",
        .f13: "F13",
        .f14: "F14",
        .f15: "F15",
        .f16: "F16",
        .f17: "F17",
        .f18: "F18",
        .f19: "F19",
        .f20: "F20",
        .pageUp: "⇞",
        .pageDown: "⇟",
        .home: "↖",
        .end: "↘",
        .escape: "⎋",
        .leftArrow: "←",
        .rightArrow: "→",
        .downArrow: "↓",
        .upArrow: "↑",
        .capsLock: "⇪",
        .control: "⌃",
        .option: "⌥",
        .shift: "⇧",
        .command: "⌘",
        .rightControl: "⌃",
        .rightOption: "⌥",
        .rightShift: "⇧",
        .rightCommand: "⌘",
        .keypadClear: "⌧",
        .keypadEnter: "⌤",
    ]
    // media key mappings using unicode code points
    let mediaKeys: [HotKey.Key: String] = [
        .volumeUp: "\u{1F50A}",   // U+1F50A 'SPEAKER WITH THREE SOUND WAVES'
        .volumeDown: "\u{1F509}", // U+1F509 'SPEAKER WITH ONE SOUND WAVE'
        .mute: "\u{1F507}",       // U+1F507 'SPEAKER WITH CANCELLATION STROKE'
    ]
    // keypad key mappings whose strings are enclosed with
    // U+20E3 'COMBINING ENCLOSING KEYCAP'
    let enclosedKeypadKeys: [HotKey.Key: String] = [
        .keypad0: "0\u{20E3}",
        .keypad1: "1\u{20E3}",
        .keypad2: "2\u{20E3}",
        .keypad3: "3\u{20E3}",
        .keypad4: "4\u{20E3}",
        .keypad5: "5\u{20E3}",
        .keypad6: "6\u{20E3}",
        .keypad7: "7\u{20E3}",
        .keypad8: "8\u{20E3}",
        .keypad9: "9\u{20E3}",
        .keypadDecimal: ".\u{20E3}",
        .keypadDivide: "/\u{20E3}",
        .keypadEquals: "=\u{20E3}",
        .keypadMinus: "-\u{20E3}",
        .keypadMultiply: "*\u{20E3}",
        .keypadPlus: "+\u{20E3}",
    ]
    // other key mappings that include unicode code points
    let unicodeKeys: [HotKey.Key: String] = [
        .function: "\u{1F310}\u{FE0E}", // U+1F310 'GLOBE WITH MERIDIANS'
        .help: "?\u{20DD}",             // U+20DD  'COMBINING ENCLOSING CIRCLE'
    ]
    return standardKeys
        .merging(mediaKeys, uniquingKeysWith: { $1 })
        .merging(enclosedKeypadKeys, uniquingKeysWith: { $1 })
        .merging(unicodeKeys, uniquingKeysWith: { $1 })
}()

// MARK: String Value
extension HotKey.Key {
    /// A string representation of the key.
    ///
    /// This property can be thought of as the "best" visual representation
    /// of the key. In many cases, the value returned is equal to the value
    /// returned from the ``keyEquivalent`` property. However, certain keys
    /// return a custom-mapped string that is better suited for display.
    ///
    /// ```swift
    /// let key = HotKey.Key.space
    /// print(key.keyEquivalent) // Prints: " "
    /// print(key.stringValue)   // Prints: "Space"
    /// ```
    public var stringValue: String {
        customStringMappings[self, default: keyEquivalent]
    }
}

// MARK: Key: Codable
extension HotKey.Key: Codable { }

// MARK: Key: Equatable
extension HotKey.Key: Equatable { }

// MARK: Key: Hashable
extension HotKey.Key: Hashable { }
