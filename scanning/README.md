This directory holds CE scanning scripts. This should help updating offsets for new game versions. Intention is, in most cases, only the initial offset will change.
Note I don't really know anything about this - feel free to improve. Current workflow is:
- In CE - Table -> Show Cheat Table Lua Script
- Paste script
- Adjust moduleName, knownBytes, pointerOffsets, finalOffset based on what you are scanning for. These are all in offsets.txt