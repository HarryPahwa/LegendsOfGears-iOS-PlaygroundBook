/*:
In case you got stuck, here's one of the infinite solutions. Just call the function showSolution()
 
 */

//#-hidden-code
import PlaygroundSupport
import Foundation

func showSolution() {
    
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
    {
        proxy.send(.integer(999))
        
    }
}
//#-end-hidden-code
//#-code-completion(identifier, show, makeGear(45), makeGear(30), makeGear(28))

//#-editable-code
showSolution()
//#-end-editable-code
