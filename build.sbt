import Lib._

lazy val root = (project in file("."))
  .aggregate(testsetup, svc)
  .settings(libraryDependencies ++= Seq(
    jdbc
  ))


lazy val svc = (project in file("svc"))
  .enablePlugins(PlayJava)

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
    jdbc,
    filters,
    mysqlconn,
    playMailer,
    jjwt
  ) ++ Lib.test(
    junit
  ))

lazy val testsetup = (project in file("testsetup"))
  .enablePlugins(PlayJava)
  .settings(PlayKeys.externalizeResources := false)
  .settings(Settings.basicSettings: _*)
  .settings(Settings.serviceSettings: _*)
  .settings(libraryDependencies ++= Seq(
    javaJpa, hibernate, cache, javaWs, evolutions, h2, selenium, mysqlconn
  ) ++ Lib.test(
    junit
  ))

ivyScala := ivyScala.value map {
  _.copy(overrideScalaVersion = true)
}


fork in run := true
