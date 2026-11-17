Modding / Hacking notes:

Overview: http://forum.goldensunhacking.net/index.php?topic=1411.0

# Djinn Editing 

http://forum.goldensunhacking.net/index.php?topic=1421.0

080B0B78 = Add Djinni
080AE834 = Add Djinni / Raise flag in Storybook flags. (02000046)
r0 = Party Member (0-7)
r1 = Djinni type (0-3)
r2 = Djinni (0-19; or in hex: 0h-13h)

Notes: For r2, you can do up to 31/1Fh, but it would be pointless. Any higher doesn't modify djinn flags (bit out of range.)


Other interesting threads:
Battle functions: http://forum.goldensunhacking.net/index.php?topic=1632.0
ROM Location Offsets: http://forum.goldensunhacking.net/index.php?topic=1424.0
Basic Room Scripting Guide: http://forum.goldensunhacking.net/index.php?topic=2617


The holy grail:
https://docs.google.com/document/d/1nsDI-Bx6p65X25CPGdJOk8K-WVsYjYTBEN-i_bR8bdk/edit?tab=t.0
My copy: https://docs.google.com/document/d/1_6RGWHibCIqVFshCvKfTRTFJ3K8rkhwjMo2m8oTvRpo/edit?tab=t.0