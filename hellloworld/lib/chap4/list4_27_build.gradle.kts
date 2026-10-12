android {
    略
    compileOptions {
        略
        ※追記①
        isCoreLibraryDesugaringEnabled = true
    }
    略
}

※追記②
dependencies {
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}