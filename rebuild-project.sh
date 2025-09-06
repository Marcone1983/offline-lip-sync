#!/bin/bash

set -e

echo "🚀 OFFLINE LIP SYNC - Project Reconstruction Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse app.config to get project details
if [ -f "assets/app.config" ]; then
    echo -e "${BLUE}📋 Reading app configuration...${NC}"
    APP_NAME=$(grep -o '"name": "[^"]*"' assets/app.config | cut -d'"' -f4 || echo "OfflineLipSync")
    APP_SLUG=$(grep -o '"slug": "[^"]*"' assets/app.config | cut -d'"' -f4 || echo "offline-lip-sync")
    APP_VERSION=$(grep -o '"version": "[^"]*"' assets/app.config | cut -d'"' -f4 || echo "1.0.0")
    RUNTIME_VERSION=$(grep -o '"runtimeVersion": "[^"]*"' assets/app.config | cut -d'"' -f4 || echo "exposdk:52.0.0")
    
    echo "App Name: $APP_NAME"
    echo "Slug: $APP_SLUG" 
    echo "Version: $APP_VERSION"
    echo "Runtime: $RUNTIME_VERSION"
else
    echo -e "${RED}❌ app.config not found${NC}"
    APP_NAME="OfflineLipSync"
    APP_SLUG="offline-lip-sync"
    APP_VERSION="1.0.0"
    RUNTIME_VERSION="exposdk:52.0.0"
fi

# Create project directory
PROJECT_DIR="rebuilt-$APP_SLUG"
echo -e "${BLUE}🏗️ Creating project: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize React Native project with Expo
echo -e "${BLUE}📱 Initializing React Native project...${NC}"
npx create-expo-app@latest . --template blank --no-install

# Create package.json with proper dependencies extracted from APK
echo -e "${BLUE}📦 Creating package.json...${NC}"
cat > package.json << EOF
{
  "name": "$APP_SLUG",
  "version": "$APP_VERSION",
  "main": "node_modules/expo/AppEntry.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "prebuild": "expo prebuild",
    "build:android": "eas build --platform android",
    "build:apk": "eas build --platform android --profile preview"
  },
  "dependencies": {
    "expo": "~52.0.0",
    "expo-av": "~14.0.7",
    "expo-camera": "~16.0.2",
    "expo-file-system": "~18.0.4",
    "expo-image-picker": "~15.0.7",
    "expo-media-library": "~16.0.5",
    "expo-notifications": "~0.29.9",
    "expo-sharing": "~12.0.1",
    "expo-status-bar": "~2.0.0",
    "expo-permissions": "~14.4.0",
    "react": "18.2.0",
    "react-native": "0.75.4",
    "react-native-reanimated": "~3.16.1",
    "react-native-safe-area-context": "4.12.0",
    "react-native-screens": "~4.0.0",
    "react-native-video": "^6.0.0",
    "react-native-fs": "^2.20.0"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0"
  }
}
EOF

# Create app.json from APK config
echo -e "${BLUE}⚙️ Creating app.json...${NC}"
cat > app.json << EOF
{
  "expo": {
    "name": "$APP_NAME",
    "slug": "$APP_SLUG",
    "version": "$APP_VERSION",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "assetBundlePatterns": [
      "**/*"
    ],
    "ios": {
      "supportsTablet": true
    },
    "android": {
      "package": "dev.a0.apps.offlipelipsync387",
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "permissions": [
        "android.permission.CAMERA",
        "android.permission.RECORD_AUDIO",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.READ_MEDIA_IMAGES",
        "android.permission.READ_MEDIA_VIDEO",
        "android.permission.READ_MEDIA_AUDIO"
      ]
    },
    "web": {
      "favicon": "./assets/favicon.png"
    },
    "plugins": [
      [
        "expo-av",
        {
          "microphonePermission": "Allow app to access your microphone for audio recording."
        }
      ],
      [
        "expo-camera",
        {
          "cameraPermission": "Allow app to access your camera for video recording."
        }
      ],
      [
        "expo-media-library",
        {
          "photosPermission": "Allow app to access your photos.",
          "savePhotosPermission": "Allow app to save photos to your library.",
          "isAccessMediaLocationEnabled": true
        }
      ]
    ]
  }
}
EOF

# Create EAS build configuration
echo -e "${BLUE}🔧 Creating EAS configuration...${NC}"
cat > eas.json << EOF
{
  "cli": {
    "version": ">= 5.2.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "android": {
        "buildType": "apk"
      }
    },
    "production": {}
  },
  "submit": {
    "production": {}
  }
}
EOF

# Create basic App.js based on Lip Sync functionality
echo -e "${BLUE}📱 Creating App.js...${NC}"
cat > App.js << 'EOF'
import React, { useState, useRef } from 'react';
import { 
  StyleSheet, 
  Text, 
  View, 
  TouchableOpacity, 
  Alert,
  SafeAreaView,
  StatusBar 
} from 'react-native';
import { StatusBar as ExpoStatusBar } from 'expo-status-bar';
import * as MediaLibrary from 'expo-media-library';
import * as FileSystem from 'expo-file-system';
import { Camera } from 'expo-camera';

export default function App() {
  const [hasPermission, setHasPermission] = useState(null);
  const [recording, setRecording] = useState(false);
  const cameraRef = useRef(null);

  React.useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      const mediaStatus = await MediaLibrary.requestPermissionsAsync();
      setHasPermission(status === 'granted' && mediaStatus.status === 'granted');
    })();
  }, []);

  const startRecording = async () => {
    if (cameraRef.current) {
      try {
        setRecording(true);
        const video = await cameraRef.current.recordAsync();
        console.log('Video recorded:', video.uri);
        
        // Save to media library
        await MediaLibrary.saveToLibraryAsync(video.uri);
        Alert.alert('Success', 'Video saved to gallery!');
      } catch (error) {
        console.error('Recording error:', error);
        Alert.alert('Error', 'Failed to record video');
      } finally {
        setRecording(false);
      }
    }
  };

  const stopRecording = async () => {
    if (cameraRef.current && recording) {
      cameraRef.current.stopRecording();
    }
  };

  if (hasPermission === null) {
    return (
      <SafeAreaView style={styles.container}>
        <Text>Requesting permissions...</Text>
      </SafeAreaView>
    );
  }

  if (hasPermission === false) {
    return (
      <SafeAreaView style={styles.container}>
        <Text>No access to camera or media library</Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" />
      <ExpoStatusBar style="light" />
      
      <View style={styles.header}>
        <Text style={styles.title}>Offline Lip Sync</Text>
        <Text style={styles.subtitle}>Video Recording & Processing</Text>
      </View>

      <View style={styles.cameraContainer}>
        <Camera
          ref={cameraRef}
          style={styles.camera}
          type={Camera.Constants.Type.front}
          ratio="16:9"
        >
          <View style={styles.overlay}>
            {recording && (
              <View style={styles.recordingIndicator}>
                <Text style={styles.recordingText}>● REC</Text>
              </View>
            )}
          </View>
        </Camera>
      </View>

      <View style={styles.controls}>
        <TouchableOpacity
          style={[styles.button, recording && styles.buttonRecording]}
          onPress={recording ? stopRecording : startRecording}
        >
          <Text style={styles.buttonText}>
            {recording ? 'Stop Recording' : 'Start Recording'}
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  header: {
    padding: 20,
    alignItems: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#ccc',
  },
  cameraContainer: {
    flex: 1,
    margin: 20,
    borderRadius: 15,
    overflow: 'hidden',
  },
  camera: {
    flex: 1,
  },
  overlay: {
    flex: 1,
    backgroundColor: 'transparent',
    justifyContent: 'flex-start',
    alignItems: 'flex-end',
    padding: 20,
  },
  recordingIndicator: {
    backgroundColor: 'rgba(255, 0, 0, 0.8)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  recordingText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 14,
  },
  controls: {
    padding: 30,
    alignItems: 'center',
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 40,
    paddingVertical: 15,
    borderRadius: 25,
    minWidth: 200,
    alignItems: 'center',
  },
  buttonRecording: {
    backgroundColor: '#FF3B30',
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
});
EOF

# Copy assets from original APK
echo -e "${BLUE}📂 Copying assets...${NC}"
mkdir -p assets

# Create placeholder assets if originals not available
echo -e "${YELLOW}📋 Creating placeholder assets...${NC}"
# These would normally be extracted from the APK resources
echo "Placeholder icon" > assets/icon.png
echo "Placeholder splash" > assets/splash.png
echo "Placeholder adaptive-icon" > assets/adaptive-icon.png
echo "Placeholder favicon" > assets/favicon.png

# Copy any available assets from APK
if [ -d "../assets" ]; then
    echo -e "${GREEN}📂 Copying assets from APK...${NC}"
    cp -r ../assets/* assets/ 2>/dev/null || true
fi

# Create metro.config.js for bundling
echo -e "${BLUE}⚙️ Creating Metro configuration...${NC}"
cat > metro.config.js << 'EOF'
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

module.exports = config;
EOF

# Create babel.config.js
cat > babel.config.js << 'EOF'
module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: ['react-native-reanimated/plugin'],
  };
};
EOF

echo -e "${GREEN}✅ Project reconstruction completed!${NC}"
echo -e "${BLUE}📂 Project created in: $(pwd)${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd $PROJECT_DIR"
echo "2. npm install"
echo "3. npx expo start"
echo "4. For APK build: eas build --platform android --profile preview"
echo ""
echo -e "${GREEN}🎉 Ready to develop and build your Offline Lip Sync app!${NC}"