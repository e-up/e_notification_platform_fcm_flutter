# Easy To Use FCM Notification

## How To Use

### Android

#### 在 `android/app` 目录下放置 `google-services.json` 文件

    google-services.json 文件，需要在 Firebase 控制台生成

#### 在 `android/build.gradle` 加入以下文本

```groovy
    buildscript {
    ext.kotlin_version = '1.3.50'
    repositories {
        google()
        jcenter()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:4.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        +classpath 'com.google.gms:google-services:4.3.8'
    }
}
```

#### 在 `android/app/build.gradle` 加入以下文本

```groovy

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.android.application'
+apply plugin: 'com.google.gms.google-services'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"
```

### IOS

#### 在 `ios` 目录下放置 `GoogleService-Info.plist` 文件

    GoogleService-Info.plist 文件，需要在 Firebase 控制台生成
    