//
//  SceneDelegate.swift
//  Folium
//
//  Created by Jarrod Norwell on 3/6/2026.
//

import AVFoundation
import ColourKit
import ExtensionsKit
import FontKit
import OnboardingKit
import StoreKit
import SwiftUI
import UIKit

import Cherry
import Cytrus
import Durian
import Grape
import Kiwi
import Lychee
import Mandarine
import Mango
import Plum
import Tomato

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let userDefaults = UserDefaults.standard
    
    var window: UIWindow? = nil
    
    private var authorizationActors = AuthorizationActors()
    private var directoryManager = DirectoryManager()
    
    private let cherrySystem = CherrySystem()
    private let cytrusSystem = CytrusSystem()
    private let durianSystem = DurianSystem()
    private let grapeSystem = GrapeSystem()
    private let kiwiSystem = KiwiSystem()
    private let lycheeSystem = LycheeSystem()
    private let mandarineSystem = MandarineSystem()
    private let mangoSystem = MangoSystem()
    private let plumSystem = PlumSystem()
    private let tomatoSystem = TomatoSystem()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if #available(iOS 15.0, *) {
            Task.detached(priority: .background) {
                for await result in Transaction.updates {
                    guard case .verified(let transaction) = result else {
                        continue
                    }
                    
                    var inDate: Bool = false
                    if let expirationDate = transaction.expirationDate {
                        inDate = expirationDate > Date()
                    }
                    
                    UserDefaults.standard.set(transaction.revocationDate.isNil && inDate, forKey: "extraFeaturesPurchased")
                    NotificationCenter.default.post(name: NSNotification.Name("extraFeaturesStatusDidChange"), object: true)
                    
                    await transaction.finish()
                }
            }
        }
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        let gamePopulationManager = GamePopulationManager(cherrySystem, cytrusSystem, durianSystem, grapeSystem,
                                                          kiwiSystem, lycheeSystem, mandarineSystem, mangoSystem,
                                                          plumSystem, tomatoSystem)
        let onboardingFlow = OnboardingFlow(authorizationActors, directoryManager, gamePopulationManager)
        
        window = UIWindow(windowScene: windowScene)
        guard let window else {
            return
        }
        
        let onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "folium.onboardingComplete")
        
        window.rootViewController = if onboardingComplete {
            TabController(directoryManager: directoryManager, gamePopulationManager: gamePopulationManager)
        } else {
            FoliumOnboardingController(window.rootViewController ?? UIViewController(), { controller in
                await onboardingFlow.cameraAuthorization(controller)
            })
        }
        
        window.tintColor = .systemIndigo
        window.makeKeyAndVisible()
        
        initializeUserDefaultsWithDefaultValues()
        
        _ = Task {
            try await directoryManager.initializeSystemDirectoriesForInitialLaunch()
            
            await cherrySystem.initializePaths()
            await cherrySystem.initializeSystem()
            
            await cytrusSystem.initializeLogging()
            await setSettingsForCytrus()
            
            await durianSystem.initializePaths()
            await durianSystem.initializeSystem()
            await setSettingsForDurian()
            
            await grapeSystem.initializePaths()
            await grapeSystem.initializeSystem()
            await setSettingsForGrape()
            
            await kiwiSystem.initializePaths()
            await kiwiSystem.initializeSystem()
            await setSettingsForKiwi()
            
            await lycheeSystem.initializePaths()
            await lycheeSystem.initializeSystem()
            
            await mandarineSystem.initializePaths()
            await mandarineSystem.initializeMemoryCards()
            await mandarineSystem.initializeSystem()
            
            await mangoSystem.initializePaths()
            await mangoSystem.initializeSystem()
            
            await plumSystem.initializePaths()
            await plumSystem.initializeSystem()
            
            await tomatoSystem.initializePaths()
            await tomatoSystem.initializeSystem()
            await setSettingsForTomato()
            
            let session: AVAudioSession = AVAudioSession.sharedInstance()
            DispatchQueue.global(qos: .background).async {
                do {
                    try session.setCategory(.playback, options: [.mixWithOthers])
                    try session.setActive(true)
                } catch {
                    print(error, error.localizedDescription)
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.disconnected)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.foregrounded)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .applicationStateDidChange, object: ApplicationState.backgrounded)
    }
    
    private func initializeUserDefaultsWithDefaultValues() {
        let jitAvailable: Bool = JITSupport.isAvailable
        print("[Folium] Executable memory (JIT) available: \(jitAvailable). 3DS CPU and shader JIT default to \(jitAvailable ? "on" : "off").")
        
        let systemsWithDefaultValues: [System : [String : Any]] = [
            .cytrus : [
                "asyncFilesystemOperations" : true,
                "asyncPresentation" : true,
                "asyncShaderCompilation" : true,
                "cpuClockPercent" : 100,
                "cpuJIT" : jitAvailable,
                "deterministicAsyncOperations" : false,
                "fastInterpreter" : true,
                "new3DSMode" : true,
                "requiredOnlineLLEModules" : false,
                
                "logFilter" : "Info",
                
                "graphicsAPI" : 2,
                "hardwareShader" : true,
                "integerScaling" : false,
                "rightEyeRender" : true,
                "skipDuplicateFrames" : false,
                "vsync" : false,
                
                "resolutionScaleFactor" : 1,
                
                "shaderJIT" : jitAvailable,
                "shadersAccurateMultiply" : false,
                "spirvOptimizer" : true,
                "spirvShaderGeneration" : true,
                
                "simulate3DSGPUTimings" : false,
                
                "textureFilter" : 0,
                "textureSampling" : 0,
                
                "audioEmulationMode" : 0,
                "audioStretching" : true,
                "inputType" : 6,
                "outputType" : 7,
                "realtimeAudio" : false,
                "simulateHeadphonesPluggedIn" : false,
                
                "regionFreePatch" : true,
                "regionValue" : -1,
                
                "stepsPerHour" : 0,
                
                "webAPIURL" : "http://88.198.47.46:5000"
            ],
            .durian : [
                "consoleModel" : 0,
                "adjustColours" : false,
                "blendFrames" : false,
                "showIcons" : false
            ],
            .grape : [
                "skipBootScreen" : true,
                "consoleModel" : 0
            ],
            .kiwi : [
                "adjustColours" : true,
                "blendFrames" : true
            ],
            .mandarine : [
                "logBios" : false,
                "logCdrom" : false,
                "logController" : false,
                "logDma" : false,
                "logGpu" : false,
                "logGte" : false,
                "logMdec" : false,
                "logMemoryCard" : false,
                "logMemoryControl" : false,
                "logSpu" : false,
                "logSystem" : true,
                
                "forceNTSC" : false,
                "forceWidescreen" : false,
                "nativeTextureFormat" : true,
                "vsync" : false,
                "widescreen" : false,
                
                "height" : 480,
                "width" : 640,
                
                "soundEnabled" : true,
                
                "extendedMemory" : false,
                "preserveState" : true,
                "timeTravel" : false
            ],
            .tomato : [
                "skipBootScreen" : false,
                
                "adjustColours" : true,
                "blendFrames" : true,
                "frameSkipping" : false
            ]
        ]
        
        let applicationDefaultValues : [String : Any] = [
            "autoResumeOnForeground" : false,
            "defaultSystemForLibrary" : "Cherry"
        ]
        
        for (system, defaultValues) in systemsWithDefaultValues {
            for (key, value) in defaultValues {
                if userDefaults.value(forKey: "\(system.string.lowercased()).\(key)") == nil {
                    userDefaults.set(value, forKey: "\(system.string.lowercased()).\(key)")
                }
            }
        }
        
        for (key, value) in applicationDefaultValues {
            if userDefaults.value(forKey: "folium.\(key)") == nil {
                userDefaults.set(value, forKey: "folium.\(key)")
            }
        }
        
        applyCytrusPerformanceDefaultsIfNeeded(jitAvailable)
    }
    
    /// One-time migration so installs created by older builds pick up the 3DS performance
    /// defaults instead of keeping the values those builds wrote. Only values that still match
    /// the previous default are changed, so explicit user choices are preserved.
    private func applyCytrusPerformanceDefaultsIfNeeded(_ jitAvailable: Bool) {
        let migrationKey: String = "folium.cytrusPerformanceDefaultsApplied"
        guard !userDefaults.bool(forKey: migrationKey) else {
            return
        }
        userDefaults.set(true, forKey: migrationKey)
        
        let previousDefaults: [String : Bool] = [
            "asyncShaderCompilation" : false,
            "cpuJIT" : false,
            "shaderJIT" : false,
            "shadersAccurateMultiply" : true,
            "spirvOptimizer" : false
        ]
        let updatedDefaults: [String : Bool] = [
            "asyncShaderCompilation" : true,
            "cpuJIT" : jitAvailable,
            "shaderJIT" : jitAvailable,
            "shadersAccurateMultiply" : false,
            "spirvOptimizer" : true
        ]
        
        for (key, previousValue) in previousDefaults {
            let fullKey: String = "cytrus.\(key)"
            guard let currentValue: Bool = userDefaults.object(forKey: fullKey) as? Bool,
                  currentValue == previousValue,
                  let updatedValue: Bool = updatedDefaults[key] else {
                continue
            }
            
            userDefaults.set(updatedValue, forKey: fullKey)
        }
    }
    
    func setSettingsForCytrus() async {
        await SettingsHeaders.cytrusHeaders.asyncForEach { header in
            await CytrusSettingsItems.settings(header).asyncForEach { item in
                guard let settingForCytrus: (setting: cytrus.SETTING, type: Any.Type) = CytrusSettingsItems.settings[item] else {
                    return
                }
                
                Task {
                    switch settingForCytrus.type {
                    case is Bool.Type:
                        _ = await cytrusSystem.setSetting(setting: settingForCytrus.setting, value: UserDefaults.standard.bool(forKey: item.rawValue))
                    case is Int.Type:
                        _ = await cytrusSystem.setSetting(setting: settingForCytrus.setting, value: UserDefaults.standard.integer(forKey: item.rawValue))
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func setSettingsForDurian() async {
        let settingsForDurian: [DurianSettingsItems : (setting: durian.SETTING, type: Any.Type)] = [
            .consoleModel : (durian.SETTING.CONSOLE_MODEL, Int.self)
        ]
        
        await SettingsHeaders.grapeHeaders.asyncForEach { header in
            await DurianSettingsItems.settings(header).asyncForEach { item in
                guard let settingForDurian: (setting: durian.SETTING, type: Any.Type) = settingsForDurian[item] else {
                    return
                }
                
                switch settingForDurian.type {
                case is Int.Type:
                    _ = await durianSystem.setSetting(setting: settingForDurian.setting, value: UserDefaults.standard.integer(forKey: item.rawValue))
                default:
                    break
                }
            }
        }
    }
    
    func setSettingsForGrape() async {
        let settingsForGrape: [GrapeSettingsItems : (setting: grape.SETTING, type: Any.Type)] = [
            .skipBootScreen : (grape.SETTING.SKIP_BOOT_SCREEN, Bool.self),
            .consoleModel : (grape.SETTING.CONSOLE_MODEL, Int.self)
        ]
        
        await SettingsHeaders.grapeHeaders.asyncForEach { header in
            await GrapeSettingsItems.settings(header).asyncForEach { item in
                guard let settingForGrape: (setting: grape.SETTING, type: Any.Type) = settingsForGrape[item] else {
                    return
                }
                
                switch settingForGrape.type {
                case is Bool.Type:
                    _ = await grapeSystem.setSetting(setting: settingForGrape.setting, value: UserDefaults.standard.bool(forKey: item.rawValue))
                case is Int.Type:
                    _ = await grapeSystem.setSetting(setting: settingForGrape.setting, value: UserDefaults.standard.integer(forKey: item.rawValue))
                default:
                    break
                }
            }
        }
    }
    
    func setSettingsForKiwi() async {
        let settingsForKiwi: [KiwiSettingsItems : kiwi.SETTING] = [
            .adjustColours : kiwi.SETTING.ADJUST_COLOURS,
            .blendFrames : kiwi.SETTING.BLEND_FRAMES
        ]
        
        await SettingsHeaders.kiwiHeaders.asyncForEach { header in
            await KiwiSettingsItems.settings(header).asyncForEach { item in
                guard let settingForKiwi: kiwi.SETTING = settingsForKiwi[item] else {
                    return
                }
                
                _ = await kiwiSystem.setSetting(setting: settingForKiwi, value: UserDefaults.standard.value(forKey: item.rawValue))
            }
        }
    }
    
    func setSettingsForMandarine() {
        let settingsForMandarine: [MandarineSettingsItems : mandarine.SETTING] = [
            .extendedMemory : mandarine.SETTING.EXTENDED_MEMORY,
            .forceNTSC : mandarine.SETTING.FORCE_NTSC,
            .forceWidescreen : mandarine.SETTING.FORCE_WIDESCREEN,
            .logBios : mandarine.SETTING.LOG_BIOS,
            .logCdrom : mandarine.SETTING.LOG_CDROM,
            .logController : mandarine.SETTING.LOG_CONTROLLER,
            .logDma : mandarine.SETTING.LOG_DMA,
            .logGpu : mandarine.SETTING.LOG_GPU,
            .logGte : mandarine.SETTING.LOG_GTE,
            .logMdec : mandarine.SETTING.LOG_MDEC,
            .logMemoryCard : mandarine.SETTING.LOG_MEMORY_CARD,
            .logMemoryControl : mandarine.SETTING.LOG_MEMORY_CONTROL,
            .logSpu : mandarine.SETTING.LOG_SPU,
            .logSystem : mandarine.SETTING.LOG_SYSTEM,
            .nativeTextureFormat : mandarine.SETTING.NATIVE_TEXTURE_FORMAT,
            .preserveState : mandarine.SETTING.PRESERVE_STATE,
            .soundEnabled : mandarine.SETTING.SOUND_ENABLED,
            .timeTravel : mandarine.SETTING.TIME_TRAVEL,
            .vsync : mandarine.SETTING.VSYNC,
            .widescreen : mandarine.SETTING.WIDESCREEN
        ]
        
        SettingsHeaders.mandarineHeaders.forEach { header in
            MandarineSettingsItems.settings(header).forEach { item in
                guard let settingForMandarine: mandarine.SETTING = settingsForMandarine[item] else {
                    return
                }
                
                Task {
                    await mandarineSystem.setSetting(setting: settingForMandarine, value: UserDefaults.standard.value(forKey: item.rawValue))
                }
            }
        }
    }
    
    func setSettingsForTomato() async {
        let settingsForTomato: [TomatoSettingsItems : tomato.SETTING] = [
            .skipBootScreen : tomato.SETTING.SKIP_BOOT_SCREEN,
            
            .adjustColours : tomato.SETTING.ADJUST_COLOURS,
            .blendFrames : tomato.SETTING.BLEND_FRAMES,
            .frameSkipping : tomato.SETTING.FRAME_SKIPPING
        ]
        
        await SettingsHeaders.tomatoHeaders.asyncForEach { header in
            await TomatoSettingsItems.settings(header).asyncForEach { item in
                guard let settingForTomato: tomato.SETTING = settingsForTomato[item] else {
                    return
                }
                
                _ = await tomatoSystem.setSetting(setting: settingForTomato, value: UserDefaults.standard.value(forKey: item.rawValue))
            }
        }
    }
}
