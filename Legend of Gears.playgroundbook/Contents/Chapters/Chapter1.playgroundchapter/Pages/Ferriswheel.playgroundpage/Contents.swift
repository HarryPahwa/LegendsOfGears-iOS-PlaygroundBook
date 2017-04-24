/*:
 Try moving your finger across the screen to adjust the background music direction
 
 Pinch the screen to show details about the added gear. Pinch again to go back.
 
 **Goal:** Generate new gears and join them together to get the Ferris Wheel moving
 
 Use the function makeGear(teethCount) to generate new gears and then drag them to join the gears. If the gears get jammed, make sure there is enough room between the gear teeth for generating movement.
 
 Gears can only be moved by their center. When moved for the first time, the gear will fly off to the gear before it. You can delete a gear by dragging it to the delete icon in the top right.
 
 **If the gears seem stuck, it means that the teeth somewhere aren't meshing properly. Try moving the gears to make them mesh properly.**
 
 **Only one gear can be generated at a time
 
 */

//#-hidden-code
import PlaygroundSupport
import Foundation

func makeGear(_ teeth: Int) {
    
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
    {
        if teeth>24 && teeth<50 {
            proxy.send(.integer(teeth))
        }
        else {
            proxy.send(.integer(0))
        }
        
    }
}
//#-end-hidden-code
//#-code-completion(identifier, show, makeGear(45), makeGear(30), makeGear(28))

//#-editable-code
let gearTeeth = 32
//#-end-editable-code
makeGear(gearTeeth)
/*:
 Optimal number of teeth for a gear are between 25 and 45.
 Any request outside of the range [25,49] will result in a random gear being drawn. You can pinch on the screen to see its specifications.
 You should move the gear before generating another one on top of it
 */
