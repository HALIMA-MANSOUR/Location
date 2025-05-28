// Ce bloc est désormais obsolète avec les versions récentes de Gradle pour Flutter.
// À ne garder que si tu l’utilises explicitement dans une configuration personnalisée.
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration personnalisée du répertoire de build
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")

rootProject.layout.buildDirectory.set(newBuildDir)

// Applique la même logique de buildDir aux sous-projets
subprojects {
    val newSubprojectBuildDir = newBuildDir.map { it.dir(project.name) }
    layout.buildDirectory.set(newSubprojectBuildDir)

    // Assure que le projet 'app' est évalué avant les autres
    evaluationDependsOn(":app")
}

// Tâche de nettoyage
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
