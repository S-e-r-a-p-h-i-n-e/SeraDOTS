// components/Field.qml
import QtQuick
import qs.globals

Item {
    id: root

    property string label:     "Setting"
    property var    value:     0
    property bool   isText:    false
    property bool   isDecimal: false
    property bool   disabled:  false

    // ── NEW: Only draws the bottom border line if explicitly set to true ──
    property bool   isLast:    false

    signal committed(var newValue)

    implicitWidth:  parent ? parent.width : 200
    implicitHeight: 38

    opacity: root.disabled ? 0.35 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Text {
        anchors.left:           parent.left
        anchors.leftMargin:     16
        anchors.verticalCenter: parent.verticalCenter
        text:                   root.label
        color:                  Colors.foreground
        font.family:            "JetBrainsMono Nerd Font"
        font.pixelSize:         14
        font.weight:            Font.Bold
    }

    Rectangle {
        id: inputContainer
        anchors.right:          parent.right
        anchors.rightMargin:    16
        anchors.verticalCenter: parent.verticalCenter
        width:                  120
        height:                 32
        radius:                 6
        color:                  Colors.color5

        border.width: 1
        border.color: input.activeFocus ? Colors.color5 : "transparent"
        Behavior on border.color { ColorAnimation { duration: 150 } }

        TextInput {
            id: input
            anchors.fill:         parent
            anchors.leftMargin:   8
            anchors.rightMargin:  8

            text:               String(root.value)
            color:              Colors.background
            font.family:        "JetBrainsMono Nerd Font"
            font.pixelSize:     12
            verticalAlignment:  TextInput.AlignVCenter
            selectByMouse:      true
            readOnly:           root.disabled
            clip:               true

            validator: root.isText ? null : root.isDecimal ? decimalValidator : intValidator

            DoubleValidator { id: decimalValidator; bottom: 0; top: 1;   decimals: 2 }
            IntValidator    { id: intValidator;     bottom: 0; top: 9999             }

            Keys.onReturnPressed: commit()
            Keys.onEnterPressed:  commit()
            onEditingFinished:    commit()

            function commit() {
                if (root.isText) {
                    root.committed(text)
                } else if (root.isDecimal) {
                    let v = parseFloat(text)
                    if (!isNaN(v)) root.committed(v)
                    else text = String(root.value)
                } else {
                    let v = parseInt(text)
                    if (!isNaN(v)) root.committed(v)
                    else text = String(root.value)
                }
            }
        }
    }

    // ── Conditional Section Guard Line ────────────────────────────────────
    Rectangle {
        // The line remains completely invisible unless isLast is declared
        visible:             root.isLast
        anchors.bottom:      parent.bottom
        anchors.left:        parent.left
        anchors.right:       parent.right
        height:              1
        color:               Colors.color8
        opacity:             0.5 // High opacity matching your main Section lines
    }
}
