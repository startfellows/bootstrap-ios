SF Labs iOS Bootstrap Library
=====================

Этот репозиторий содержит в себе **Bootstrap iOS Library** и генератор проектов на основе данной бибилиотеки - **tamplier**.


Bootstrap
-----

- Содержит абстрактный код, который можно переиспользовать в любом проекте SF Labs
- Состоит из нескольких основных частей:
  - UI - общие UI элементы
  - API - походы к API
  - Dump - помойка с методами-утилитами
  - Modules - Обычно - набор UIViewController'ов, которые можно вставить в любой проект, сконфигрурировать и использовать (например, экран авторизации)
  - Bootstrap - главный модуль, который позволяет кофигурировать приложение
- Другие подпроекты *in progress*..


tamplier
-----

Генерирует простые проекты на основе шаблонов **.templates**


Использование
-----

Установка **tamplier**

    brew tap sflabsorg/sf
    brew install tamplier

Генерация проекта по шаблону авторизации

    tamplier generate --auth --output ~/Desktop --name AwesomeProject

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


Разработка
-----

- Для разработки **шаблонов** и/или внесения изменений в **Boostrap** следует использовать ```Package.xcworkspace```
- Для создания шаблонов следует скопировать Authentication и изменить название проекта на свой
- Если хочется сделать начисто - структура шаблона должна повторять **Authentication** для корректной генерации проектов, а именно:
  - Название проекта = название шаблона
  - Корневая директория проекта = 'Application'
  - Инициализация Bootstrap в **main.swift**
  - Info.plist файл должен находиться в Supporting директории
  - В директории Supporting/Configuration должны находиться xcconfig и entitlements файлы
  - Все настройки проекта хранятся в xcconfig, без использования Xcode
- Следует не забыть добавить свой шаблон в **<bootstrap-path>/Sources/Tamplier/main.swift**
- После успешного создания шаблона его генерацию следует проврить локально, с помощью схемы **tamplier**

