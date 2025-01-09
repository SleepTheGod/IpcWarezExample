#!/bin/bash

# Define the directory to store website files
WEB_DIR="/var/www/html/malware_simulation"

# Create the directory structure
echo "Creating website directory structure..."
mkdir -p $WEB_DIR
mkdir -p $WEB_DIR/trusted_content

# Create the main index.html file
echo "Creating index.html file..."
cat <<EOL > $WEB_DIR/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Advanced Embed & IPC Simulation</title>
    <style>
        body {
            background-color: #2d2d2d;
            color: #f2f2f2;
            font-family: "Courier New", monospace;
            text-align: center;
            padding-top: 50px;
        }

        iframe {
            border: 2px solid #f0f0f0;
            box-shadow: 0 0 15px rgba(255, 255, 255, 0.2);
        }

        .button {
            background-color: #444;
            border: 1px solid #555;
            color: #f2f2f2;
            padding: 15px 32px;
            text-align: center;
            font-size: 20px;
            cursor: pointer;
            margin: 20px;
            transition: all 0.3s ease;
        }

        .button:hover {
            background-color: #555;
            border-color: #666;
        }

        .console {
            background-color: #000;
            color: #0f0;
            padding: 20px;
            border: 1px solid #444;
            font-family: "Courier New", monospace;
            width: 80%;
            margin: 20px auto;
            height: 150px;
            overflow-y: auto;
            white-space: pre-wrap;
        }
    </style>
</head>
<body>
    <h1>Malware Simulation: Advanced IPC and Content Embedding</h1>

    <!-- Embed content from a safe, educational source -->
    <iframe src="trusted_content.html" width="550" height="400"></iframe>

    <button class="button" onclick="triggerMaliciousSimulation()">Simulate Malicious Action</button>

    <div class="console" id="consoleOutput">
        Loading console output...
    </div>

    <script>
        // Simulate IPC communication with advanced logging and potential malicious behavior
        function sendIPCMessage(ipc, actionType, data) {
            const message = {
                actionType: actionType,
                key: "general.homepage",
                value: data
            };
            ipc.send("dispatch-action", JSON.stringify(message));
            logConsoleOutput(\`IPC message sent on channel "dispatch-action": \${JSON.stringify(message)}\`);
        }

        // Simulate the malicious action and log output
        function triggerMaliciousSimulation() {
            const ipc = {
                send: function(channel, message) {
                    // In a real-world scenario, this might execute harmful payloads (for educational purposes only)
                    console.log(\`Simulated IPC message on channel \${channel}: \${message}\`);
                }
            };

            const maliciousUrl = "http://attacker.example.com/";
            sendIPCMessage(ipc, "app-change-setting", maliciousUrl);
        }

        // Log messages to the console
        function logConsoleOutput(message) {
            const consoleElement = document.getElementById('consoleOutput');
            consoleElement.textContent += \`\${message}\n\`;
            consoleElement.scrollTop = consoleElement.scrollHeight; // Auto-scroll to the bottom
        }

        // Add realistic delayed simulation behavior for educational purposes
        setTimeout(() => {
            logConsoleOutput("Malicious action simulated. Check IPC behavior.");
        }, 3000);
    </script>
</body>
</html>
EOL

# Create the trusted content file
echo "Creating trusted_content.html file..."
cat <<EOL > $WEB_DIR/trusted_content/trusted_content.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trusted Content</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            text-align: center;
        }
        .content {
            padding: 20px;
        }
        .button {
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s ease;
        }
        .button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <header>
        <h1>Welcome to Trusted Content</h1>
    </header>

    <div class="content">
        <p>This is an example of trusted content embedded inside an iframe. The content is safe and does not execute any malicious behavior.</p>
        <button class="button" onclick="alert('This is a safe and educational button click!')">Click Me!</button>
    </div>

    <script>
        console.log("Trusted content loaded successfully.");
    </script>
</body>
</html>
EOL

# Install nginx if not installed
if ! command -v nginx &> /dev/null
then
    echo "nginx not found, installing nginx..."
    sudo apt update
    sudo apt install -y nginx
else
    echo "nginx already installed."
fi

# Configure nginx to serve the website
echo "Configuring nginx..."
cat <<EOL | sudo tee /etc/nginx/sites-available/malware_simulation
server {
    listen 80;
    server_name localhost;

    root $WEB_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Create a symbolic link to enable the site
echo "Enabling website configuration..."
sudo ln -s /etc/nginx/sites-available/malware_simulation /etc/nginx/sites-enabled/

# Test nginx configuration
echo "Testing nginx configuration..."
sudo nginx -t

# Restart nginx to apply changes
echo "Restarting nginx..."
sudo systemctl restart nginx

# Allow HTTP traffic through the firewall (if using ufw)
echo "Allowing HTTP traffic through the firewall..."
sudo ufw allow 'Nginx Full'

echo "Deployment complete. The site should be available at http://localhost."
