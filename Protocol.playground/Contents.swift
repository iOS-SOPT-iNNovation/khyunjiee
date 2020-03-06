import Foundation

protocol NewMethodProtocol {
    mutating func execute(cmd command: String, desc: String)
    func showPort(p: Int, memo desc: String) -> String
}

struct RubyNewService: NewMethodProtocol {
    func execute(cmd command: String, desc: String) {
        if command == "start" {
            print("\(desc)를 실행합니다.")
        }
    }
    
    func showPort(p: Int, memo desc: String) -> String {
        return "Port: \(p), Memo: \(desc)"
    }
}

struct RubyNewService2: NewMethodProtocol {
    func execute(cmd comm: String, desc d: String) {
        if comm == "start" {
            print("\(d)를 실행합니다.")
        }
    }
    
    func showPort(p: Int, memo description: String) -> String {
        return "Port: \(p), Memo: \(description)"
    }
}

protocol MService {
    mutating func execute(cmd: String)
    func showPort(p: Int) -> String
}

struct RubyMService: MService {
    var paramCommand: String?
    
    mutating func execute(cmd: String) {
        self.paramCommand = cmd
        if cmd == "start" {
            print("실행합니다")
        }
    }
    
    func showPort(p: Int) -> String {
        return "Port: \(p), now command: \(self.paramCommand!)"
    }
}

struct RubyMService2: MService {
    var paramCommand: String?
    
    func execute(cmd: String) {
        if cmd == "start" {
            print("실행합니다")
        }
    }
    
    func showPort(p: Int) -> String {
        return "Port: \(p), now command: \(self.paramCommand!)"
    }
}

class RubyThread: MService {
    var paramCommand: String?
    
    func execute(cmd: String) {
        self.paramCommand = cmd
        if cmd == "start" {
            print("실행합니다")
        }
    }
    
    func showPort(p: Int) -> String {
        return "Port: \(p), now command: \(self.paramCommand!)"
    }
}

protocol SomeTypeProperty {
    static var defaultValue: String { get set }
    static func getDefaultValue() -> String
}

struct TypeStruct: SomeTypeProperty {
    static var defaultValue = "default"
    
    static func getDefaultValue() -> String {
        return defaultValue
    }
}

class ValueObject: SomeTypeProperty {
    static var defaultValue = "default"
    
    class func getDefaultValue() -> String {
        return defaultValue
    }
}

protocol SomeInitProtocol {
    init()
    init(cmd: String)
}

struct SInit: SomeInitProtocol {
    var cmd: String
    
    init() {
        self.cmd = "start"
    }
    
    init(cmd: String) {
        self.cmd = cmd
    }
}

class CInit: SomeInitProtocol {
    var cmd: String
    
    required init() {
        self.cmd = "start"
    }
    
    required init(cmd: String) {
        self.cmd = cmd
    }
}

protocol Init {
    init()
}

class Parent {
    init() {
    }
}

class Child: Parent, Init {
    override required init() {
    }
}

struct MultiImplement: NewMethodProtocol, SomeInitProtocol {
    var cmd: String
    
    init() {
        self.cmd = "default"
    }
    
    init(cmd: String) {
        self.cmd = cmd
    }
    
    mutating func execute(cmd: String, desc: String) {
        self.cmd = cmd
        
        if cmd == "start" {
            print("시작합니다")
        }
    }
    
    func showPort(p: Int, memo desc: String) -> String {
        return "Port: \(p), Memo: \(desc)"
    }
}

@objc protocol Phone {
    var phoneNumber: String { get set }
    @objc optional var emailAddress: String { get set }
    func dialNumber()
    @objc optional func getEmail()
}
