// Top-level build configuration
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
