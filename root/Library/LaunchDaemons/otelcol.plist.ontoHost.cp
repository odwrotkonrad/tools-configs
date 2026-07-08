<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>otelcol</string>
	<key>ProgramArguments</key>
	<array>
		<string>/usr/local/bin/otelcol</string>
		<string>--config=file:/etc/otelcol/config.yml</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>StandardErrorPath</key>
	<string>/var/log/otelcol/otelcol.log</string>
	<key>StandardOutPath</key>
	<string>/var/log/otelcol/otelcol.log</string>
	<key>ThrottleInterval</key>
	<integer>5</integer>
</dict>
</plist>
