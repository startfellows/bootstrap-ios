SF Labs iOS Bootstrap Library
=====================


- Содержит абстрактный код, который можно переиспользовать в любом проекте SF Labs
- Состоит из нескольких основных частей:
  - UI - общие UI элементы
  - API - походы к API
  - Dump - помойка с методами-утилитами
  - Modules - Обычно - набор UIViewController'ов, которые можно вставить в любой проект, сконфигрурировать и использовать (например, экран авторизации)
  - Bootstrap - главный модуль, который позволяет кофигурировать приложение
- Другие подпроекты *in progress*..


Использование
-----

Установка **[tamplier](https://github.com/sflabsorg/tamplier)**

    brew tap sflabsorg/sf
    brew install tamplier

Генерация проекта по шаблону авторизации

    tamplier generate --auth --output ~/Desktop --name AwesomeProject
    
Генерация Swift Package с Swagger API по YML спецификации

    tamplier api --path {path_to_yml_spec_file} --output ~/Desktop/AwesomeProject

Установка **Bootstrap** в обычном проекте (в сгенерированном проекте библиотека подключена по умолчанию)

    .package(url: "git@github.com:sflabsorg/bootstrap-ios.git", .branch("master"))

Пример конфигурации main.swift

    import UIKit
    import Bootstrap
    import Modules
    import API

    class ApplicationDelegate: NSObject, Bootstrap.ApplicationDelegate {
        
        func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
            
            return true
        }
    }

    class WindowSceneDelegate: NSObject, Bootstrap.WindowSceneDelegate {
        
        // MARK: Bootstrap.WindowSceneDelegate
        
        func scene(_ scene: WindowScene, willConnectToSession session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            let viewController = UIViewController()
            viewController.delegate = self
            scene.setRootViewController(viewController, animated: false)
        }
    }

    let bootstrap = Boot(
        ApplicationDelegate(),
        WindowSceneDelegate()
    )

    main(bootstrap)
