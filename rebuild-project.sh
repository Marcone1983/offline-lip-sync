#!/bin/bash

set -e

echo "🚀 OFFLINE LIP SYNC - Commercial Model Bootstrap Project"
echo "========================================================"

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
    
    echo "App Name: $APP_NAME"
    echo "Slug: $APP_SLUG" 
    echo "Version: $APP_VERSION"
else
    echo -e "${RED}❌ app.config not found${NC}"
    APP_NAME="OfflineLipSync"
    APP_SLUG="offline-lip-sync"
    APP_VERSION="1.0.0"
fi

# Create project directory
PROJECT_DIR="rebuilt-$APP_SLUG"
echo -e "${BLUE}🏗️ Creating Android project: $PROJECT_DIR${NC}"
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create Android project structure
echo -e "${BLUE}📱 Creating Android project structure...${NC}"
mkdir -p app/src/main/{java/dev/a0/apps/offlinelipsync387,res/{layout,values,drawable},assets}
mkdir -p gradle/wrapper

# Create root build.gradle
echo -e "${BLUE}📦 Creating root build.gradle...${NC}"
cat > build.gradle << 'EOF'
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

# Create settings.gradle
cat > settings.gradle << 'EOF'
include ':app'
EOF

# Create app build.gradle
echo -e "${BLUE}🔧 Creating app/build.gradle...${NC}"
cat > app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'dev.a0.apps.offlinelipsync387'
    compileSdk 34
    
    defaultConfig {
        applicationId "dev.a0.apps.offlinelipsync387"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
}

dependencies {
    implementation "androidx.core:core-ktx:1.13.1"
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "com.google.android.material:material:1.12.0"
    implementation "androidx.constraintlayout:constraintlayout:2.1.4"
    implementation "androidx.work:work-runtime-ktx:2.9.1"
    implementation "com.squareup.okhttp3:okhttp:4.12.0"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1"
    implementation "androidx.annotation:annotation:1.8.2"
    implementation "androidx.lifecycle:lifecycle-process:2.8.7"
    
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.2.1'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.6.1'
}
EOF

# Create AndroidManifest.xml
echo -e "${BLUE}📱 Creating AndroidManifest.xml...${NC}"
cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    
    <!-- Model download permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Media processing permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    
    <!-- Foreground service for model download -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:name=".App"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:usesCleartextTraffic="false"
        android:theme="@style/Theme.OfflineLipSync"
        tools:targetApi="31">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.OfflineLipSync">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        
    </application>
</manifest>
EOF

# Create Kotlin source files - COMMERCIAL MODEL MANAGEMENT
KOTLIN_DIR="app/src/main/java/dev/a0/apps/offlinelipsync387"

echo -e "${BLUE}🔧 Creating Paths.kt...${NC}"
cat > "$KOTLIN_DIR/Paths.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

import android.content.Context
import java.io.File

object Paths {
    fun base(context: Context) = File(context.filesDir, "models")

    fun musetalkBin(context: Context) = File(base(context), "musetalk/pytorch_model.bin")
    fun musetalkCfg(context: Context) = File(base(context), "musetalk/musetalk.json")

    fun vaeCfg(context: Context) = File(base(context), "sd-vae-ft-mse/config.json")
    fun vaeWeights(context: Context) = File(base(context), "sd-vae-ft-mse/diffusion_pytorch_model.safetensors")

    fun dwpose(context: Context) = File(base(context), "dwpose/dw-ll_ucoco_384.pth")

    fun faceParse(context: Context) = File(base(context), "face-parse-bisenet/79999_iter.pth")
    fun faceParseResnet18(context: Context) = File(base(context), "face-parse-bisenet/resnet18-5c106cde.pth")

    fun whisperTiny(context: Context) = File(base(context), "whisper/tiny.pt")

    fun gfpgan14(context: Context) = File(base(context), "gfpgan/GFPGANv1.4.pth")
}
EOF

echo -e "${BLUE}🔧 Creating ModelManifest.kt...${NC}"
cat > "$KOTLIN_DIR/ModelManifest.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

data class ModelFile(
    val relPath: String,
    val urls: List<String>,
    val sha256: String? = null
)

object ModelManifest {
    val FILES = listOf(
        // MuseTalk (Hugging Face org TMElyralab; file principale e config)
        ModelFile(
            "musetalk/pytorch_model.bin",
            listOf(
                "https://huggingface.co/TMElyralab/MuseTalk/resolve/main/musetalk/pytorch_model.bin",
                "https://huggingface.co/ameerazam08/MuseTalk/resolve/main/models/musetalk/pytorch_model.bin"
            ),
            sha256 = null // hash non pubblicato ufficialmente al momento
        ),
        ModelFile(
            "musetalk/musetalk.json",
            listOf(
                "https://huggingface.co/TMElyralab/MuseTalk/resolve/main/musetalk/musetalk.json",
                "https://huggingface.co/ameerazam08/MuseTalk/resolve/main/models/musetalk/musetalk.json"
            ),
            sha256 = null
        ),

        // VAE ft-mse (StabilityAI)
        ModelFile(
            "sd-vae-ft-mse/config.json",
            listOf("https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/config.json"),
            sha256 = null
        ),
        ModelFile(
            "sd-vae-ft-mse/diffusion_pytorch_model.safetensors",
            listOf("https://huggingface.co/stabilityai/sd-vae-ft-mse/resolve/main/diffusion_pytorch_model.safetensors"),
            sha256 = null // pagina non espone SHA ufficiale
        ),

        // DWPose (hash esposto su LFS pointer)
        ModelFile(
            "dwpose/dw-ll_ucoco_384.pth",
            listOf(
                "https://huggingface.co/yzd-v/DWPose/resolve/main/dw-ll_ucoco_384.pth",
                "https://huggingface.co/camenduru/DWPose/resolve/main/dw-ll_ucoco_384.pth"
            ),
            sha256 = "0d9408b13cd863c4e95a149dd31232f88f2a12aa6cf8964ed74d7d97748c7a07"
        ),

        // Face parsing BiSeNet (hash esposto su LFS pointer)
        ModelFile(
            "face-parse-bisenet/79999_iter.pth",
            listOf(
                "https://huggingface.co/ManyOtherFunctions/face-parse-bisent/resolve/4a3bfd03d577fb315993d960227f4194d39ec8ec/79999_iter.pth",
                "https://huggingface.co/vivym/face-parsing-bisenet/resolve/768606b84908769d31ddd78b2e1105319839edfa/79999_iter.pth"
            ),
            sha256 = "468e13ca13a9b43cc0881a9f99083a430e9c0a38abd935431d1c28ee94b26567"
        ),
        ModelFile(
            "face-parse-bisenet/resnet18-5c106cde.pth",
            listOf("https://download.pytorch.org/models/resnet18-5c106cde.pth"),
            sha256 = null
        ),

        // Whisper tiny (encoder) – MIT, link Azure "public"
        ModelFile(
            "whisper/tiny.pt",
            listOf("https://openaipublic.azureedge.net/main/whisper/models/65147644a518d12f04e32d6f3b26facc3f8dd46e5390956a9424a650c0ce22b9/tiny.pt"),
            sha256 = "65147644a518d12f04e32d6f3b26facc3f8dd46e5390956a9424a650c0ce22b9"
        ),

        // GFPGAN v1.4 (face restore, qualità pro) – Apache-2.0
        ModelFile(
            "gfpgan/GFPGANv1.4.pth",
            listOf(
                "https://huggingface.co/gmk123/GFPGAN/resolve/main/GFPGANv1.4.pth",
                "https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv1.4.pth"
            ),
            sha256 = "e2cd4703ab14f4d01fd1383a8a8b266f9a5833dacee8e6a79d3bf21a1b6be5ad"
        )
    )
}
EOF

echo -e "${BLUE}🔧 Creating Notify.kt...${NC}"
cat > "$KOTLIN_DIR/Notify.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

import android.app.*
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

object Notify {
    const val CHANNEL_ID = "model_bootstrap"
    fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(CHANNEL_ID, "Model bootstrap", NotificationManager.IMPORTANCE_LOW)
                nm.createNotificationChannel(ch)
            }
        }
    }
    fun progress(ctx: Context, text: String, progress: Int, max: Int): Notification =
        NotificationCompat.Builder(ctx, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle("Installazione modelli")
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setProgress(max, progress, max <= 0)
            .build()
}
EOF

echo -e "${BLUE}🔧 Creating ModelBootstrapWorker.kt...${NC}"
cat > "$KOTLIN_DIR/ModelBootstrapWorker.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

import android.content.Context
import android.util.Log
import androidx.annotation.WorkerThread
import androidx.work.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import java.util.concurrent.TimeUnit

class ModelBootstrapWorker(ctx: Context, params: WorkerParameters) : CoroutineWorker(ctx, params) {

    private val ok = OkHttpClient.Builder()
        .retryOnConnectionFailure(true)
        .build()

    override suspend fun getForegroundInfo(): ForegroundInfo {
        Notify.ensureChannel(applicationContext)
        val n = Notify.progress(applicationContext, "Preparazione…", 0, 0)
        return ForegroundInfo(1001, n)
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val base = Paths.base(applicationContext).apply { mkdirs() }
        val prefs = applicationContext.getSharedPreferences("boot", Context.MODE_PRIVATE)

        val total = ModelManifest.FILES.size
        var index = 0

        for (mf in ModelManifest.FILES) {
            index++
            val out = File(base, mf.relPath)
            out.parentFile?.mkdirs()

            // se già presente e valido → salta
            if (out.exists() && mf.sha256?.let { sha256(out).equals(it, true) } != false) {
                setProgress(index, total, "Verifica ${mf.relPath}")
                continue
            }

            val tmp = File(out.parentFile, out.name + ".part")
            // resume: se esiste .part riprendo da length
            val resumed = if (tmp.exists()) tmp.length() else 0L

            var okOne = false
            for (url in mf.urls) {
                try {
                    setProgress(index, total, "Scarico ${mf.relPath}")
                    download(url, tmp, resumed)
                    // verifica eventuale SHA
                    if (mf.sha256 != null) {
                        val got = sha256(tmp)
                        if (!got.equals(mf.sha256, true)) {
                            tmp.delete()
                            throw IllegalStateException("SHA mismatch for ${mf.relPath}")
                        }
                    }
                    // atomic move
                    if (out.exists()) out.delete()
                    if (!tmp.renameTo(out)) {
                        FileOutputStream(out).use { dst ->
                            tmp.inputStream().use { src -> src.copyTo(dst) }
                            dst.fd.sync()
                        }
                        tmp.delete()
                    }
                    okOne = true
                    break
                } catch (e: Exception) {
                    Log.w("ModelBootstrap", "Fail ${mf.relPath} from $url: ${e.message}")
                    // tenta prossimo mirror
                }
            }
            if (!okOne) return@withContext Result.retry()

            setProgress(index, total, "Installato ${mf.relPath}")
        }

        prefs.edit().putBoolean("models_ready", true).apply()
        Result.success()
    }

    private suspend fun setProgress(i: Int, total: Int, label: String) {
        val n = Notify.progress(applicationContext, label, i, total)
        setForeground(ForegroundInfo(1001, n))
    }

    @WorkerThread
    private fun download(url: String, tmp: File, resumeFrom: Long) {
        val reqBuilder = Request.Builder().url(url)
            .header("User-Agent", "Growverse-LipSync-Installer/1.0")
            .get()

        if (resumeFrom > 0) {
            reqBuilder.header("Range", "bytes=$resumeFrom-")
        }

        ok.newCall(reqBuilder.build()).execute().use { resp ->
            if (!resp.isSuccessful) throw IllegalStateException("HTTP ${resp.code}")
            val append = resumeFrom > 0
            val sink = FileOutputStream(tmp, append)
            sink.channel.use { ch ->
                resp.body!!.byteStream().use { src ->
                    val buf = ByteArray(1 shl 16)
                    while (true) {
                        val r = src.read(buf)
                        if (r <= 0) break
                        ch.write(java.nio.ByteBuffer.wrap(buf, 0, r))
                    }
                    sink.fd.sync()
                }
            }
        }
    }

    private fun sha256(f: File): String {
        val md = MessageDigest.getInstance("SHA-256")
        f.inputStream().use { ins ->
            val buf = ByteArray(1 shl 16)
            while (true) {
                val r = ins.read(buf)
                if (r <= 0) break
                md.update(buf, 0, r)
            }
        }
        return md.digest().joinToString("") { "%02x".format(it) }
    }

    companion object {
        fun enqueueIfNeeded(ctx: Context) {
            val ready = ctx.getSharedPreferences("boot", Context.MODE_PRIVATE)
                .getBoolean("models_ready", false)
            if (ready) return

            val req = OneTimeWorkRequestBuilder<ModelBootstrapWorker>()
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
                .build()
            WorkManager.getInstance(ctx).enqueueUniqueWork(
                "model_bootstrap",
                ExistingWorkPolicy.KEEP,
                req
            )
        }
    }
}
EOF

echo -e "${BLUE}🔧 Creating App.kt (Application class)...${NC}"
cat > "$KOTLIN_DIR/App.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

import android.app.Application
import androidx.work.WorkInfo
import androidx.work.WorkManager

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        // Avvia bootstrap (foreground) alla prima apertura
        ModelBootstrapWorker.enqueueIfNeeded(this)

        // Se vuoi mostrare uno splash fino a SUCCEEDED, osserva lo stato:
        // WorkManager.getInstance(this).getWorkInfosForUniqueWorkLiveData("model_bootstrap")
        //   .observeForever { list -> ... }
    }
}
EOF

echo -e "${BLUE}🔧 Creating MainActivity.kt...${NC}"
cat > "$KOTLIN_DIR/MainActivity.kt" << 'EOF'
package dev.a0.apps.offlinelipsync387

import android.os.Bundle
import android.widget.TextView
import android.widget.Button
import android.widget.ProgressBar
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    private lateinit var statusText: TextView
    private lateinit var progressBar: ProgressBar
    private lateinit var startButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        statusText = findViewById(R.id.statusText)
        progressBar = findViewById(R.id.progressBar)
        startButton = findViewById(R.id.startButton)

        // Check if models are ready
        val prefs = getSharedPreferences("boot", MODE_PRIVATE)
        val modelsReady = prefs.getBoolean("models_ready", false)

        if (modelsReady) {
            showReady()
        } else {
            showDownloading()
            observeModelBootstrap()
        }

        startButton.setOnClickListener {
            if (modelsReady) {
                startLipSyncPipeline()
            }
        }
    }

    private fun observeModelBootstrap() {
        WorkManager.getInstance(this)
            .getWorkInfosForUniqueWorkLiveData("model_bootstrap")
            .observe(this) { workInfos ->
                val workInfo = workInfos?.firstOrNull()
                when (workInfo?.state) {
                    WorkInfo.State.RUNNING -> {
                        statusText.text = "Downloading AI models..."
                        progressBar.visibility = View.VISIBLE
                        startButton.visibility = View.GONE
                    }
                    WorkInfo.State.SUCCEEDED -> {
                        showReady()
                    }
                    WorkInfo.State.FAILED -> {
                        statusText.text = "Download failed. Retrying..."
                        progressBar.visibility = View.VISIBLE
                    }
                    else -> {
                        statusText.text = "Preparing..."
                        progressBar.visibility = View.VISIBLE
                    }
                }
            }
    }

    private fun showReady() {
        statusText.text = "AI Models Ready!\nMuseTalk • VAE • DWPose • Face-Parsing • Whisper • GFPGAN"
        progressBar.visibility = View.GONE
        startButton.visibility = View.VISIBLE
        startButton.text = "Start Lip Sync"
    }

    private fun showDownloading() {
        statusText.text = "Downloading AI models for offline lip-sync..."
        progressBar.visibility = View.VISIBLE
        startButton.visibility = View.GONE
    }

    private fun startLipSyncPipeline() {
        // Get model paths for your pipeline
        lifecycleScope.launch {
            val cfg = mapOf(
                "musetalk_bin" to Paths.musetalkBin(this@MainActivity).absolutePath,
                "musetalk_cfg" to Paths.musetalkCfg(this@MainActivity).absolutePath,
                "vae_cfg" to Paths.vaeCfg(this@MainActivity).absolutePath,
                "vae_weights" to Paths.vaeWeights(this@MainActivity).absolutePath,
                "dwpose" to Paths.dwpose(this@MainActivity).absolutePath,
                "face_parse" to Paths.faceParse(this@MainActivity).absolutePath,
                "resnet18" to Paths.faceParseResnet18(this@MainActivity).absolutePath,
                "whisper_tiny" to Paths.whisperTiny(this@MainActivity).absolutePath,
                "gfpgan" to Paths.gfpgan14(this@MainActivity).absolutePath
            )

            statusText.text = "Models loaded! Ready for lip-sync processing.\n\n" +
                    "Model paths configured:\n" +
                    "• MuseTalk: ${cfg["musetalk_bin"]}\n" +
                    "• VAE: ${cfg["vae_weights"]}\n" +
                    "• DWPose: ${cfg["dwpose"]}\n" +
                    "• Face-Parse: ${cfg["face_parse"]}\n" +
                    "• Whisper: ${cfg["whisper_tiny"]}\n" +
                    "• GFPGAN: ${cfg["gfpgan"]}"

            // TODO: Launch your lip-sync inference pipeline here
            // All models are downloaded and paths are ready
        }
    }
}
EOF

# Create layout files
echo -e "${BLUE}🎨 Creating layout files...${NC}"
cat > app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="24dp"
    android:gravity="center"
    android:background="@android:color/black">

    <ImageView
        android:layout_width="80dp"
        android:layout_height="80dp"
        android:src="@drawable/ic_lip_sync"
        android:layout_marginBottom="32dp"
        android:contentDescription="Lip Sync Icon" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Offline Lip Sync"
        android:textSize="24sp"
        android:textStyle="bold"
        android:textColor="@android:color/white"
        android:layout_marginBottom="8dp" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Commercial AI Models"
        android:textSize="14sp"
        android:textColor="#CCCCCC"
        android:layout_marginBottom="48dp" />

    <TextView
        android:id="@+id/statusText"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Initializing..."
        android:textSize="16sp"
        android:textColor="@android:color/white"
        android:textAlignment="center"
        android:lineSpacingMultiplier="1.3"
        android:layout_marginBottom="32dp" />

    <ProgressBar
        android:id="@+id/progressBar"
        style="@android:style/Widget.ProgressBar.Horizontal"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:indeterminate="true"
        android:layout_marginBottom="32dp"
        android:visibility="visible" />

    <Button
        android:id="@+id/startButton"
        android:layout_width="200dp"
        android:layout_height="56dp"
        android:text="Start Lip Sync"
        android:textColor="@android:color/white"
        android:backgroundTint="@color/primary_color"
        android:visibility="gone" />

</LinearLayout>
EOF

# Create values files
echo -e "${BLUE}🎨 Creating values...${NC}"
mkdir -p app/src/main/res/values

cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Offline Lip Sync</string>
</resources>
EOF

cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="primary_color">#FF6B35</color>
    <color name="primary_dark">#E55A2B</color>
    <color name="accent_color">#03DAC5</color>
    <color name="background_dark">#121212</color>
</resources>
EOF

cat > app/src/main/res/values/themes.xml << 'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">
    <style name="Theme.OfflineLipSync" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <item name="colorPrimary">@color/primary_color</item>
        <item name="colorPrimaryVariant">@color/primary_dark</item>
        <item name="colorOnPrimary">@android:color/white</item>
        <item name="colorSecondary">@color/accent_color</item>
        <item name="colorSecondaryVariant">@color/accent_color</item>
        <item name="colorOnSecondary">@android:color/black</item>
        <item name="android:statusBarColor" tools:targetApi="l">?attr/colorPrimaryVariant</item>
    </style>
</resources>
EOF

# Create drawable resources
mkdir -p app/src/main/res/drawable
cat > app/src/main/res/drawable/ic_lip_sync.xml << 'EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24"
    android:tint="@color/primary_color">
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,2C6.48,2 2,6.48 2,12s4.48,10 10,10 10,-4.48 10,-10S17.52,2 12,2zM12,20c-4.41,0 -8,-3.59 -8,-8s3.59,-8 8,-8 8,3.59 8,8 -3.59,8 -8,8z"/>
  <path
      android:fillColor="@android:color/white"
      android:pathData="M8.5,11.5c0.83,0 1.5,-0.67 1.5,-1.5s-0.67,-1.5 -1.5,-1.5S7,9.17 7,10s0.67,1.5 1.5,1.5z"/>
  <path
      android:fillColor="@android:color/white"
      android:pathData="M15.5,11.5c0.83,0 1.5,-0.67 1.5,-1.5s-0.67,-1.5 -1.5,-1.5S14,9.17 14,10s0.67,1.5 1.5,1.5z"/>
  <path
      android:fillColor="@android:color/white"
      android:pathData="M12,17.5c2.33,0 4.31,-1.46 5.11,-3.5H6.89c0.8,2.04 2.78,3.5 5.11,3.5z"/>
</vector>
EOF

# Create Gradle wrapper files
echo -e "${BLUE}🔧 Creating Gradle wrapper...${NC}"
cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# Create gradlew script
cat > gradlew << 'EOF'
#!/bin/sh
GRADLE_OPTS="$GRADLE_OPTS \"-Xmx64m\" \"-Xms64m\""
export GRADLE_OPTS

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

GRADLE_USER_HOME=${GRADLE_USER_HOME:-$HOME/.gradle}

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH."
fi

# Determine the wrapper executable
if [ "$OS" = "Windows_NT" ] ; then
    APP_HOME="`pwd -P`"
    WRAPPER_JAR="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"
else
    APP_HOME="`pwd -P`"
    WRAPPER_JAR="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"
fi

exec "$JAVACMD" $GRADLE_OPTS -Dorg.gradle.appname=$APP_BASE_NAME -jar "$WRAPPER_JAR" "$@"
EOF

chmod +x gradlew

# Create proguard rules
cat > app/proguard-rules.pro << 'EOF'
# Add project specific ProGuard rules here.
-keep class dev.a0.apps.offlinelipsync387.** { *; }
-keepclassmembers class dev.a0.apps.offlinelipsync387.** { *; }
EOF

# Create backup and data extraction rules
mkdir -p app/src/main/res/xml
cat > app/src/main/res/xml/backup_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="file" path="models/"/>
</full-backup-content>
EOF

cat > app/src/main/res/xml/data_extraction_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="file" path="models/"/>
    </cloud-backup>
    <device-transfer>
        <exclude domain="file" path="models/"/>
    </device-transfer>
</data-extraction-rules>
EOF

echo -e "${GREEN}✅ Commercial AI Model Bootstrap Project Created!${NC}"
echo -e "${BLUE}📂 Project created in: $(pwd)${NC}"
echo ""
echo -e "${YELLOW}🎯 What this app does:${NC}"
echo "• Downloads MuseTalk + VAE + DWPose + Face-Parsing + Whisper + GFPGAN"
echo "• Verifies SHA-256 hashes where available"
echo "• Supports resume for interrupted downloads"
echo "• Stores models in private app storage"
echo "• Works 100% OFFLINE after initial download"
echo "• Commercial-friendly licenses (MIT/Apache-2.0/OpenRAIL-M)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd $PROJECT_DIR"
echo "2. ./gradlew assembleDebug    # Build APK"
echo "3. ./gradlew installDebug     # Install on device"
echo ""
echo -e "${GREEN}🚀 Ready for professional lip-sync development!${NC}"