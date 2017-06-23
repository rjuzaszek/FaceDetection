import UIKit
import Foundation

/// Holds all settings for the RecognitionAlgorithm. Intentionally left empty.
public struct Settings { /* ... */ }
/// Holds the result of the RecognitionAlgorithm. Intentionally left empty.
public struct Result { /* ... */ }
/// The amazing RecognitionAlgorithm
public class RecognitionAlgorithm {
    func apply(settings: Settings) { /* ... */ }
    func process(frame: UIImage) -> Result {
        let result = Result()
        /* ... */
        return result
    }
}

protocol Listener: class {
    func faceRecognizer(_ faceRecognizer: FaceRecognizer, didProcess frame: UIImage, result: Result)
}
/// The protocol that needs to be implemented
protocol FaceRecognizer {
    /// Add a listener
    func add(listener: Listener)
    /// Remove a listener
    func remove(listener: Listener)
    /// The setter applies the recognitionSettings to the RecognitionAlgorithm.
    var recognitionSettings: Settings { get set }
    /// Process a frame and invokes the listeners on the specified queue.
    ///
    /// - parameter frame: The frame to process.
    /// - parameter queue: The queue on which the listeners are invoked.
    func process(frame: UIImage, queue: DispatchQueue)
}

class FaceRecognizerWorker: FaceRecognizer {
    
    //MARK: Properties
    //there is a need to make here an array of weak objects (weak wrapper for Listener class) but I did't have enaugh time for that :(, otherwise ARC will keep both classes because of strong references if they won't be removed from array after recognition would stop
    var listeners: [Listener] = []
    let algorythm: RecognitionAlgorithm
    
    init(settings: Settings) {
        algorythm = RecognitionAlgorithm()
        algorythm.apply(settings: settings)
    }
    
    /// The setter applies the recognitionSettings to the RecognitionAlgorithm.
    var recognitionSettings: Settings {
        get {
            return self.recognitionSettings
        }
        
        set {
            algorythm.apply(settings: recognitionSettings)
        }
    }
    
    //MARK: Listeners add/remove
    func add(listener: Listener) {
        listeners.append(listener)
    }

    func remove(listener: Listener) {
        //simplification here, Listener type needs != operator overload
        listeners = listeners.filter() { $0 != listener }
    }
    
    //MARK: Process frame
    func process(frame: UIImage, queue: DispatchQueue) {
        //this is quick thoughts resolution
        //make this atomic to guarrantee concurenncy
        queue.sync { [unowned self] in
            let result = self.algorythm.process(frame: frame)
            for listener in self.listeners {
                listener.faceRecognizer(self, didProcess: frame, result: result)
            }
        }
    }
}
