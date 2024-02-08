#!/bin/bash
osascript <<EOF
tell application "Terminal"
    set pi1Listening to do script "socat TCP-LISTEN:1234,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test1.pcap"
    delay 1 # Give the window a second to open
end tell
EOF

echo "start listening Pi1..."

sleep 1

osascript <<EOF
tell application "Terminal"
    set pi2Listening to do script "socat TCP-LISTEN:12345,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test2.pcap"
    delay 1 # Give the window a second to open
end tell
EOF

echo "start listening Pi2..."

sleep 1

osascript <<EOF
tell application "Terminal"
    set pi1 to do script " "
end tell
EOF

echo "Pi1 starts capturing..."

osascript <<EOF
tell application "Terminal"
    set pi2 to do script " "
end tell
EOF

osascript <<EOF
tell application "Terminal"
    do script "ssh pi@192.168.51.125 \\"cd /jffs/nexmon/; sudo ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3\\"" in pi1
end tell
EOF
osascript <<EOF
tell application "Terminal"
    do script "ssh pi@192.168.51.98 \\"cd /jffs/nexmon/; sudo ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3\\"" in pi2
end tell
EOF
echo "Pi2 starts capturing..."

sleep 5
echo "Terminating..."
killall Terminal
# echo "ending..."
# # Use AppleScript to close the Terminal window that was opened earlier
# osascript <<EOF
# tell application "Terminal"
#     # Close the window that was running the socat command
#     # This assumes it is the last opened window; adjust if necessary
#     set pi1Listening to front window
#     close pi1Listening
# end tell
# EOF
# socat TCP-LISTEN:201,reuseaddr - > test1.pcap #&
# #socat TCP-LISTEN:202,reuseaddr - > test2.pcap &

# echo "Start listening..."
# sleep 1

# ssh pi@192.168.51.125 "cd /jffs/nexmon/; sudo ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3" &
# # ssh admin@192.168.51.202 "cd /jffs/nexmon/; ./quick_setup_livestream_5GHz.sh 36 80 1 1 JCAS3" &

# sleep 15

# # ssh admin@192.168.51.201 "killall -INT tcpdump"
# # ssh admin@192.168.51.202 "killall -INT tcpdump"

# # sleep 2
# # killall -INT socat


