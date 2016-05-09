import Lib._

lazy val root = (project in file("."))
  .aggregate(testsetup, svc, int)
  .settings(libraryDependencies ++= Seq(
    jdbc
  ))


lazy val svc = (project in file("svc"))
  .enablePlugins(PlayJava)

  .settings(jacoco.settings)
  .settings(
    Keys.fork in jacoco.Config := true)
  .settings(parallelExecution in jacoco.Config := false)
  .settings(jacoco.outputDirectory in jacoco.Config := file(baseDirectory.value.getAbsolutePath + "/target/jacoco"))
  .settings(jacoco.excludes in jacoco.Config := Seq("views*", "router*", "controllers*", "controllers*javascript*", "view.html*"))

  .settings(checkProcesses:= checkProcessesTask)
  .settings(stopProcesses:= stopProcessesTask)
  .settings(endToEndTestProtractorCI:= endToEndTestProtractorCITask)

  .settings(PlayKeys.externalizeResources := false)
  .settings(includeFilter in(Assets, LessKeys.less) := "*.less")
  .settings(clientTest := clientTestTask)
  .settings(endToEndTest := endToEndTestTask)
  .settings(startPAMM := startPAMMTask)
  .settings(stopPAMM := stopPAMMTask)
  .settings(Keys.test := customTestTask.value)
  .settings(Settings.basicSettings: _*)
  .settings(Settings.serviceSettings: _*)
  .settings(libraryDependencies ++= Seq(
    hibernate,
    javaJpa,
    cache,
    javaWs,
    evolutions,
    mysqlconn,
    jdbc,
    filters,
    commonsIO,
    playMailer,
    jjwt
  ) ++ Lib.test(
    junit
  ))

lazy val int = (project in file("int"))
  .settings(Settings.basicSettings: _*)
  .settings(libraryDependencies ++= Lib.compile(
    jaxrs, jaxrsClient, guice
  ) ++ Lib.test(
    cucumberGuice, cucumberJUnit, dbunit, mysqlconn, junit, logback
  ))

lazy val testsetup = (project in file("testsetup"))
  .enablePlugins(PlayJava)
  .settings(Settings.basicSettings: _*)
  .settings(Settings.serviceSettings: _*)
  .settings(libraryDependencies ++= Seq(
    javaJpa, hibernate, cache, javaWs, evolutions, h2, selenium, dbunit, mysqlconn
  ) ++ Lib.test(
    junit
  ))

ivyScala := ivyScala.value map {
  _.copy(overrideScalaVersion = true)
}


fork in run := true
